function Get-MGBanner {
    <#
    .SYNOPSIS
        Generates a colored ASCII banner for MagicGester.
    #>
    [CmdletBinding()]
    param(
        [string]$Color1 = 'DarkMagenta',
        [string]$Color2 = 'Yellow'
    )

    process {
        $ascii = @'
.-.   .-..-.  .-..----..---. .----.  .----. 
|  `.'  | \ \/ /{ {__ {_   _}| {}  }/  {}  \
| |\ /| |  }  { .-._} } | |  | .-. \\      /
`-' ` `-'  `--' `----'  `-'  `-' `-' `----'                                     
'@

        # Using Write-GradientAscii if available (true 2D gradients), else New-AsciiGradient, else fallback
        if (Get-Command Write-GradientAscii -ErrorAction SilentlyContinue) {
            $lines = $ascii -split "`r?`n"
            $tokens = ConvertTo-AsciiTokens -Lines $lines -Connectivity 8
            Write-GradientAscii -TokenObject $tokens -Mode Horizontal -StartColor @(147, 51, 234) -EndColor @(234, 179, 8)
        } elseif (Get-Command New-AsciiGradient -ErrorAction SilentlyContinue) {
            # New-AsciiGradient expects integer steps for 256 colors.
            # Using standard Phellams colors: DarkMagenta to Yellow-ish
            New-AsciiGradient -Type fg -Steps @(55, 93, 129, 214, 226) -String $ascii
        } else {
            Write-Host $ascii -ForegroundColor $Color2
        }

        # Robust module version detection
        $version = (get-module -name 'mystro').version.tostring()
        $mod = Get-Module mystro
        if ($null -eq $mod) { $mod = Get-Module magicgester }
        if ($null -ne $mod) { $version = $mod.Version.ToString() }

        Write-Host " [v$version] - Mystro Asset Engine" -ForegroundColor Gray
        Write-Host ""
    }
}
