$script:here = $PSScriptRoot
$script:root = Split-Path -Parent $script:here
Import-Module (Join-Path $script:root "mystro.psd1") -Force

Describe "MagicGester V2 Test Suite" {
    BeforeAll {
        $script:outDir = Join-Path $PSScriptRoot "output"
        if (Test-Path $script:outDir) { Remove-Item $script:outDir -Recurse -Force }
        New-Item -ItemType Directory -Path $script:outDir | Out-Null
        
        $script:testSvg = Join-Path $PSScriptRoot "test-logo.svg"
        Set-Content -Path $script:testSvg -Value '<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><circle cx="50" cy="50" r="40" stroke="green" stroke-width="4" fill="yellow" /></svg>'
    }

    AfterAll {
        if (Test-Path $script:outDir) { Remove-Item $script:outDir -Recurse -Force }
        if (Test-Path $script:testSvg) { Remove-Item $script:testSvg -Force }
    }

    Context "mystro config" {
        It "Should generate a valid configuration object" {
            $config = mystro config -Source $script:testSvg -OutputDir $script:outDir -Formats @('png', 'webp') -PngRanges @('32x32')
            $config.psobject.TypeNames[0] | Should -Be 'MagicGester.Config'
            $config.Jobs.Count | Should -Be 1
            $config.Jobs[0].Outputs.Keys | Should -Contain 'png'
        }
    }

    Context "mystro Gen (E2E)" {
        It "Should successfully execute the pipeline and generate assets" {
            if (-not (Get-Command magick -ErrorAction SilentlyContinue)) {
                Set-ItResult -Inconclusive -Because "ImageMagick (magick) is required for E2E tests but not installed."
                return
            }
            $config = mystro config -Source $script:testSvg -OutputDir $script:outDir -Formats @('png', 'ico', 'webp', 'jpg') -PngRanges @('32x32') -IcoRanges @('16x16') -WebpRanges @('32x32') -JpgRanges @('32x32')
            $stats = $config | mystro Gen
            
            $stats | Should -Not -BeNullOrEmpty
            
            $pngPath = Join-Path $script:outDir "png/test-logo-32x32.png"
            $icoPath = Join-Path $script:outDir "ico/test-logo-16x16.ico"
            
            Test-Path $pngPath | Should -Be $true
            Test-Path $icoPath | Should -Be $true
            
            $script:testPng = $pngPath
            $script:testJpg = Join-Path $script:outDir "jpg/test-logo-32x32.jpg"
            $script:testWebp = Join-Path $script:outDir "webp/test-logo-32x32.webp"
            $script:testIco = $icoPath
        }
    }

    Context "mystro minfo" {
        It "Should retrieve metadata for a generated PNG" {
            if ($null -ne $script:testPng -and (Test-Path $script:testPng)) {
                $info = mystro minfo -Source $script:testPng
                $info | Should -Not -BeNullOrEmpty
                $info.Format | Should -Match 'PNG'
            } else {
                Set-ItResult -Inconclusive -Because "Dependency file not found"
            }
        }
        
        It "Should retrieve metadata for a generated JPG" {
            if ($null -ne $script:testJpg -and (Test-Path $script:testJpg)) {
                $info = mystro minfo -Source $script:testJpg
                $info | Should -Not -BeNullOrEmpty
                $info.Format | Should -Match 'JPEG'
            } else {
                Set-ItResult -Inconclusive -Because "Dependency file not found"
            }
        }
    }

    Context "mystro MGI" {
        It "Should successfully process and resize a generic PNG image to WEBP" {
            if ($null -ne $script:testPng -and (Test-Path $script:testPng)) {
                $procDir = Join-Path $script:outDir "processed"
                $result = mystro MGI -Source $script:testPng -OutputDir $procDir -Range "16x16" -Format "webp"
                
                $result | Should -Not -BeNullOrEmpty
                Test-Path $result.Target | Should -Be $true
            } else {
                Set-ItResult -Inconclusive -Because "Dependency file not found"
            }
        }
    }

    Context "mystro minfo format help" {
        It "Should return without errors" {
            { mystro minfo -Format "png" } | Should -Not -Throw
        }
    }

    Context "mystro TUI Helpers" {
        It "Should generate stateful spinner characters and colorize them" {
            InModuleScope mystro {
                New-Spinner -Reset
                
                $s1 = New-Spinner
                $s2 = New-Spinner
                
                $s1 | Should -Not -BeNullOrEmpty
                $s2 | Should -Not -BeNullOrEmpty
                $s1 | Should -Not -Be $s2
            }
        }

        It "Should generate progress bars of correct length and apply colorization" {
            InModuleScope mystro {
                $bar = New-Bar -Percent 50 -Width 30
                $bar | Should -Not -BeNullOrEmpty
                $bar | Should -Match '\[38;2;'
            }
        }

        It "Should tokenize single lines correctly without array indexing errors" {
            InModuleScope mystro {
                { ConvertTo-AsciiTokens -Lines @("test") } | Should -Not -Throw
                $tokens = ConvertTo-AsciiTokens -Lines @("test")
                $tokens.Width | Should -Be 4
                $tokens.Height | Should -Be 1
            }
        }
    }
}
