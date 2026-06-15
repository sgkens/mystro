<div align="center">
    <img src="https://gitlab.kenscloud.online/phallems/glvigor/-/blob/main/logo.svg" alt="MagicGester Logo" width="128">
    <h1><strong>MagicGester</strong></h1>
    <p><b>Asset Generation & Management Engine</b></p>
    <p>
        <a href="https://gitlab.kenscloud.online/phallems/glvigor/-/pipelines"><img src="https://gitlab.kenscloud.online/phallems/glvigor/badges/main/pipeline.svg" alt="Pipeline Status"></a>
        <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"></a>
        <a href="https://gitlab.kenscloud.online/phallems/glvigor"><img src="https://img.shields.io/badge/version-0.2.0-blue.svg" alt="Version"></a>
    </p>
    <hr>
    <p>A <b>PowerShell</b> module for automated SVG-to-multi-format asset pipelines.</p>
    <p>🚨 <strong>Requirements:</strong> ImageMagick (Required), Inkscape (Recommended for Vector fidelity).</p>
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
$config = New-MGConfig -Source "./assets/logo.svg" -OutputDir "./dist" -AutoScale
$config | Invoke-MagicGester
```

## **API Reference**

### `New-MGConfig` (`mgconf`)
Generates a structured configuration dataset for MagicGester asset pipelines.
- **Parameters:**
  - `-Source`: Path to source SVG or directory.
  - `-OutputDir`: Root directory for outputs.
  - `-Formats`: Target formats (default: png, ico, webp).
  - `-AutoScale`: Automatically calculate resolutions while preserving aspect ratio.

### `Invoke-MagicGester` (`mginv`)
Executes the asset generation pipeline based on a configuration object.
- **Parameters:**
  - `-Config`: The config object (Accepts pipeline input).

### `Get-MGImageInfo` (`mgeri`)
Retrieves detailed metadata about an image file using ImageMagick.

### `Show-MGMediaInfo` (`mginfo`)
Displays TUI information about media formats and best use cases.

### `New-MGRelease` (`mgls`)
Automates the release process for CI/CD, including draft release notes.

## 📊 Media Information
MagicGester includes a TUI-based information manager to help you choose the best formats for your needs:

```powershell
Show-MGMediaInfo -Format webp
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
