function Invoke-MGImageProcessor {
    <#
    .SYNOPSIS
        Performs generic image resizing, compression, and optimization.

    .DESCRIPTION
        Utilizes ImageMagick to process raster images (PNG, JPG, WebP, etc.).
        Supports target dimensions and quality optimization.

    .PARAMETER Source
        The path to the source image file.

    .PARAMETER OutputDir
        The directory where processed assets will be stored.

    .PARAMETER Range
        The target resolution (e.g., '32x32', '1024x1024').

    .PARAMETER Quality
        Compression quality (1-100), default is 85.

    .PARAMETER Format
        Target output format. If omitted, uses the source format.

    .EXAMPLE
        Invoke-MGImageProcessor -Source "photo.jpg" -OutputDir "./dist" -Range "800x600" -Quality 75
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('mgproc')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Default')]
        [string]$Source,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Default')]
        [string]$OutputDir,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Range,

        [Parameter(ParameterSetName = 'Default')]
        [int]$Quality = 85,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Format,

        [Parameter(Mandatory = $true, ParameterSetName = 'Help')]
        [switch]$Help
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Help') {
            Show-MGTuiHelp -CmdletName 'Invoke-MGImageProcessor'
            return
        }

        $env = Get-MGEnvironment
        $magick = $env.Details['Magick'].Path

        if (-not $magick) {
            Write-LazyLog -Level err -Title "Magick" -Message "ImageMagick not found."
            return
        }

        if (-not [System.IO.File]::Exists($Source)) {
            Write-LazyLog -Level err -Title "File" -Message "Source file '$Source' not found."
            return
        }

        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($Source)
        $sourceExt = [System.IO.Path]::GetExtension($Source).TrimStart('.')
        $targetFormat = if ($Format) { $Format } else { $sourceExt }
        
        $rangeSuffix = if ($Range) { "-$Range" } else { "" }
        $outputPath = Join-Path $OutputDir "$fileName$rangeSuffix.$targetFormat"

        if (-not [System.IO.Directory]::Exists($OutputDir)) {
            [System.IO.Directory]::CreateDirectory($OutputDir) | Out-Null
        }

        try {
            $timer = [System.Diagnostics.Stopwatch]::StartNew()
            
            $cmdArgs = @()
            $cmdArgs += $Source
            
            if ($Range) {
                $cmdArgs += "-resize"
                $cmdArgs += $Range
            }
            
            $cmdArgs += "-quality"
            $cmdArgs += $Quality
            
            $cmdArgs += $outputPath

            & $magick @cmdArgs
            
            $timer.Stop()
            
            if (Test-Path $outputPath) {
                $size = (Get-Item $outputPath).Length
                Write-LazyLog -Level suc -Title "Success" -Message "Processed: $([System.IO.Path]::GetFileName($outputPath)) [$($size) bytes] in $($timer.Elapsed.TotalSeconds)s"
                return [PSCustomObject]@{
                    Source   = $Source
                    Target   = $outputPath
                    Size     = $size
                    Duration = $timer.Elapsed.TotalSeconds
                }
            } else {
                throw "Output file generation failed."
            }
        }
        catch {
            Write-LazyLog -Level err -Title "Failure" -Message "Processing failed for $Source: $($_.Exception.Message)"
        }
    }
}
