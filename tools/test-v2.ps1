# Test Script for MagicGester V2
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)
$modulePath = Join-Path $root "magicgester.psd1"

Import-Module $modulePath -Force

$testSvg = Join-Path $root "test-logo.svg"
$outDir  = Join-Path $root "output/test-v2"

# Clean up old output
if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }

Write-Host "--- Starting MagicGester V2 Test ---" -ForegroundColor Cyan

$config = New-MGConfig -Source $testSvg -OutputDir $outDir -PngRanges @('32x32', '64x64') -IcoRanges @('16x16') -WebpRanges @('128x128')

$config | Invoke-MagicGester

Write-Host "--- Test Complete. Check output at: $outDir ---" -ForegroundColor Cyan
