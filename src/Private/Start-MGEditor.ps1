function Start-MGEditor {
    <#
    .SYNOPSIS
        Opens the specified SVG source file in the Inkscape editor.
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
            if ($Config.Jobs -and $Config.Jobs.Count -gt 0) {
                $Source = $Config.Jobs[0].SourceFile
            }
        }
        if ([string]::IsNullOrEmpty($Source)) {
            $localCfg = Get-MGLocalConfig
            if ($null -ne $localCfg -and $localCfg.Jobs -and $localCfg.Jobs.Count -gt 0) {
                $Source = $localCfg.Jobs[0].SourceFile
            }
        }

        if ([string]::IsNullOrEmpty($Source)) {
            throw "No source file specified or found in configuration."
        }

        if (-not (Test-Path $Source)) {
            throw "Source file not found: $Source"
        }

        # Resolve Inkscape path
        $env = Get-MGEnvironment -NoInstall
        $inkscape = $env.Details['Inkscape'].Path

        if (-not $inkscape) {
            Write-LazyLog -Level err -Title "Editor" -Message "Inkscape not found. Please install Inkscape to edit vector source files."
            return
        }

        Write-LazyLog -Level act -Title "Editor" -Message "Opening $Source in Inkscape..."
        
        # Start Inkscape in the background
        Start-Process -FilePath $inkscape -ArgumentList $Source
    }
}
