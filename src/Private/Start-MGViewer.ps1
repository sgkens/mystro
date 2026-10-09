function Start-MGViewer {
    <#
    .SYNOPSIS
        Opens the specified image file in the default system image viewer.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Source,

        [Parameter()]
        [PSObject]$Config
    )

    process {
        if ([string]::IsNullOrEmpty($Source) -and $null -ne $Config) {
            # Try to find the first successfully generated output path
            if ($Config.Jobs -and $Config.Jobs.Count -gt 0) {
                $out = $Config.Jobs[0].Outputs | Where-Object { $_.Status -eq 'Success' -or $_.Path } | Select-Object -First 1
                if ($null -ne $out) {
                    $Source = $out.Path
                } else {
                    $Source = $Config.Jobs[0].SourceFile
                }
            }
        }
        if ([string]::IsNullOrEmpty($Source)) {
            $localCfg = Get-MGLocalConfig
            if ($null -ne $localCfg -and $localCfg.Jobs -and $localCfg.Jobs.Count -gt 0) {
                $out = $localCfg.Jobs[0].Outputs | Where-Object { $_.Status -eq 'Success' -or $_.Path } | Select-Object -First 1
                if ($null -ne $out) {
                    $Source = $out.Path
                } else {
                    $Source = $localCfg.Jobs[0].SourceFile
                }
            }
        }

        if ([string]::IsNullOrEmpty($Source)) {
            throw "No image file specified or found in configuration."
        }

        if (-not (Test-Path $Source)) {
            throw "Image file not found: $Source"
        }

        Write-LazyLog -Level act -Title "Viewer" -Message "Opening $Source in system image viewer..."
        
        # Start-Process will invoke the default registered system handler for the file type
        Start-Process -FilePath $Source
    }
}
