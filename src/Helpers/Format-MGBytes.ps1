function Format-MGBytes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [long]$Bytes
    )

    if ($Bytes -lt 1KB) { return "$($Bytes) B" }
    if ($Bytes -lt 1MB) { return "$([math]::Round($Bytes / 1KB, 2)) KB" }
    if ($Bytes -lt 1GB) { return "$([math]::Round($Bytes / 1MB, 2)) MB" }
    if ($Bytes -lt 1TB) { return "$([math]::Round($Bytes / 1GB, 2)) GB" }
    if ($Bytes -lt 1PB) { return "$([math]::Round($Bytes / 1TB, 2)) TB" }
    return "$([math]::Round($Bytes / 1PB, 2)) PB"
}