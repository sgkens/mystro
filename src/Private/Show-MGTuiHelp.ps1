function Show-MGTuiHelp {
    <#
    .SYNOPSIS
        Private helper to render PHWriter help for a specific cmdlet.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CmdletName
    )

    process {
        $root_path = $global:_magicgester.rootpath
        $metadataFile = Join-Path $root_path "phwrite-metadata.ps1"

        if (-not (Test-Path $metadataFile)) {
            Write-Warning "Help metadata not found at $metadataFile"
            return
        }

        # Load metadata array
        . $metadataFile

        $meta = $phwriter_metadata_array | Where-Object { $_.commandinfo.cmdlet -eq $CmdletName }

        if ($null -eq $meta) {
            Write-Warning "No help metadata found for cmdlet: $CmdletName"
            return
        }

        New-PHWriter -Name "mystro" `
                     -CommandInfo ([pscustomobject]$meta.commandinfo) `
                     -ParamTable $meta.paramtable `
                     -Examples $meta.examples `
                     -Version "0.2.0" `
                     -Padding 4 `
                     -Indent 2 `
                     -CustomLogo "MAGICGETER"
    }
}
