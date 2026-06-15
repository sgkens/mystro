# MagicGester Root Module Loader
# ---------------------------------------------------------------------------
using module src\phwriter\phwriter.psm1
# ---------------------------------------------------------------------------

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src  = Join-Path $root "src"

# Directories to search
$dirs = @("Public", "Private", "Helpers", "Classes", "UI")

foreach ($dir in $dirs) {
    $path = Join-Path $src $dir
    if ([System.IO.Directory]::Exists($path)) {
        # Dot-source all .ps1 files
        [System.IO.Directory]::GetFiles($path, "*.ps1", [System.IO.SearchOption]::AllDirectories) | ForEach-Object {
            try {
                . $_
            } catch {
                Write-Error "Failed to load: $_. Error: $($_.Exception.Message)"
            }
        }
    }
}

# ---------------------------------------------------------------------------
# EXPORT CONTROL
# ---------------------------------------------------------------------------

$publicPath = Join-Path $src "Public"
$publicFunctions = @()

if ([System.IO.Directory]::Exists($publicPath)) {
    $publicFunctions = [System.IO.Directory]::GetFiles($publicPath, "*.ps1") | ForEach-Object {
        [System.IO.Path]::GetFileNameWithoutExtension($_)
    }
}

# Explicitly export only Public functions
Export-ModuleMember -Function $publicFunctions -Alias *
