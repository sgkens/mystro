function New-MGConfig {
    <#
    .SYNOPSIS
        Generates a structured configuration dataset for MagicGester asset pipelines.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('mgconf')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Default')]
        [string]$Source,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Default')]
        [string]$OutputDir,

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

        [Parameter(Mandatory = $true, ParameterSetName = 'Help')]
        [switch]$Help
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Help') {
            Show-MGTuiHelp -CmdletName 'New-MGConfig'
            return
        }

        $fullSourcePath = [System.IO.Path]::GetFullPath($Source)
        $fullOutputPath = [System.IO.Path]::GetFullPath($OutputDir)

        $config = [PSCustomObject]@{
            PSTypeName = 'MagicGester.Config'
            Metadata   = @{
                CreatedAt = [DateTime]::Now
                Source    = $fullSourcePath
                OutputDir = $fullOutputPath
                AutoScale = $AutoScale
            }
            Jobs       = @()
        }

        # Logic to discover files if source is a directory
        $sources = @()
        if ([System.IO.Directory]::Exists($fullSourcePath)) {
            $sources = [System.IO.Directory]::GetFiles($fullSourcePath, "*.svg")
        } elseif ([System.IO.File]::Exists($fullSourcePath)) {
            $sources = @($fullSourcePath)
        } else {
            throw "Source path '$fullSourcePath' not found."
        }

        # Standard default scale steps
        $defaultSteps = @(16, 32, 48, 64, 128, 256, 512, 1024)

        foreach ($file in $sources) {
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file)
            $dims = Get-MGSvgDimensions -Path $file
            
            $job = @{
                SourceFile = $file
                Name       = $fileName
                Outputs    = @{}
                Dimensions = $dims
            }

            # Helper to generate ranges based on aspect ratio
            function Get-ScaledRanges {
                param($steps, $origDims)
                $results = @()
                if ($null -eq $origDims -or $null -eq $origDims.Width -or $origDims.Width -eq 0) {
                    # Fallback to square if dims unknown
                    return $steps | ForEach-Object { "$($_)x$($_)" }
                }
                $ratio = $origDims.Height / $origDims.Width
                foreach ($s in $steps) {
                    $h = [math]::Round($s * $ratio)
                    $results += "$($s)x$($h)"
                }
                return $results
            }

            $currentPng  = if ($PngRanges)  { $PngRanges  } else { Get-ScaledRanges $defaultSteps $dims }
            $currentIco  = if ($IcoRanges)  { $IcoRanges  } else { @('16x16', '32x32', '48x48', '256x256') }
            $currentWebp = if ($WebpRanges) { $WebpRanges } else { $currentPng }
            $currentJpg  = if ($JpgRanges)  { $JpgRanges  } else { $currentPng }
            $currentSvg  = if ($SvgRanges)  { $SvgRanges  } else { @('original') }

            if ($Formats -contains 'png')  { $job.Outputs['png']  = $currentPng }
            if ($Formats -contains 'ico')  { $job.Outputs['ico']  = $currentIco }
            if ($Formats -contains 'webp') { $job.Outputs['webp'] = $currentWebp }
            if ($Formats -contains 'jpg')  { $job.Outputs['jpg']  = $currentJpg }
            if ($Formats -contains 'svg')  { $job.Outputs['svg']  = $currentSvg }

            $config.Jobs += [PSCustomObject]$job
        }

        if ($AsJson) {
            return $config | ConvertTo-Json -Depth 10
        }

        return $config
    }
}
