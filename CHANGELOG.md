# **CHANGELOG**

## 🧿 v0.7.0

- Resolved race condition between Inkscape exports and ImageMagick conversions using synchronous `.NET` Process execution.
- Implemented parallel asset generation using a robust `.NET` RunspacePool with dynamic progress feedback.
- Added live full-screen TUI dashboard running inside the alternate screen buffer (`\e[?1049h`), with flicker-free cursor-homed redraws.
- Created `New-Spinner` and `New-Bar` helpers utilizing 24-bit TrueColor gradients via the `asciitokenizer` engine.
- Fixed a pipeline array unwrapping/indexing exception in the BFS flood fill tokenizer for single-line inputs.
- Normalized diagnostics check inside `Show-MGAbout` to return lowercase `'not found'` for missing dependencies.
- Updated `build_config.json` module configuration and version telemetry references.

## 🧿 v0.3.0

- Added `edit` and `view` modes to Invoke-Mystro (`mystro`).
  - `mystro edit` opens the vector source SVG file in the Inkscape GUI editor.
  - `mystro view` opens the generated target image in the system's default image viewer.
- Enhanced dependency routing in the pipeline:
  - Non-PNG raster exports (WebP, JPG, ICO) are now routed through a temporary PNG + ImageMagick fallback, bypassing unstable/broken Inkscape Python extensions.
- Added `about` mode versions of Python, Pip, TinyCSS2, and Pillow to show all runtime requirements.
- Standardized visual borders, aligning fonts and layout to prevent terminal screen tearing.
- Replaced double-width emojis with safe single-width unicode block shapes.
- Renamed "High-Performance Asset Engine" to "Mystro Asset Engine".

## 🧿 v0.2.0-alpha

- MagicGester V2 transforms the project from a collection of export scripts into a professional-grade asset 
generation engine.
  - The module now supports zero-touch automation, intelligent scaling, adaptive rendering, automated packaging, 
and CI/CD-ready deployment workflows.
  - All V2 milestones have been completed, validated, and marked as production-ready.
  - Documentation, build systems, manifests, and release workflows have been standardized to Phellams engineering 
standards.

### Feature Additions

- Added `New-MGConfig` (`mgconf`) for manifest-driven asset generation.
- Added `Invoke-MagicGester` (`mginv`) as the centralized execution, validation, and telemetry engine.
- Added `Get-MGSvgDimensions` for precise SVG dimension discovery using .NET XML parsing.
- Added intelligent `-AutoScale` support with automatic aspect-ratio preservation.
- Added adaptive renderer selection with automatic Inkscape and ImageMagick fallback support.
- Added `New-MGRelease` for automated release generation and CI/CD integration.
- Added branded TUI components including `Get-MGBanner` and `Show-MGCompletionReport`.
- Added optimization telemetry and asset size reduction reporting.
- Added universal `-Help` support across all public cmdlets:
  - `New-MGConfig`
  - `Invoke-MagicGester`
  - `Get-MGImageInfo`
  - `Show-MGMediaInfo`
  - `New-MGRelease`
- Added dedicated Help parameter sets that allow documentation access without mandatory parameter validation.
- Added `Show-MGTuiHelp` for PHWriter-powered terminal help rendering.
- Added centralized `phwrite-metadata.ps1` documentation manifest.
- Added automated `-ZipBundle` support for creating versioned distribution archives.
- Added roadmap and architectural milestone documentation.

### Feature Improvements

- Refactored the module into a fully manifest-driven execution pipeline.
- Reorganized source layout into:
  - `src/Public`
  - `src/Private`
  - `src/Helpers`
  - `src/UI`
- Enhanced `New-MGConfig` with intelligent defaults and advanced batch-processing support.
- Improved execution performance through configuration-based orchestration.
- Standardized logging, ANSI rendering, gradients, and key-value display utilities.
- Upgraded README with Quick Start, Advanced Pipeline, and API Reference documentation.
- Standardized module manifest metadata and PSData definitions.
- Integrated Phellams multi-stage GitLab CI/CD templates.
- Added standardized `build_config.json` build orchestration.
- Improved telemetry collection, reporting accuracy, and deployment readiness.
- Finalized pixel-perfect TUI reporting and alignment across supported terminals.

### Breaking Changes

- Export-script-centric workflows have been replaced by the V2 manifest-driven execution model.
- Asset generation workflows now rely on configuration manifests generated through `New-MGConfig`.
- Pipeline execution is centralized through `Invoke-MagicGester`.
- Build, packaging, and release workflows have been aligned with the V2 architecture and Phellams standards.

## 🧿 v0.2.1-b `tag-only`

- Intial concept tag, no release notes, no package