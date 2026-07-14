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

        foreach ($job in $Config.Jobs) {
            Write-LazyLog -Level inf -Title "Job" -Message "Processing: $($job.Name)"
            $sourceSize = (Get-Item $job.SourceFile).Length
            
            $jobStats = @{
                Name    = $job.Name
                Source  = $job.SourceFile
                SourceSize = $sourceSize
                Outputs = @()
            }

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
                    
                    $outStat = @{
                        Range  = $range
                        Format = $format
                        Path   = $outputPath
                        Status = 'Success'
                        Size   = 0
                        Duration = 0
                    }

                    try {
                        $timer = [System.Diagnostics.Stopwatch]::StartNew()
                        
                        if ($range -eq 'original') {
                            Copy-Item -Path $job.SourceFile -Destination $outputPath -Force
                        } else {
                            if ($format -eq 'svg') {
                                Copy-Item -Path $job.SourceFile -Destination $outputPath -Force
                            } elseif ($format -eq 'png') {
                                if ($inkscape) {
                                    $width, $height = $range -split 'x'
                                    & $inkscape --export-width=$width --export-height=$height --export-filename=$outputPath $job.SourceFile
                                } else {
                                    & $magick -background none -size $range $job.SourceFile $outputPath
                                }
                            } else {
                                # Use temp PNG for webp, jpg, jpeg, ico, etc. to bypass buggy Inkscape extensions
                                $tempPng = [System.IO.Path]::GetTempFileName() + ".png"
                                if ($inkscape) {
                                    $width, $height = $range -split 'x'
                                    & $inkscape --export-width=$width --export-height=$height --export-filename=$tempPng $job.SourceFile
                                } else {
                                    & $magick -background none -size $range $job.SourceFile $tempPng
                                }
                                & $magick $tempPng $outputPath
                                if (Test-Path $tempPng) { Remove-Item $tempPng -Force }
                            }
                        }
                        
                        $timer.Stop()
                        
                        if (Test-Path $outputPath) {
                            $outSize = (Get-Item $outputPath).Length
                            $outStat['Size'] = $outSize
                            $outStat['Duration'] = $timer.Elapsed.TotalSeconds
                            Write-LazyLog -Level suc -Title "Success" -Message "Generated: $([System.IO.Path]::GetFileName($outputPath)) [$($outSize) bytes]"
                        } else {
                            throw "Output file not found after generation."
                        }
                    } catch {
                        $outStat.Status = 'Failed'
                        $outStat['Error'] = $_.Exception.Message
                        Write-LazyLog -Level err -Title "Failure" -Message "Export failed for $($job.Name) [$range]: $($_.Exception.Message)"
                    }
                    $jobStats.Outputs += $outStat
                }
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
            $version = (Get-Module magicgester).Version
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
