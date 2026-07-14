function New-MGRelease {
    <#
    .SYNOPSIS
        Automates the asset generation and release process for CI/CD pipelines.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('mgls')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
        [PSObject]$Config,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$Commit,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$ZipBundle,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Version,

        [Parameter(Mandatory = $true, ParameterSetName = 'Help')]
        [switch]$Help
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Help') {
            Show-MGTuiHelp -CmdletName 'New-MGRelease'
            return
        }

        Write-LazyLog -Level inf -Title "CI" -Message "Starting Automated Release Pipeline..."
        
        if ($null -eq $Config) {
            $Config = Get-MGLocalConfig
            if ($null -eq $Config) {
                Write-LazyLog -Level err -Title "Config" -Message "No configuration provided or found."
                throw "Pipeline aborted: missing configuration."
            }
        }
        
        $stats = $Config | Invoke-MagicGester -ZipBundle:$ZipBundle
        
        # Prepare release notes for commit message
        $notes = New-StringBuilder
        $notes.AppendLine("build: [MagicGester Asset Compilation]")
        $notes.AppendLine("Version: $($Version)")
        $notes.AppendLine("Summary:")
        
        foreach ($job in $stats.Jobs) {
            $notes.AppendLine("- $($job.Name): $($job.Outputs.Count) variants generated.")
        }

        Write-Host "`n--- DRAFT RELEASE NOTES ---" -ForegroundColor Cyan
        Write-Host $notes.ToString()
        Write-Host "---------------------------`n"

        if ($Commit) {
            Write-LazyLog -Level act -Title "Git" -Message "Staging assets and committing..."
        }

        return $stats
    }
}

function New-StringBuilder {
    return [System.Text.StringBuilder]::new()
}
