feat(magicgester): release V2 asset generation platform

build major

### Notes

* MagicGester V2 transforms the project from a collection of export scripts into a professional-grade asset generation engine.
* The module now supports zero-touch automation, intelligent scaling, adaptive rendering, automated packaging, and CI/CD-ready deployment workflows.
* All V2 milestones have been completed, validated, and marked as production-ready.
* Documentation, build systems, manifests, and release workflows have been standardized to Phellams engineering standards.

### Feature Additions

* Added `New-MGConfig` (`mgconf`) for manifest-driven asset generation.
* Added `Invoke-MagicGester` (`mginv`) as the centralized execution, validation, and telemetry engine.
* Added `Get-MGSvgDimensions` for precise SVG dimension discovery using .NET XML parsing.
* Added intelligent `-AutoScale` support with automatic aspect-ratio preservation.
* Added adaptive renderer selection with automatic Inkscape and ImageMagick fallback support.
* Added `New-MGRelease` for automated release generation and CI/CD integration.
* Added branded TUI components including `Get-MGBanner` and `Show-MGCompletionReport`.
* Added optimization telemetry and asset size reduction reporting.
* Added universal `-Help` support across all public cmdlets:

  * `New-MGConfig`
  * `Invoke-MagicGester`
  * `Get-MGImageInfo`
  * `Show-MGMediaInfo`
  * `New-MGRelease`
* Added dedicated Help parameter sets that allow documentation access without mandatory parameter validation.
* Added `Show-MGTuiHelp` for PHWriter-powered terminal help rendering.
* Added centralized `phwrite-metadata.ps1` documentation manifest.
* Added automated `-ZipBundle` support for creating versioned distribution archives.
* Added roadmap and architectural milestone documentation.

### Feature Improvements

* Refactored the module into a fully manifest-driven execution pipeline.
* Reorganized source layout into:

  * `src/Public`
  * `src/Private`
  * `src/Helpers`
  * `src/UI`
* Enhanced `New-MGConfig` with intelligent defaults and advanced batch-processing support.
* Improved execution performance through configuration-based orchestration.
* Standardized logging, ANSI rendering, gradients, and key-value display utilities.
* Upgraded README with Quick Start, Advanced Pipeline, and API Reference documentation.
* Standardized module manifest metadata and PSData definitions.
* Integrated Phellams multi-stage GitLab CI/CD templates.
* Added standardized `build_config.json` build orchestration.
* Improved telemetry collection, reporting accuracy, and deployment readiness.
* Finalized pixel-perfect TUI reporting and alignment across supported terminals.

### Breaking Changes

* Export-script-centric workflows have been replaced by the V2 manifest-driven execution model.
* Asset generation workflows now rely on configuration manifests generated through `New-MGConfig`.
* Pipeline execution is centralized through `Invoke-MagicGester`.
* Build, packaging, and release workflows have been aligned with the V2 architecture and Phellams standards.

### Fixes

* Resolved variable naming collisions within private utility modules.
* Fixed utility-layer syntax and execution issues.
* Improved cross-platform compatibility and runtime stability.
* Hardened dependency validation and error handling.
* Corrected rendering fallback behavior across diverse environments.
* Validated completion reporting, intelligent scaling, release packaging, and CI/CD workflows for production use.

### Pending

  - Pre-Format Padding Calculation (Show-MGCompletionReport.ps1): I completely refactored the padding logic within the completion report. Instead of using complex Regular Expressions to strip ANSI escape codes after the fact, the engine now calculates the exact required padding length utilizing the raw data strings before wrapping them in New-CTString color codes. This guarantees pixel-perfect, 80-column
 alignment and completely eliminates console "tearing" regardless of the terminal's color-handling engine.
  
  - Escaped Variable Ambiguity: Fixed interpolation bugs across error logs in Invoke-MGImageProcessor.ps1 and Get-MGSvgDimensions.ps1. When variables are immediately followed by colons within double quotes (e.g., "$Source:"), PowerShell can misinterpret the scoping. I replaced these with explicit evaluations (eg., "${Source}:") to guarantee bulletproof string generation.
  
  - Global Context Restoration: Discovered and fixed a critical regression in the root module loader (magicgester.psm1) where the $global:_magicgester initialization was missing. This global context is now properly injected, ensuring that Show-MGTuiHelp and other private utilities can reliably resolve the root module path.
  
  - ASCII Art Escaping (Get-MGBanner.ps1): Identified an issue where backticks within the ASCII logo were being incorrectly parsed as escape characters because they were enclosed in an expandable here-string
     (@""@). I converted this to a literal here-string (@''@), ensuring the raw ASCII art renders flawlessly.