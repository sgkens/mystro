# Knowledge Base: Lessons Learned Building MagicGester (Mystro) V2

## Overview
This document serves as a persistent knowledge base capturing the architectural shifts, technical challenges, and Phellams-standard compliance patterns established during the development of MagicGester V2 (featuring the `mystro` router). This file should be referenced in future Phellams module developments to ensure consistency and prevent regressions.

---

## 1. Architectural Paradigms

### The Central Router Pattern (`Invoke-Mystro`)
- **Concept:** Instead of exposing numerous highly specific cmdlets (`New-MGConfig`, `Invoke-MagicGester`, `Get-MGImageInfo`) to the user, we implemented a single entry point (`mystro`) using a `-Mode` parameter.
- **Benefit:** Dramatically simplifies the public API surface. Users only need to remember one command and its modes, reducing cognitive load.
- **Implementation Details:** 
  - The router (`src/Public/Invoke-Mystro.ps1`) uses `switch ($Mode)` to delegate logic.
  - Legacy public cmdlets were migrated to `src/Private/` and are called internally by the router.
  - Parameter forwarding was achieved by filtering `$PSBoundParameters` (excluding router-specific switches like `Mode` and `Help`) and splatting (`@forwardArgs`) them to the internal functions.

### Strict Encapsulation (Root Module Loader)
- **Concept:** The `magicgester.psm1` file acts strictly as a loader and boundary enforcer.
- **Benefit:** Prevents internal helpers and logic from polluting the global PowerShell session, mitigating "dirty session" bugs.
- **Implementation Details:**
  - The loader dot-sources all `.ps1` files across `Public`, `Private`, `Helpers`, and `UI` directories.
  - It dynamically reads the names of files in `src/Public/` and exclusively passes those to `Export-ModuleMember`.
  - **CRITICAL FIX:** The root loader must inject the `$global:_magicgester = @{ rootpath = $root }` variable. Private UI components (like the help renderer) rely on this to locate metadata files.

---

## 2. Terminal User Interface (TUI) Standards

### The Pre-Format Padding Rule (Zero Screen Tearing)
- **Challenge:** Applying ANSI escape codes (via `New-CTString` or `Write-Color`) before calculating layout padding causes the terminal to count the invisible escape characters as part of the string length. This results in misaligned borders and "screen tearing."
- **Solution:** Always calculate the length of the *raw, unformatted string* to determine the required padding, apply the padding, and *then* inject the ANSI codes.
- **Code Pattern:**
  ```powershell
  $rawText = " Job: $($job.Name)"
  $padCount = 80 - $rawText.Length
  Write-Host "║ $(ctstr "{ct:cyan:b:$rawText}")$(" " * $padCount)║"
  ```

### Variable Scoping in Interpolated Strings
- **Challenge:** PowerShell string interpolation can fail or misinterpret variables when followed immediately by special characters (like `:`). E.g., `"$Path:"` might look for a scope or drive named `$Path`.
- **Solution:** Always use explicit curly brace wrapping for variables inside double-quoted strings when adjacent to non-whitespace characters.
- **Code Pattern:** Use `"${Path}:"` instead of `"$Path:"`.

### ASCII Art Escaping
- **Challenge:** Backticks (`` ` ``) in ASCII art are interpreted as escape characters by PowerShell when using expandable here-strings (`@""@`), corrupting the logo rendering.
- **Solution:** Always use literal here-strings (`@''@`) for ASCII art to ensure exact rendering.

---

## 3. High-Performance Tooling & Dependencies

### .NET-First Dimension Discovery
- **Concept:** Relying on external shell utilities (like ImageMagick's `identify`) to parse SVG dimensions is slow and prone to parsing errors.
- **Solution:** Utilized native `.NET` XML parsing (`[System.Xml.XmlDocument]`) in `Get-MGSvgDimensions.ps1`.
- **Benefit:** Sub-millisecond parsing and highly accurate extraction of `width`, `height`, and `viewBox` attributes for auto-scaling logic.

### Adaptive Dependency Fallbacks
- **Concept:** A robust module should not fail entirely if a preferred, but non-critical, dependency is missing.
- **Solution:** `Invoke-MagicGester` was designed to prefer `Inkscape` for high-fidelity vector rendering but gracefully falls back to `ImageMagick` (via `librsvg`) if Inkscape is absent.

---

## 4. Documentation & CI/CD Excellence

### PHWriter TUI Help Integration
- **Concept:** Bringing professional documentation directly into the terminal.
- **Implementation Details:**
  - Created a centralized `phwrite-metadata.ps1` array defining synopses, parameter tables, and examples.
  - Implemented `Show-MGTuiHelp` to render this metadata using the `New-PHWriter` engine.
  - **Param Context Switch:** Every public cmdlet implements a dedicated `Help` parameter set (`[Parameter(Mandatory = $true, ParameterSetName = 'Help')] [switch]$Help`). This allows the user to invoke `mystro -Help` and bypass mandatory parameter validation for the `Default` parameter set.

### Phellams Standard CI/CD
- **Concept:** Zero-touch deployments using standardized templates.
- **Implementation Details:**
  - Adopted the `phellams-automator` Docker image and multi-stage `.gitlab-ci.yml` template.
  - Implemented `build_config.json` to orchestrate Pester tests (`tests/MagicGester.Tests.ps1`) and package generation.
  - Added `New-MGRelease` to automate pipeline execution and draft release notes during the CI lifecycle.