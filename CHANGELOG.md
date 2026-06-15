# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-06-16

### Added
*   Added `New-MGConfig` (`mgconf`) for manifest-driven asset generation.
*   Added `Invoke-MagicGester` (`mginv`) as the centralized execution, validation, and telemetry engine.
*   Added `Get-MGSvgDimensions` for precise SVG dimension discovery using .NET XML parsing.
*   Added intelligent `-AutoScale` support with automatic aspect-ratio preservation.
*   Added adaptive renderer selection with automatic Inkscape and ImageMagick fallback support.
*   Added `New-MGRelease` for automated release generation and CI/CD integration.
*   Added `Invoke-MGImageProcessor` for generic image resizing, compression, and optimization.
*   Added branded TUI components including `Get-MGBanner` and `Show-MGCompletionReport`.
*   Added optimization telemetry and asset size reduction reporting.
*   Added universal `-Help` support across all public cmdlets.
*   Added dedicated Help parameter sets that allow documentation access without mandatory parameter validation.
*   Added `Show-MGTuiHelp` for PHWriter-powered terminal help rendering.
*   Added centralized `phwrite-metadata.ps1` documentation manifest.
*   Added automated `-ZipBundle` support for creating versioned distribution archives.
*   Added roadmap and architectural milestone documentation.

### Changed
*   Refactored the module into a fully manifest-driven execution pipeline.
*   Reorganized source layout into `src/Public`, `src/Private`, `src/Helpers`, and `src/UI`.
*   Enhanced `New-MGConfig` with intelligent defaults and advanced batch-processing support.
*   Improved execution performance through configuration-based orchestration.
*   Standardized logging, ANSI rendering, gradients, and key-value display utilities.
*   Upgraded README with Quick Start, Advanced Pipeline, and API Reference documentation.
*   Standardized module manifest metadata and PSData definitions.
*   Integrated Phellams multi-stage GitLab CI/CD templates.
*   Added standardized `build_config.json` build orchestration.
*   Improved telemetry collection, reporting accuracy, and deployment readiness.

### Fixed
*   Resolved variable naming collisions within private utility modules.
*   Fixed utility-layer syntax and execution issues.
*   Improved cross-platform compatibility and runtime stability.
*   Hardened dependency validation and error handling.
*   Corrected rendering fallback behavior across diverse environments.
*   Validated completion reporting, intelligent scaling, release packaging, and CI/CD workflows for production use.
*   Fixed PHWriter variable interpolation for UI components.
