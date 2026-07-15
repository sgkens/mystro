function Get-InkscapeVersion {
    $path = Get-Command inkscape -ErrorAction SilentlyContinue
    if (-not $path) { $path = Get-Command inkscape.exe -ErrorAction SilentlyContinue }
    if ($path) {
        try {
            $ver = & $path.Source --version 2>&1 | Out-String
            if ($ver -match 'Inkscape\s+([^\s\(\)]+)') {
                return $Matches[1]
            }
            return "Found"
        } catch {
            return "Error retrieving version"
        }
    }
    return "not found"
}

function Get-ImageMagickVersion {
    $path = Get-Command magick -ErrorAction SilentlyContinue
    if (-not $path) { $path = Get-Command magick.exe -ErrorAction SilentlyContinue }
    if ($path) {
        try {
            $verText = & $path.Source --version 2>&1 | Out-String
            if ($verText -match 'ImageMagick\s+([^\s]+)') {
                return $Matches[1]
            }
            return "Found"
        } catch {
            return "Error retrieving version"
        }
    }
    return "not found"
}

function Show-MGAbout {
    <#
    .SYNOPSIS
        Displays the system, module, and dependency versions for Mystro / MagicGester.
    #>
    [CmdletBinding()]
    param()

    process {
        # Check module version
        $modVersion = "0.2.0"
        $mod = Get-Module mystro
        if ($null -eq $mod) { $mod = Get-Module magicgester }
        if ($null -ne $mod) { $modVersion = $mod.Version.ToString() }

        # Check dependencies
        $psVersion = $PSVersionTable.PSVersion.ToString()
        $inkscapeVersion = Get-InkscapeVersion
        $magickVersion = Get-ImageMagickVersion

        # Check python and sub-dependencies
        $pythonVersion = "not found"
        $pipVersion = "not found"
        $tinycssVersion = "not found"
        $pillowVersion = "not found"

        $sysPython = Get-Command /usr/bin/python3 -ErrorAction SilentlyContinue
        if ($null -eq $sysPython) { $sysPython = Get-Command python3 -ErrorAction SilentlyContinue }
        if ($null -eq $sysPython) { $sysPython = Get-Command python -ErrorAction SilentlyContinue }

        if ($sysPython) {
            try {
                $cmd = 'import sys, pip, tinycss2, PIL; print(sys.version.split()[0]); print(pip.__version__); print(tinycss2.__version__); print(PIL.__version__)'
                $out = & $sysPython.Source -c $cmd 2>&1
                if ($out.Count -ge 4) {
                    $pythonVersion = $out[0].ToString().Trim()
                    $pipVersion = $out[1].ToString().Trim()
                    $tinycssVersion = $out[2].ToString().Trim()
                    $pillowVersion = $out[3].ToString().Trim()
                } else {
                    # Fallback individual imports
                    try {
                        $pythonVersion = (& $sysPython.Source -c "import sys; print(sys.version.split()[0])" 2>&1).ToString().Trim()
                    } catch {}
                    try {
                        $pipVersion = (& $sysPython.Source -c "import pip; print(pip.__version__)" 2>&1).ToString().Trim()
                    } catch {}
                    try {
                        $tinycssVersion = (& $sysPython.Source -c "import tinycss2; print(tinycss2.__version__)" 2>&1).ToString().Trim()
                    } catch {}
                    try {
                        $pillowVersion = (& $sysPython.Source -c "import PIL; print(PIL.__version__)" 2>&1).ToString().Trim()
                    } catch {}
                }
            } catch {
                # Ignore and use defaults
            }
        }

        # Draw a beautiful retro-modern box
        $HBorder = "═" * 80
        $Divider = "─" * 80

        Write-Host ""
        Write-Host "╔$HBorder╗" -ForegroundColor DarkMagenta
        
        $titleRaw = "  ABOUT MYSTRO / MAGICGESTER"
        $paddedTitle = Pad-AnsiString -Text (ctstr "{ct:yellow:b:$titleRaw}") -Width 80 -Align Left
        Write-Host "║$paddedTitle║" -ForegroundColor DarkMagenta
        Write-Host "╠$HBorder╣" -ForegroundColor DarkMagenta

        $desc = " MagicGester is a high-performance asset generation and management engine"
        $paddedDesc = Pad-AnsiString -Text $desc -Width 80 -Align Left
        Write-Host "║$paddedDesc║" -ForegroundColor DarkMagenta

        $desc2 = " designed for automated SVG-to-multi-format asset pipelines."
        $paddedDesc2 = Pad-AnsiString -Text $desc2 -Width 80 -Align Left
        Write-Host "║$paddedDesc2║" -ForegroundColor DarkMagenta

        Write-Host "╟$Divider╢" -ForegroundColor DarkMagenta

        # Print versions in a clean table format
        $rows = @(
            @{ Name = "Mystro Module Version"; Value = $modVersion }
            @{ Name = "PowerShell Version";   Value = $psVersion }
            @{ Name = "Inkscape Version";     Value = $inkscapeVersion }
            @{ Name = "ImageMagick Version";  Value = $magickVersion }
            @{ Name = "Python Version";       Value = $pythonVersion }
            @{ Name = "Pip Version";          Value = $pipVersion }
            @{ Name = "TinyCSS2 Version";     Value = $tinycssVersion }
            @{ Name = "Pillow Version";       Value = $pillowVersion }
        )

        foreach ($row in $rows) {
            $valColor = if ($row.Value -eq 'not found' -or $row.Value -like 'Error*') { 'red' } else { 'green' }
            $lineRaw = "    ◆ {0,-25} : {1}" -f $row.Name, $row.Value
            $formattedLine = ctstr "{ct:${valColor}:$lineRaw}"
            $paddedLine = Pad-AnsiString -Text $formattedLine -Width 80 -Align Left
            Write-Host "║$paddedLine║" -ForegroundColor DarkMagenta
        }

        Write-Host "╚$HBorder╝" -ForegroundColor DarkMagenta
        Write-Host ""
    }
}
