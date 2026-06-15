function Show-MGCompletionReport {
    <#
    .SYNOPSIS
        Displays a visually rich completion report for a MagicGester pipeline run.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Stats
    )

    process {
        $HBorder = "═" * 80
        $Divider = "─" * 80

        Write-Host ""
        Write-Host "╔$HBorder╗" -ForegroundColor DarkMagenta
        Write-Host "║ $(ctstr '{ct:yellow:b:PIPELINE COMPLETION REPORT}')" + (" " * 53) + "║" -ForegroundColor DarkMagenta
        Write-Host "╠$HBorder╣" -ForegroundColor DarkMagenta

        foreach ($job in $Stats.Jobs) {
            $sourceSizeStr = Format-MGBytes -Bytes $job.SourceSize
            Write-Host "║ 💠 Job: $(ctstr "{ct:cyan:b:$($job.Name)}")" + (" " * (70 - $job.Name.Length)) + "║" -ForegroundColor DarkMagenta
            Write-Host "║    Source: $($job.Source)" + (" " * (71 - $job.Source.Length)) + "║" -ForegroundColor DarkMagenta
            Write-Host "║    Size:   $sourceSizeStr" + (" " * (71 - $sourceSizeStr.Length)) + "║" -ForegroundColor DarkMagenta
            Write-Host "╟$Divider╢" -ForegroundColor DarkMagenta

            foreach ($out in $job.Outputs) {
                $outSizeStr = Format-MGBytes -Bytes $out.Size
                $ratio = ($out.Size / $job.SourceSize) * 100
                $color = if ($ratio -lt 50) { 'green' } elseif ($ratio -lt 100) { 'yellow' } else { 'red' }
                
                $line = "    🔹 {0,-10} | {1,-10} | {2,-12} | {3:N2}%" -f $out.Format, $out.Range, $outSizeStr, $ratio
                $statusLine = "║ $(ctstr "{ct:${color}:$line}")"
                # Simple padding calculation
                $paddingCount = 81 - [regex]::Replace($statusLine, '\e\[[0-9;]*m', '').Length
                Write-Host "$statusLine" + (" " * $paddingCount) + "║" -ForegroundColor DarkMagenta
            }
            Write-Host "╟$Divider╢" -ForegroundColor DarkMagenta
        }

        $totalTime = "{0:N2}s" -f $Stats.TotalDuration
        Write-Host "║ 🏁 $(ctstr "{ct:suc:b:Total Execution Time:}") $totalTime" + (" " * (54 - $totalTime.Length)) + "║" -ForegroundColor DarkMagenta
        Write-Host "╚$HBorder╝" -ForegroundColor DarkMagenta
        Write-Host ""
    }
}

# Alias for backward compat or ease of use
if (-not (Get-Command ctstr -ErrorAction SilentlyContinue)) {
    function ctstr { param($s) return New-CTString $s }
}
