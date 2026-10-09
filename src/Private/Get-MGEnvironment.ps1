function Get-MGEnvironment {
    <#
    .SYNOPSIS
        Checks for the existence of required external dependencies.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$NoInstall
    )

    process {
        $OSIsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
        
        $deps = @{
            Inkscape = if ($OSIsWindows) { "inkscape.exe" } else { "inkscape" }
            Magick   = if ($OSIsWindows) { "magick.exe" } else { "magick" }
            FFmpeg   = if ($OSIsWindows) { "ffmpeg.exe" } else { "ffmpeg" }
        }

        $results = [PSCustomObject]@{
            PSTypeName = 'MagicGester.Environment'
            Status     = 'Ready'
            Details    = @{}
        }

        foreach ($entry in $deps.GetEnumerator()) {
            $path = Get-Command $entry.Value -ErrorAction SilentlyContinue
            if ($null -eq $path -and -not $NoInstall) {
                $installed = Install-MGDependency -Name $entry.Key
                if ($installed) {
                    $path = Get-Command $entry.Value -ErrorAction SilentlyContinue
                }
            }

            if ($null -eq $path) {
                $results.Status = 'Incomplete'
                $results.Details[$entry.Key] = @{
                    Found = $false
                    Command = $entry.Value
                }
            } else {
                $results.Details[$entry.Key] = @{
                    Found   = $true
                    Path    = $path.Source
                    Command = $entry.Value
                }
            }
        }

        return $results
    }
}
