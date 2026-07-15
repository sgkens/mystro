<div align="center">
    <img src="https://gitlab.kenscloud.online/phallems/glvigor/-/blob/main/logo.svg" alt="MagicGester Logo" width="128">
    <h1><strong>Mystro</strong></h1>
    <p><b>Asset Generation & Management Engine</b></p>
    <p>
        <a href="https://gitlab.kenscloud.online/phallems/glvigor/-/pipelines"><img src="https://gitlab.kenscloud.online/phallems/glvigor/badges/main/pipeline.svg" alt="Pipeline Status"></a>
        <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"></a>
        <a href="https://gitlab.kenscloud.online/phallems/glvigor"><img src="https://img.shields.io/badge/version-0.2.0-blue.svg" alt="Version"></a>
    </p>
    <hr>
    <p>A <b>PowerShell</b> module for automated SVG-to-multi-format asset pipelines.</p>
    <p>🚨 <strong>Requirements:</strong> ImageMagick (Required), Inkscape (Recommended for Vector fidelity), Python 3 + pip + tinycss2 + Pillow (Required for Inkscape raster export extensions).</p>
    <small>Available on <strong>Linux</strong> , <strong>Windows</strong>, and <strong>macOS</strong></small>
    <br>
    <span>
        <a href="https://gitlab.kenscloud.online/phallems/glvigor"><b>GitLab</b></a> |
        <a href="#api-reference"><b>API Reference</b></a> |
        <a href="CHANGELOG.md"><b>Changelog</b></a>
    </span>
    <hr>
</div>

## **Core Features**

- **Object-Oriented Pipeline:** Decoupled configuration engine (`New-MGConfig`) for high-speed batch processing.
- **Intelligent Auto-Scaling:** Aspect-ratio preservation and automatic target resolution discovery.
- **Unified Execution:** Robust transformation engine (`Invoke-MagicGester`) with intelligent dependency fallbacks.
- **Retro-Modern TUI:** Handcrafted ANSI-driven feedback, real-time logging, and visual optimization reports.
- **Telemetry-Rich:** Detailed metrics on source/target sizes and execution performance.
- **CI/CD Ready:** Dedicated automation wrappers for seamless integration into production DevOps workflows.

## **Quick Start**

### 1. Installation
```powershell
# Clone the repository
git clone https://gitlab.kenscloud.online/phallems/glvigor.git magicgester
cd magicgester

# Import the module
Import-Module ./magicgester.psd1 -Force
```

### 2. Basic Usage
Generate multiple PNG and WebP variants from a single SVG source with auto-scaling:

```powershell
mystro config -Source "./assets/logo.svg" -OutputDir "./dist" -AutoScale | mystro Gen
```

## **API Reference**

### *💲Invoke-Mystro* (Alias: `mystro`)

The central routing interface for MagicGester asset generation. Supports multiple operational modes to encapsulate the toolkit's functionality.

**🔹Syntax:**

```powershell
Invoke-Mystro [-Mode] <String> [[-Config] <PSObject>] [-Source <String>] 
              [-OutputDir <String>] [-Format <String>] [-Formats <String[]>] 
              [-PngRanges <String[]>] [-IcoRanges <String[]>] [-WebpRanges <String[]>] 
              [-JpgRanges <String[]>] [-SvgRanges <String[]>] [-AutoScale] 
              [-AsJson] [-SaveLocal] [-ZipBundle] [-Commit] [-Version <String>] 
              [-Range <String>] [-Quality <Int32>] [-Help] [<CommonParameters>]
```

**🔹Parameters**

| **Parameter** | **Type** | **Required** | **Default** | **Validation** | **Description** |
| --- | --- | --- | --- | --- | --- |
| `Mode` | `String` | True | None | `help, Gen, release, minfo, config, MGI, about, edit, view` | The operational mode to execute. |
| `Config` | `PSObject` | False | None | None | Pipeline configuration object (required for `Gen` and `release`). |
| `Source` | `String` | False | None | None | Path to the source file or directory. |
| `OutputDir` | `String` | False | None | None | Destination directory for generated or processed assets. |
| `Formats` | `String[]` | False | `@('png', 'ico', 'webp')` | None | Array of target formats to generate in `config` mode. |
| `AutoScale` | `Switch` | False | False | None | Automatically calculate scaling ranges while preserving aspect ratio. |
| `SaveLocal` | `Switch` | False | False | None | Saves the generated configuration JSON to `~/.phellams/mystro/config.json`. |
| `ZipBundle` | `Switch` | False | False | None | Aggregates all generated outputs into a single, versioned ZIP archive. |
| `Quality` | `Int32` | False | `85` | `1-100` | Target quality for raster compression in `MGI` mode. |
| `Help` | `Switch` | False | False | None | Triggers the interactive TUI documentation via PHWriter. |

**🔻Outputs**

`System.Management.Automation.PSCustomObject`

**Mode Breakdown:**
- `config`: Generates a structured configuration dataset. (Wraps `New-MGConfig`)
- `Gen`: Executes the high-performance asset transformation pipeline. (Wraps `Invoke-MagicGester`)
- `minfo`: Retrieves file metadata or displays format documentation. (Wraps `Get-MGImageInfo` and `Show-MGMediaInfo`)
- `MGI`: Performs generic image resizing and compression. (Wraps `Invoke-MGImageProcessor`)
- `release`: Automates CI/CD releases and draft notes. (Wraps `New-MGRelease`)
- `about`: Displays a diagnostic view of System, PowerShell, Module, and dependency version mappings. (Wraps `Show-MGAbout`)
- `edit`: Opens the vector source SVG file in the Inkscape GUI editor. (Wraps `Start-MGEditor`)
- `view`: Opens the generated target image in the system's default image viewer. (Wraps `Start-MGViewer`)
- `help`: Displays the PHWriter TUI documentation.

## 📊 Media Information
MagicGester includes a TUI-based information manager to help you choose the best formats for your needs:

```powershell
mystro minfo -Format webp
```

---

## **Releases & Tagging**

This project follows strict **SemVer** versioning. For all releases, use the following workflow:

1. Create a Draft Merge Request (MR) targeting `develop`.
2. Once approved, merge to `develop` and then to `main`.
3. Generate a new version tag using `New-SemverTag.ps1` (Internal Phellams Tooling).

---

## **Support**

- 📝 [Documentation](https://gitlab.kenscloud.online/phallems/glvigor/-/wikis/home)
- 🐛 [Issue Tracker](https://gitlab.kenscloud.online/phallems/glvigor/-/issues)
- 💬 [Discussions](https://gitlab.kenscloud.online/phallems/glvigor/-/issues)

---

## **Contributing**

Contributions are welcome! Please fork the repository and submit a **Merge Request** (MR) targeting the `develop` branch.
