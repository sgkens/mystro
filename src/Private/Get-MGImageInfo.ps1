function Get-MGImageInfo {
    <#
    .SYNOPSIS
        Retrieves detailed information about an image file using ImageMagick.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias("mgeri")]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Default')]
        [string]$Source,

        [Parameter(Mandatory = $true, ParameterSetName = 'Help')]
        [switch]$Help
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Help') {
            Show-MGTuiHelp -CmdletName 'Get-MGImageInfo'
            return
        }

        $env = Get-MGEnvironment
        $magick = $env.Details['Magick'].Path

        if (-not $magick) {
            Write-LazyLog -Level err -Title "Magick" -Message "ImageMagick not found."
            return
        }

        if (-not [System.IO.File]::Exists($Source)) {
            Write-LazyLog -Level err -Title "File" -Message "Source file '$Source' does not exist."
            return
        }

        try {
            $output = & $magick identify -verbose $Source
            
            $info = [ordered]@{}
            foreach ($line in $output) {
                if ($line -match '^\s*(.+?):\s*(.+)$') {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    $info[$key] = $value
                }
            }

            return [PSCustomObject]$info
        }
        catch {
            Write-LazyLog -Level err -Title "Magick" -Message "Failed to parse image info: $($_.Exception.Message)"
        }
    }
}
