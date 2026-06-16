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
        $titleRaw = " PIPELINE COMPLETION REPORT"
        $pad0 = 80 - $titleRaw.Length
        Write-Host "║ $(ctstr "{ct:yellow:b:$titleRaw}")$(" " * $pad0)║" -ForegroundColor DarkMagenta
        Write-Host "╠$HBorder╣" -ForegroundColor DarkMagenta

        foreach ($job in $Stats.Jobs) {
            $sourceSizeStr = Format-MGBytes -Bytes $job.SourceSize
            
            $jobRaw = " 💠 Job: $($job.Name)"
            $pad1 = 80 - $jobRaw.Length
            Write-Host "║ $(ctstr "{ct:cyan:b:$jobRaw}")$(" " * $pad1)║" -ForegroundColor DarkMagenta
            
            $srcRaw = "    Source: $($job.Source)"
            $pad2 = 80 - $srcRaw.Length
            Write-Host "║ $srcRaw$(" " * $pad2)║" -ForegroundColor DarkMagenta
            
            $sizeRaw = "    Size:   $sourceSizeStr"
            $pad3 = 80 - $sizeRaw.Length
            Write-Host "║ $sizeRaw$(" " * $pad3)║" -ForegroundColor DarkMagenta
            
            Write-Host "╟$Divider╢" -ForegroundColor DarkMagenta

            foreach ($out in $job.Outputs) {
                $outSizeStr = Format-MGBytes -Bytes $out.Size
                $ratio = ($out.Size / $job.SourceSize) * 100
                $color = if ($ratio -lt 50) { 'green' } elseif ($ratio -lt 100) { 'yellow' } else { 'red' }
                
                $lineRaw = "    🔹 {0,-10} | {1,-10} | {2,-12} | {3:N2}%" -f $out.Format, $out.Range, $outSizeStr, $ratio
                $pad4 = 80 - $lineRaw.Length
                $formattedLine = ctstr "{ct:${color}:$lineRaw}"
                Write-Host "║ $formattedLine$(" " * $pad4)║" -ForegroundColor DarkMagenta
            }
            Write-Host "╟$Divider╢" -ForegroundColor DarkMagenta
        }

        $totalTime = "{0:N2}s" -f $Stats.TotalDuration
        $timeRaw = " 🏁 Total Execution Time: $totalTime"
        $pad5 = 80 - $timeRaw.Length
        Write-Host "║ $(ctstr "{ct:suc:b:$timeRaw}")$(" " * $pad5)║" -ForegroundColor DarkMagenta
        Write-Host "╚$HBorder╝" -ForegroundColor DarkMagenta
        Write-Host ""
    }
}

# Alias for backward compat or ease of use
if (-not (Get-Command ctstr -ErrorAction SilentlyContinue)) {
    function ctstr { param($s) return New-CTString $s }
}
