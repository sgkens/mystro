$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = Split-Path -Parent $here
Import-Module (Join-Path $root "magicgester.psd1") -Force

Describe "MagicGester V2 Test Suite" {
    BeforeAll {
        $script:outDir = Join-Path $here "output"
        if (Test-Path $script:outDir) { Remove-Item $script:outDir -Recurse -Force }
        New-Item -ItemType Directory -Path $script:outDir | Out-Null
        
        $script:testSvg = Join-Path $here "test-logo.svg"
        Set-Content -Path $script:testSvg -Value '<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><circle cx="50" cy="50" r="40" stroke="green" stroke-width="4" fill="yellow" /></svg>'
    }

    AfterAll {
        if (Test-Path $script:outDir) { Remove-Item $script:outDir -Recurse -Force }
        if (Test-Path $script:testSvg) { Remove-Item $script:testSvg -Force }
    }

    Context "mystro config" {
        It "Should generate a valid configuration object" {
            $config = mystro config -Source $script:testSvg -OutputDir $script:outDir -Formats @('png', 'webp') -PngRanges @('32x32')
            $config.PSTypeName | Should -Be 'MagicGester.Config'
            $config.Jobs.Count | Should -Be 1
            $config.Jobs[0].Outputs.Keys | Should -Contain 'png'
        }
    }

    Context "mystro Gen (E2E)" {
        It "Should successfully execute the pipeline and generate assets" {
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
            if (Test-Path $script:testPng) {
                $info = mystro minfo -Source $script:testPng
                $info | Should -Not -BeNullOrEmpty
                $info.Format | Should -Match 'PNG'
            } else {
                Set-ItResult -Inconclusive -Message "Dependency file not found"
            }
        }
        
        It "Should retrieve metadata for a generated JPG" {
            if (Test-Path $script:testJpg) {
                $info = mystro minfo -Source $script:testJpg
                $info | Should -Not -BeNullOrEmpty
                $info.Format | Should -Match 'JPEG'
            } else {
                Set-ItResult -Inconclusive -Message "Dependency file not found"
            }
        }
    }

    Context "mystro MGI" {
        It "Should successfully process and resize a generic PNG image to WEBP" {
            if (Test-Path $script:testPng) {
                $procDir = Join-Path $script:outDir "processed"
                $result = mystro MGI -Source $script:testPng -OutputDir $procDir -Range "16x16" -Format "webp"
                
                $result | Should -Not -BeNullOrEmpty
                Test-Path $result.Target | Should -Be $true
            } else {
                Set-ItResult -Inconclusive -Message "Dependency file not found"
            }
        }
    }

    Context "mystro minfo format help" {
        It "Should return without errors" {
            { mystro minfo -Format "png" } | Should -Not -Throw
        }
    }
}
