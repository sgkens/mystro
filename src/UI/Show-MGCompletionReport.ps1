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
        
        $titleRaw = "  PIPELINE COMPLETION REPORT"
        $paddedTitle = Pad-AnsiString -Text (ctstr "{ct:yellow:b:$titleRaw}") -Width 80 -Align Left
        Write-Host "║$paddedTitle║" -ForegroundColor DarkMagenta
        Write-Host "╠$HBorder╣" -ForegroundColor DarkMagenta

        foreach ($job in $Stats.Jobs) {
            $sourceSizeStr = Format-MGBytes -Bytes $job.SourceSize
            
            $jobText = ctstr "{ct:cyan:b: ◆ Job: $($job.Name)}"
            $paddedJob = Pad-AnsiString -Text $jobText -Width 80 -Align Left
            Write-Host "║$paddedJob║" -ForegroundColor DarkMagenta
            
            $srcText = "    Source: $($job.Source)"
            $paddedSrc = Pad-AnsiString -Text $srcText -Width 80 -Align Left -Truncate:$true -TruncateSuffix "..."
            Write-Host "║$paddedSrc║" -ForegroundColor DarkMagenta
            
            $sizeText = "    Size:   $sourceSizeStr"
            $paddedSize = Pad-AnsiString -Text $sizeText -Width 80 -Align Left
            Write-Host "║$paddedSize║" -ForegroundColor DarkMagenta
            
            Write-Host "╟$Divider╢" -ForegroundColor DarkMagenta

            foreach ($out in $job.Outputs) {
                # Skip failed generation outputs to avoid displaying 0 B / 0.00%
                if ($out.Status -eq 'Failed') {
                    continue
                }
                $outSizeStr = Format-MGBytes -Bytes $out.Size
                $ratio = ($out.Size / $job.SourceSize) * 100
                $color = if ($ratio -lt 50) { 'green' } elseif ($ratio -lt 100) { 'yellow' } else { 'red' }
                
                $lineRaw = "    ▪ {0,-10} | {1,-10} | {2,-12} | {3:N2}%" -f $out.Format, $out.Range, $outSizeStr, $ratio
                $formattedLine = ctstr "{ct:${color}:$lineRaw}"
                $paddedOut = Pad-AnsiString -Text $formattedLine -Width 80 -Align Left
                Write-Host "║$paddedOut║" -ForegroundColor DarkMagenta
            }
            Write-Host "╟$Divider╢" -ForegroundColor DarkMagenta
        }

        $totalTime = "{0:N2}s" -f $Stats.TotalDuration
        $timeText = ctstr "{ct:green:b: ▶ Total Execution Time: $totalTime}"
        $paddedTime = Pad-AnsiString -Text $timeText -Width 80 -Align Left
        Write-Host "║$paddedTime║" -ForegroundColor DarkMagenta
        Write-Host "╚$HBorder╝" -ForegroundColor DarkMagenta
        Write-Host ""
    }
}

# Alias for backward compat or ease of use
if (-not (Get-Command ctstr -ErrorAction SilentlyContinue)) {
    function ctstr { param($s) return New-CTString $s }
}
