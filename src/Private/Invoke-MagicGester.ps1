function Invoke-MagicGester {
    <#
    .SYNOPSIS
        Executes the MagicGester asset generation pipeline based on a configuration.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('mginv')]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'Default')]
        [PSObject]$Config,

        [Parameter(ParameterSetName = 'Default')]
        [switch]$ZipBundle,

        [Parameter(Mandatory = $true, ParameterSetName = 'Help')]
        [switch]$Help
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Help') {
            Show-MGTuiHelp -CmdletName 'Invoke-MagicGester'
            return
        }

        $global:__logging = $true
        Get-MGBanner
        Write-LazyLog -Level inf -Title "MagicGester" -Message "Initializing Pipeline..."
        
        if ($null -eq $Config) {
            $Config = Get-MGLocalConfig
            if ($null -eq $Config) {
                Write-LazyLog -Level err -Title "Config" -Message "No configuration provided or found."
                throw "Pipeline aborted: missing configuration."
            }
        }
        
        $env = Get-MGEnvironment
        if ($env.Status -ne 'Ready' -and -not $env.Details['Magick'].Found) {
            Write-LazyLog -Level err -Title "EnvCheck" -Message "Critical dependencies missing (Magick is required)."
            throw "Pipeline aborted."
        }

        $inkscape = $env.Details['Inkscape'].Path
        $magick   = $env.Details['Magick'].Path
        
        $stats = @{
            StartTime = [DateTime]::Now
            Jobs      = @()
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Help') { return }

        $isParallelSupported = (Get-Command ForEach-Object).Parameters.ContainsKey('Parallel')

        foreach ($job in $Config.Jobs) {
            Write-LazyLog -Level inf -Title "Job" -Message "Processing: $($job.Name)"
            $sourceSize = (Get-Item $job.SourceFile).Length
            
            $jobStats = @{
                Name       = $job.Name
                Source     = $job.SourceFile
                SourceSize = $sourceSize
                Outputs    = @()
            }

            # Gather all tasks for this job
            $tasks = [System.Collections.Generic.List[PSCustomObject]]::new()
            $outputKeys = if ($job.Outputs -is [System.Collections.IDictionary]) {
                $job.Outputs.Keys
            } else {
                $job.Outputs.psobject.Properties | ForEach-Object { $_.Name }
            }

            foreach ($format in $outputKeys) {
                $ranges = if ($job.Outputs -is [System.Collections.IDictionary]) {
                    $job.Outputs[$format]
                } else {
                    $job.Outputs.$format
                }
                $formatDir = Join-Path $Config.Metadata.OutputDir $format
                
                if (-not [System.IO.Directory]::Exists($formatDir)) {
                    [System.IO.Directory]::CreateDirectory($formatDir) | Out-Null
                }

                foreach ($range in $ranges) {
                    $outputPath = Join-Path $formatDir "$($job.Name)-$range.$format"
                    [void]$tasks.Add([PSCustomObject]@{
                        Format     = $format
                        Range      = $range
                        OutputPath = $outputPath
                    })
                }
            }

            # Process tasks in parallel if supported, otherwise sequentially
            $results = if ($isParallelSupported) {
                $tasks | ForEach-Object -ThrottleLimit 4 -Parallel {
                    $task = $_
                    $jobSourceFile = $using:job.SourceFile
                    $inkscape = $using:inkscape
                    $magick = $using:magick

                    $runProc = {
                        param($exe, $argsList)
                        $psi = [System.Diagnostics.ProcessStartInfo]::new()
                        $psi.FileName = $exe
                        foreach ($a in $argsList) { [void]$psi.ArgumentList.Add($a) }
                        $psi.UseShellExecute = $false
                        $psi.CreateNoWindow = $true
                        $psi.RedirectStandardOutput = $true
                        $psi.RedirectStandardError = $true
                        $proc = [System.Diagnostics.Process]::Start($psi)
                        $proc.WaitForExit()
                        return [PSCustomObject]@{
                            ExitCode = $proc.ExitCode
                            Error = $proc.StandardError.ReadToEnd()
                        }
                    }

                    $outStat = @{
                        Range    = $task.Range
                        Format   = $task.Format
                        Path     = $task.OutputPath
                        Status   = 'Success'
                        Size     = 0
                        Duration = 0
                        Error    = $null
                    }

                    try {
                        $timer = [System.Diagnostics.Stopwatch]::StartNew()
                        
                        if ($task.Range -eq 'original') {
                            [System.IO.File]::Copy($jobSourceFile, $task.OutputPath, $true)
                        } else {
                            if ($task.Format -eq 'svg') {
                                [System.IO.File]::Copy($jobSourceFile, $task.OutputPath, $true)
                            } elseif ($task.Format -eq 'png') {
                                if ($inkscape) {
                                    $width, $height = $task.Range -split 'x'
                                    $res = &$runProc $inkscape @("--export-width=$width", "--export-height=$height", "--export-filename=$($task.OutputPath)", $jobSourceFile)
                                    if ($res.ExitCode -ne 0) { throw "Inkscape failed: $($res.Error)" }
                                } else {
                                    $res = &$runProc $magick @("-background", "none", "-size", $task.Range, $jobSourceFile, $task.OutputPath)
                                    if ($res.ExitCode -ne 0) { throw "Magick failed: $($res.Error)" }
                                }
                            } else {
                                $tempPng = [System.IO.Path]::GetTempFileName() + ".png"
                                try {
                                    if ($inkscape) {
                                        $width, $height = $task.Range -split 'x'
                                        $res = &$runProc $inkscape @("--export-width=$width", "--export-height=$height", "--export-filename=$tempPng", $jobSourceFile)
                                        if ($res.ExitCode -ne 0) { throw "Inkscape failed: $($res.Error)" }
                                    } else {
                                        $res = &$runProc $magick @("-background", "none", "-size", $task.Range, $jobSourceFile, $tempPng)
                                        if ($res.ExitCode -ne 0) { throw "Magick failed: $($res.Error)" }
                                    }
                                    
                                    $res = &$runProc $magick @($tempPng, $task.OutputPath)
                                    if ($res.ExitCode -ne 0) { throw "Magick conversion failed: $($res.Error)" }
                                } finally {
                                    if ([System.IO.File]::Exists($tempPng)) {
                                        [System.IO.File]::Delete($tempPng)
                                    }
                                }
                            }
                        }
                        
                        $timer.Stop()
                        
                        if ([System.IO.File]::Exists($task.OutputPath)) {
                            $outStat.Size = [System.IO.FileInfo]::new($task.OutputPath).Length
                            $outStat.Duration = $timer.Elapsed.TotalSeconds
                        } else {
                            throw "Output file not found after generation."
                        }
                    } catch {
                        $outStat.Status = 'Failed'
                        $outStat.Error = $_.Exception.Message
                    }

                    [PSCustomObject]$outStat
                }
            } else {
                $tasks | ForEach-Object {
                    $task = $_
                    $jobSourceFile = $job.SourceFile
                    $inkscape = $inkscape
                    $magick = $magick

                    $runProc = {
                        param($exe, $argsList)
                        $psi = [System.Diagnostics.ProcessStartInfo]::new()
                        $psi.FileName = $exe
                        foreach ($a in $argsList) { [void]$psi.ArgumentList.Add($a) }
                        $psi.UseShellExecute = $false
                        $psi.CreateNoWindow = $true
                        $psi.RedirectStandardOutput = $true
                        $psi.RedirectStandardError = $true
                        $proc = [System.Diagnostics.Process]::Start($psi)
                        $proc.WaitForExit()
                        return [PSCustomObject]@{
                            ExitCode = $proc.ExitCode
                            Error = $proc.StandardError.ReadToEnd()
                        }
                    }

                    $outStat = @{
                        Range    = $task.Range
                        Format   = $task.Format
                        Path     = $task.OutputPath
                        Status   = 'Success'
                        Size     = 0
                        Duration = 0
                        Error    = $null
                    }

                    try {
                        $timer = [System.Diagnostics.Stopwatch]::StartNew()
                        
                        if ($task.Range -eq 'original') {
                            [System.IO.File]::Copy($jobSourceFile, $task.OutputPath, $true)
                        } else {
                            if ($task.Format -eq 'svg') {
                                [System.IO.File]::Copy($jobSourceFile, $task.OutputPath, $true)
                            } elseif ($task.Format -eq 'png') {
                                if ($inkscape) {
                                    $width, $height = $task.Range -split 'x'
                                    $res = &$runProc $inkscape @("--export-width=$width", "--export-height=$height", "--export-filename=$($task.OutputPath)", $jobSourceFile)
                                    if ($res.ExitCode -ne 0) { throw "Inkscape failed: $($res.Error)" }
                                } else {
                                    $res = &$runProc $magick @("-background", "none", "-size", $task.Range, $jobSourceFile, $task.OutputPath)
                                    if ($res.ExitCode -ne 0) { throw "Magick failed: $($res.Error)" }
                                }
                            } else {
                                $tempPng = [System.IO.Path]::GetTempFileName() + ".png"
                                try {
                                    if ($inkscape) {
                                        $width, $height = $task.Range -split 'x'
                                        $res = &$runProc $inkscape @("--export-width=$width", "--export-height=$height", "--export-filename=$tempPng", $jobSourceFile)
                                        if ($res.ExitCode -ne 0) { throw "Inkscape failed: $($res.Error)" }
                                    } else {
                                        $res = &$runProc $magick @("-background", "none", "-size", $task.Range, $jobSourceFile, $tempPng)
                                        if ($res.ExitCode -ne 0) { throw "Magick failed: $($res.Error)" }
                                    }
                                    
                                    $res = &$runProc $magick @($tempPng, $task.OutputPath)
                                    if ($res.ExitCode -ne 0) { throw "Magick conversion failed: $($res.Error)" }
                                } finally {
                                    if ([System.IO.File]::Exists($tempPng)) {
                                        [System.IO.File]::Delete($tempPng)
                                    }
                                }
                            }
                        }
                        
                        $timer.Stop()
                        
                        if ([System.IO.File]::Exists($task.OutputPath)) {
                            $outStat.Size = [System.IO.FileInfo]::new($task.OutputPath).Length
                            $outStat.Duration = $timer.Elapsed.TotalSeconds
                        } else {
                            throw "Output file not found after generation."
                        }
                    } catch {
                        $outStat.Status = 'Failed'
                        $outStat.Error = $_.Exception.Message
                    }

                    [PSCustomObject]$outStat
                }
            }

            # Collect results in main thread
            foreach ($res in $results) {
                $outStat = @{
                    Range    = $res.Range
                    Format   = $res.Format
                    Path     = $res.Path
                    Status   = $res.Status
                    Size     = $res.Size
                    Duration = $res.Duration
                }
                
                if ($res.Status -eq 'Success') {
                    Write-LazyLog -Level suc -Title "Success" -Message "Generated: $([System.IO.Path]::GetFileName($res.Path)) [$($res.Size) bytes]"
                } else {
                    $outStat.Error = $res.Error
                    Write-LazyLog -Level err -Title "Failure" -Message "Export failed for $($job.Name) [$($res.Range)]: $($res.Error)"
                }
                
                $jobStats.Outputs += $outStat
            }

            $stats.Jobs += $jobStats
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -eq 'Help') { return }

        $stats.EndTime = [DateTime]::Now
        $stats.TotalDuration = ($stats.EndTime - $stats.StartTime).TotalSeconds
        
        Write-LazyLog -Level suc -Title "Complete" -Message "Pipeline finished in $($stats.TotalDuration)s."
        
        if ($ZipBundle) {
            $version = (Get-Module mystro).Version
            if (-not $version) { $version = "0.2.0" }
            $zipPath = Join-Path $Config.Metadata.OutputDir "bundle-$($version).zip"
            Write-LazyLog -Level act -Title "Bundle" -Message "Creating ZIP archive: $([System.IO.Path]::GetFileName($zipPath))"
            
            if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
            
            try {
                Compress-Archive -Path "$($Config.Metadata.OutputDir)/*" -DestinationPath $zipPath -Force
                Write-LazyLog -Level suc -Title "Bundle" -Message "ZIP archive created successfully."
                $stats['BundlePath'] = $zipPath
            } catch {
                Write-LazyLog -Level err -Title "Bundle" -Message "Failed to create ZIP: $($_.Exception.Message)"
            }
        }

        if (Get-Command Show-MGCompletionReport -ErrorAction SilentlyContinue) {
            Show-MGCompletionReport -Stats $stats
        }

        return $stats
    }
}
