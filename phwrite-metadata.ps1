# ==============================================================================
# File: phwriter-metadata.ps1 (MagicGester V2)
# ==============================================================================
$source = "https://gitlab.kenscloud.online/phallems/glvigor.git"
$phwriter_metadata_array = @(
    @{
        commandinfo = @{
            cmdlet      = "New-MGConfig"
            synopsis    = "New-MGConfig -Source <String> -OutputDir <String> [-Formats <String[]>] [-AutoScale] [-AsJson]"
            description = "Generates a structured configuration dataset for MagicGester asset pipelines, defining source assets and target variant ranges."
            source      = $source
        }
        paramtable  = @(
            @{ name = "Source"; param = "Source"; type = "string"; required = $true; description = "Path to source SVG file or directory."; inline = $false },
            @{ name = "OutputDir"; param = "OutputDir"; type = "string"; required = $true; description = "Root directory for generated assets."; inline = $false },
            @{ name = "Formats"; param = "Formats"; type = "string[]"; required = $false; description = "Target formats (png, ico, webp, jpg, svg)."; inline = $false },
            @{ name = "PngRanges"; param = "PngRanges"; type = "string[]"; required = $false; description = "Custom dimensions for PNG (e.g. '32x32')."; inline = $false },
            @{ name = "AutoScale"; param = "AutoScale"; type = "switch"; required = $false; description = "Automatically calculate resolutions based on aspect ratio."; inline = $true },
            @{ name = "Help"; param = "Help"; type = "switch"; required = $false; description = "Display this help information."; inline = $true }
        )
        examples    = @(
            "New-MGConfig -Source './logo.svg' -OutputDir './dist' -AutoScale",
            "mgconf -Source './assets' -OutputDir './dist' -Formats png,ico"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "Invoke-MagicGester"
            synopsis    = "Invoke-MagicGester -Config <PSObject> [-ZipBundle]"
            description = "Executes the high-performance asset transformation pipeline using Inkscape and ImageMagick fallbacks."
            source      = $source
        }
        paramtable  = @(
            @{ name = "Config"; param = "Config"; type = "PSObject"; required = $true; description = "The MagicGester.Config object defining the pipeline jobs."; inline = $false },
            @{ name = "ZipBundle"; param = "ZipBundle"; type = "switch"; required = $false; description = "Automatically aggregate all generated assets into a ZIP archive."; inline = $true },
            @{ name = "Help"; param = "Help"; type = "switch"; required = $false; description = "Display this help information."; inline = $true }
        )
        examples    = @(
            "New-MGConfig -Source 'logo.svg' -OutputDir './dist' | Invoke-MagicGester",
            "mginv -Config $myConfig"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "Get-MGImageInfo"
            synopsis    = "Get-MGImageInfo [-Source] <String>"
            description = "Retrieves detailed structured metadata for an image file using ImageMagick identify."
            source      = $source
        }
        paramtable  = @(
            @{ name = "Source"; param = "Source"; type = "string"; required = $true; description = "Path to the image file to inspect."; inline = $false },
            @{ name = "Help"; param = "Help"; type = "switch"; required = $false; description = "Display this help information."; inline = $true }
        )
        examples    = @(
            "Get-MGImageInfo -Source './dist/png/logo-32x32.png'",
            "mgeri './icon.ico'"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "Show-MGMediaInfo"
            synopsis    = "Show-MGMediaInfo [[-Format] <String>]"
            description = "Displays an elegant TUI report detailing various media formats, their pros, cons, and best use cases."
            source      = $source
        }
        paramtable  = @(
            @{ name = "Format"; param = "Format"; type = "string"; required = $false; description = "Specific format to query (png, webp, svg, etc.)."; inline = $false },
            @{ name = "Help"; param = "Help"; type = "switch"; required = $false; description = "Display this help information."; inline = $true }
        )
        examples    = @(
            "Show-MGMediaInfo",
            "mginfo -Format webp"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "New-MGRelease"
            synopsis    = "New-MGRelease -Config <PSObject> [-Commit] [-ZipBundle] [-Version <String>]"
            description = "CI/CD wrapper that automates pipeline execution, metric recording, and draft release notes generation."
            source      = $source
        }
        paramtable  = @(
            @{ name = "Config"; param = "Config"; type = "PSObject"; required = $true; description = "The pipeline configuration object."; inline = $false },
            @{ name = "Commit"; param = "Commit"; type = "switch"; required = $false; description = "If set, stages and commits generated assets."; inline = $true },
            @{ name = "ZipBundle"; param = "ZipBundle"; type = "switch"; required = $false; description = "Automatically aggregate all generated assets into a ZIP archive."; inline = $true },
            @{ name = "Version"; param = "Version"; type = "string"; required = $false; description = "Version string for release notes."; inline = $false },
            @{ name = "Help"; param = "Help"; type = "switch"; required = $false; description = "Display this help information."; inline = $true }
        )
        examples    = @(
            "New-MGRelease -Config $config -Version '0.2.0'"
        )
    }
)
