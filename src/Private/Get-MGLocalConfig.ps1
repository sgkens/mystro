function Get-MGLocalConfig {
    <#
    .SYNOPSIS
        Resolves and loads the local config file if it exists.
    #>
    [CmdletBinding()]
    param()

    process {
        $localDir = [System.IO.Path]::Combine($HOME, ".phellams", "mystro")
        $jsonPath = [System.IO.Path]::Combine($localDir, "config.json")
        
        if ([System.IO.File]::Exists($jsonPath)) {
            Write-LazyLog -Level inf -Title "Config" -Message "Loading config from $jsonPath" -log
            try {
                $jsonContent = [System.IO.File]::ReadAllText($jsonPath)
                $config = ConvertFrom-Json $jsonContent
                return $config
            } catch {
                Write-LazyLog -Level err -Title "Config" -Message "Failed to parse local config file: $($_.Exception.Message)" -log
            }
        }
        return $null
    }
}
