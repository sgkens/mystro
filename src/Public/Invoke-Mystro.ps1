function Invoke-Mystro {
    <#
    .SYNOPSIS
        Main routing interface for the MagicGester asset generation engine.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('mystro')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Default')]
        [ValidateSet('help', 'Gen', 'release', 'minfo', 'config', 'MGI', 'about', 'edit', 'view')]
        [string]$Mode,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Default')]
        [PSObject]$Config,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Source,

        [Parameter(ParameterSetName = 'Default')]
        [string]$OutputDir,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Format,

        [Parameter(ParameterSetName = 'Default')]
        [string[]]$Formats = @('png', 'ico', 'webp'),

        [Parameter(ParameterSetName = 'Default')]
        [string[]]$PngRanges,
        
        [Parameter(ParameterSetName = 'Default')]
        [string[]]$IcoRanges,
        
        [Parameter(ParameterSetName = 'Default')]
        [string[]]$WebpRanges,
        
        [Parameter(ParameterSetName = 'Default')]
        [string[]]$JpgRanges,
        
        [Parameter(ParameterSetName = 'Default')]
        [string[]]$SvgRanges,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$AutoScale,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$AsJson,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$SaveLocal,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$ZipBundle,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$Commit,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Version,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Range,

        [Parameter(ParameterSetName = 'Default')]
        [int]$Quality = 85,

        [Parameter(Mandatory = $true, ParameterSetName = 'Help')]
        [switch]$Help
    )

    process {
        if ($Help -or $Mode -eq 'help') {
            Show-MGTuiHelp -CmdletName 'Invoke-Mystro'
            return
        }

        # Filter out routing parameters to pass cleanly to private cmdlets
        $forwardArgs = @{}
        foreach ($key in $PSBoundParameters.Keys) {
            if ($key -notin @('Mode', 'SaveLocal', 'Help')) {
                $forwardArgs[$key] = $PSBoundParameters[$key]
            }
        }

        switch ($Mode) {
            'config' {
                $cfg = New-MGConfig @forwardArgs

                if ($SaveLocal) {
                    $localDir = Join-Path $HOME ".phellams/mystro"
                    if (-not (Test-Path $localDir)) { New-Item -ItemType Directory -Path $localDir | Out-Null }
                    $jsonPath = Join-Path $localDir "config.json"
                    $cfg | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath
                    Write-LazyLog -Level suc -Title "Config" -Message "Saved config to $jsonPath"
                }

                return $cfg
            }
            'Gen' {
                if (-not $forwardArgs.ContainsKey('Config')) {
                    $localCfg = Get-MGLocalConfig
                    if ($null -ne $localCfg) {
                        $forwardArgs['Config'] = $localCfg
                    } else {
                        throw "Config object is required for Gen mode. Provide it via pipeline, -Config parameter, or save a local config using 'mystro config -SaveLocal'."
                    }
                }
                return Invoke-MagicGester @forwardArgs
            }
            'release' {
                if (-not $forwardArgs.ContainsKey('Config')) {
                    $localCfg = Get-MGLocalConfig
                    if ($null -ne $localCfg) {
                        $forwardArgs['Config'] = $localCfg
                    } else {
                        throw "Config object is required for release mode. Provide it via -Config parameter, or save a local config using 'mystro config -SaveLocal'."
                    }
                }
                return New-MGRelease @forwardArgs
            }
            'minfo' {
                if ($forwardArgs.ContainsKey('Source')) {
                    return Get-MGImageInfo @forwardArgs
                } else {
                    return Show-MGMediaInfo @forwardArgs
                }
            }
            'MGI' {
                return Invoke-MGImageProcessor @forwardArgs
            }
            'about' {
                Show-MGAbout
            }
            'edit' {
                Start-MGEditor @forwardArgs
            }
            'view' {
                Start-MGViewer @forwardArgs
            }
        }
    }
}
