# ==============================================================================
# File: phwriter-metadata.ps1 (MagicGester V2)
# ==============================================================================
$source = "https://gitlab.com/phallems/mystro.git"
$phwriter_metadata_array = @(
    @{
        commandinfo = @{
            cmdlet      = "mystro (Invoke-Mystro)"
            synopsis    = "mystro -Mode <String> [Options]"
            description = "The central routing interface for MagicGester asset generation, offering 'config', 'Gen', 'release', 'minfo', and 'MGI' modes."
            source      = $source
        }
        paramtable  = @(
            @{ name = "Mode"; param = "Mode"; type = "string"; required = $true; description = "The operational mode: config, Gen, release, minfo, MGI, help."; inline = $false },
            @{ name = "Config"; param = "Config"; type = "PSObject"; required = $false; description = "Pipeline configuration object (for Gen/release)."; inline = $false },
            @{ name = "Source"; param = "Source"; type = "string"; required = $false; description = "Source file or directory."; inline = $false },
            @{ name = "OutputDir"; param = "OutputDir"; type = "string"; required = $false; description = "Output directory for generated/processed assets."; inline = $false },
            @{ name = "Formats"; param = "Formats"; type = "string[]"; required = $false; description = "Formats to generate (e.g. png, ico)."; inline = $false },
            @{ name = "AutoScale"; param = "AutoScale"; type = "switch"; required = $false; description = "Calculate scaled ranges automatically."; inline = $true },
            @{ name = "SaveLocal"; param = "SaveLocal"; type = "switch"; required = $false; description = "Save config.json to ~/.phellams/mystro/."; inline = $true },
            @{ name = "ZipBundle"; param = "ZipBundle"; type = "switch"; required = $false; description = "Zip all outputs after Gen/release."; inline = $true },
            @{ name = "Help"; param = "Help"; type = "switch"; required = $false; description = "Display this help information."; inline = $true }
        )
        examples    = @(
            "mystro config -Source 'logo.svg' -OutputDir './dist' -AutoScale -SaveLocal",
            "mystro config -Source 'logo.svg' -OutputDir './dist' | mystro Gen",
            "mystro minfo -Format webp",
            "mystro minfo -Source './dist/logo-32x32.png'",
            "mystro MGI -Source 'photo.jpg' -OutputDir './out' -Range '800x600' -Quality 80"
        )
    }
)