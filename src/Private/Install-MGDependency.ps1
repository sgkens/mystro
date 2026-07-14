function Install-MGDependency {
    <#
    .SYNOPSIS
        Attempts to install a missing dependency using system package managers.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    process {
        Write-LazyLog -Level act -Title "Install" -Message "Attempting to install dependency: $Name" -log
        
        $OSIsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
        
        if ($OSIsWindows) {
            # 1. Try Scoop
            $scoop = Get-Command scoop -ErrorAction SilentlyContinue
            if ($scoop) {
                $pkg = switch ($Name) {
                    'Inkscape' { 'inkscape' }
                    'Magick'   { 'imagemagick' }
                    'FFmpeg'   { 'ffmpeg' }
                }
                Write-LazyLog -Level act -Title "Scoop" -Message "Installing $pkg via Scoop..." -log
                try {
                    $process = Start-Process scoop -ArgumentList "install $pkg" -NoNewWindow -PassThru -Wait
                    if ($process.ExitCode -eq 0) {
                        Write-LazyLog -Level suc -Title "Scoop" -Message "$pkg installed successfully." -log
                        return $true
                    }
                } catch {
                    Write-LazyLog -Level err -Title "Scoop" -Message "Scoop installation failed: $($_.Exception.Message)" -log
                }
            }
            
            # 2. Try Winget
            $winget = Get-Command winget -ErrorAction SilentlyContinue
            if ($winget) {
                $id = switch ($Name) {
                    'Inkscape' { 'Inkscape.Inkscape' }
                    'Magick'   { 'ImageMagick.ImageMagick' }
                    'FFmpeg'   { 'Gyan.FFmpeg' }
                }
                Write-LazyLog -Level act -Title "Winget" -Message "Installing $id via Winget..." -log
                try {
                    $process = Start-Process winget -ArgumentList "install --id $id -h --accept-source-agreements --accept-package-agreements" -NoNewWindow -PassThru -Wait
                    if ($process.ExitCode -eq 0) {
                        Write-LazyLog -Level suc -Title "Winget" -Message "$Name installed successfully." -log
                        return $true
                    }
                } catch {
                    Write-LazyLog -Level err -Title "Winget" -Message "Winget installation failed: $($_.Exception.Message)" -log
                }
            }
            
            Write-LazyLog -Level wrn -Title "Install" -Message "Could not install $Name automatically. Please install it manually." -log
            return $false
        } else {
            # Linux package managers: check if root or can use sudo
            $isRoot = $false
            try {
                $uid = (bash -c "id -u" -ErrorAction SilentlyContinue).Trim()
                if ($uid -eq "0") { $isRoot = $true }
            } catch {}

            $hasSudo = Get-Command sudo -ErrorAction SilentlyContinue
            $useSudo = $hasSudo -and -not $isRoot
            $sudoPrefix = if ($useSudo) { "sudo -n " } else { "" }

            $pkg = switch ($Name) {
                'Inkscape' { 'inkscape' }
                'Magick'   { 'imagemagick' }
                'FFmpeg'   { 'ffmpeg' }
            }

            $pm = $null
            $cmd = $null

            if (Get-Command apt-get -ErrorAction SilentlyContinue) {
                $pm = 'apt'
                # For headless/non-interactive install on Linux, use env DEBIAN_FRONTEND=noninteractive
                $cmd = "${sudoPrefix}env DEBIAN_FRONTEND=noninteractive apt-get update -y && ${sudoPrefix}env DEBIAN_FRONTEND=noninteractive apt-get install -y $pkg"
            } elseif (Get-Command dnf -ErrorAction SilentlyContinue) {
                $pm = 'dnf'
                $pkgName = if ($Name -eq 'Magick') { 'ImageMagick' } else { $pkg }
                $cmd = "${sudoPrefix}dnf install -y $pkgName"
            } elseif (Get-Command yum -ErrorAction SilentlyContinue) {
                $pm = 'yum'
                $pkgName = if ($Name -eq 'Magick') { 'ImageMagick' } else { $pkg }
                $cmd = "${sudoPrefix}yum install -y $pkgName"
            } elseif (Get-Command pacman -ErrorAction SilentlyContinue) {
                $pm = 'pacman'
                $cmd = "${sudoPrefix}pacman -S --noconfirm $pkg"
            } elseif (Get-Command apk -ErrorAction SilentlyContinue) {
                $pm = 'apk'
                $cmd = "${sudoPrefix}apk add --no-cache $pkg"
            }

            if ($pm) {
                Write-LazyLog -Level act -Title "Linux-PM" -Message "Installing $Name via $pm using command: $cmd" -log
                try {
                    $process = Start-Process bash -ArgumentList "-c `"$cmd`"" -NoNewWindow -PassThru -Wait
                    if ($process.ExitCode -eq 0) {
                        Write-LazyLog -Level suc -Title "Linux-PM" -Message "$Name installed successfully." -log
                        return $true
                    } else {
                        Write-LazyLog -Level err -Title "Linux-PM" -Message "Installation command returned non-zero exit code: $($process.ExitCode). Non-interactive sudo or package manager command failed." -log
                        Write-LazyLog -Level wrn -Title "Install" -Message "Please run manually: sudo apt-get update && sudo apt-get install -y $pkg" -log
                    }
                } catch {
                    Write-LazyLog -Level err -Title "Linux-PM" -Message "Package manager installation failed: $($_.Exception.Message)" -log
                    Write-LazyLog -Level wrn -Title "Install" -Message "Please run manually: sudo apt-get update && sudo apt-get install -y $pkg" -log
                }
            } else {
                Write-LazyLog -Level wrn -Title "Install" -Message "No recognized Linux package manager found. Please install $Name manually." -log
            }
            return $false
        }
    }
}
