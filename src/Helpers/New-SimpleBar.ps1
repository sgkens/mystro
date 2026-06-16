# ==============================================================================
# File: SimpleBar.psm1
# ==============================================================================

# ------------------------------------------------------------------------------
# INITIALIZATION: VT100 / ANSI Support Enabler
# ------------------------------------------------------------------------------
try {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class TerminalConfiguration {
        const int STD_OUTPUT_HANDLE = -11;
        const uint ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004;

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr GetStdHandle(int nStdHandle);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);

        public static void EnableVT100() {
            IntPtr handle = GetStdHandle(STD_OUTPUT_HANDLE);
            if (handle != IntPtr.Zero) {
                uint mode;
                if (GetConsoleMode(handle, out mode)) {
                    mode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
                    SetConsoleMode(handle, mode);
                }
            }
        }
    }
"@ -ErrorAction SilentlyContinue
    [TerminalConfiguration]::EnableVT100()
}
catch {
    # Fail silently if host environment does not support Win32 API calls (e.g., non-Windows OS)
}

# ------------------------------------------------------------------------------
# HELPER: Get-TerminalUI
# ------------------------------------------------------------------------------
function Get-TerminalUI {
    param (
        [ValidateSet('None', 'Thin', 'Double', 'Rounded')]
        [string]$BorderStyle = 'None'
    )
    
    $ui = [PSCustomObject]@{
        TopLeft     = ''
        TopRight    = ''
        BottomLeft  = ''
        BottomRight = ''
        Horizontal  = ''
        Vertical    = ''
        HasBorder   = $false
    }

    switch ($BorderStyle) {
        'Thin' {
            $ui.TopLeft = '┌'; $ui.TopRight = '┐'; $ui.BottomLeft = '└'; $ui.BottomRight = '┘'
            $ui.Horizontal = '─'; $ui.Vertical = '│'; $ui.HasBorder = $true
        }
        'Double' {
            $ui.TopLeft = '╔'; $ui.TopRight = '╗'; $ui.BottomLeft = '╚'; $ui.BottomRight = '╝'
            $ui.Horizontal = '═'; $ui.Vertical = '║'; $ui.HasBorder = $true
        }
        'Rounded' {
            $ui.TopLeft = '╭'; $ui.TopRight = '╮'; $ui.BottomLeft = '╰'; $ui.BottomRight = '╯'
            $ui.Horizontal = '─'; $ui.Vertical = '│'; $ui.HasBorder = $true
        }
    }
    return $ui
}

# ------------------------------------------------------------------------------
# HELPER: Get-TerminalPalette
# ------------------------------------------------------------------------------
function Get-TerminalPalette {
    param (
        [hashtable]$ColorPalette,
        [string]$ColorMode,
        [hashtable]$ColorThresholds,
        [int[]]$GradientStart,
        [int[]]$GradientEnd,
        [int]$CurrentValue,
        [int]$MaxValue = 100
    )

    $esc = [char]27
    $reset = "$esc[0m"

    $parseColor = {
        param($Value)
        if ($null -eq $Value) { return $null }
        if ($Value -is [array] -and $Value.Count -ge 3) {
            return "38;2;$([int]$Value[0]);$([int]$Value[1]);$([int]$Value[2])"
        }
        return [string]$Value
    }

    $paletteObj = [PSCustomObject]@{
        Apply          = {
            param([string]$Text, [string]$Code)
            if ([string]::IsNullOrWhiteSpace($Code) -or [string]::IsNullOrEmpty($Text)) { return $Text }
            return "$esc[$Code`m$Text$reset"
        }.GetNewClosure()
        
        GetFillColor   = {
            param([int]$Index, [int]$TotalFill)
            
            if ($ColorMode -eq 'Conditional') {
                $matchingThreshold = $null
                $minKey = [int]::MaxValue
                foreach ($k in $ColorThresholds.Keys) {
                    if ($k -ge $CurrentValue -and $k -lt $minKey) {
                        $minKey = $k
                        $matchingThreshold = $k
                    }
                }
                if ($null -ne $matchingThreshold) { 
                    return (& $parseColor $ColorThresholds[$matchingThreshold])
                }
                return $null
            }
            
            if ($ColorMode -eq 'Gradient') {
                $ratio = 0
                if ($TotalFill -gt 1) { $ratio = $Index / ($TotalFill - 1) }
                $r = [math]::Round($GradientStart[0] + ($GradientEnd[0] - $GradientStart[0]) * $ratio)
                $g = [math]::Round($GradientStart[1] + ($GradientEnd[1] - $GradientStart[1]) * $ratio)
                $b = [math]::Round($GradientStart[2] + ($GradientEnd[2] - $GradientStart[2]) * $ratio)
                return "38;2;$r;$g;$b"
            }

            foreach ($k in $ColorPalette.Keys) {
                if ($k -ieq 'Fill') { 
                    return (& $parseColor $ColorPalette[$k])
                }
            }
            return $null
        }.GetNewClosure()

        GetStaticColor = {
            param([string]$Key)
            foreach ($k in $ColorPalette.Keys) {
                if ($k -ieq $Key) { 
                    return (& $parseColor $ColorPalette[$k])
                }
            }
            return $null
        }.GetNewClosure()
    }
    
    return $paletteObj
}

# ------------------------------------------------------------------------------
# FUNCTION: New-SimpleBar
# ------------------------------------------------------------------------------
function New-SimpleBar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]$Brackets = @('[', ']'),

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateRange(0, 100)]
        [int]$Fill,

        [Parameter(Mandatory = $false)]
        [ValidateRange(3, [int]::MaxValue)]
        [int]$Width = 20,

        [Parameter(Mandatory = $false)]
        [char]$FillChar = [char]9608,

        [Parameter(Mandatory = $false)]
        [char]$EmptyChar = '-',

        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Thin', 'Double', 'Rounded')]
        [string]$BorderStyle = 'None',

        [Parameter(Mandatory = $false)]
        [hashtable]$ColorPalette = @{},

        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Center', 'Start', 'End', 'Before', 'After')]
        [string]$PercentagePosition = 'None',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Solid', 'Conditional', 'Gradient')]
        [string]$ColorMode = 'Solid',

        [Parameter(Mandatory = $false)]
        [hashtable]$ColorThresholds = @{ 30 = "38;5;196"; 70 = "38;5;226"; 100 = "38;5;46" },

        [Parameter(Mandatory = $false)]
        [int[]]$GradientStart = @(255, 0, 0),

        [Parameter(Mandatory = $false)]
        [int[]]$GradientEnd = @(0, 255, 0)
    )

    process {
        $ui = Get-TerminalUI -BorderStyle $BorderStyle
        $palette = Get-TerminalPalette -ColorPalette $ColorPalette -ColorMode $ColorMode -ColorThresholds $ColorThresholds -GradientStart $GradientStart -GradientEnd $GradientEnd -CurrentValue $Fill

        $rawLeft = if ($Brackets.Count -gt 0) { $Brackets[0] } else { '' }
        $rawRight = if ($Brackets.Count -gt 1) { $Brackets[1] } else { '' }

        $borderOffset = if ($ui.HasBorder) { 2 } else { 0 }
        $innerWidth = $Width - ($rawLeft.Length + $rawRight.Length) - $borderOffset
        if ($innerWidth -lt 1) { $innerWidth = 1 }

        $fillCount = [math]::Round(($Fill / 100.0) * $innerWidth)
        if ($fillCount -gt $innerWidth) { $fillCount = $innerWidth }
        if ($fillCount -lt 0) { $fillCount = 0 }

        $emptyCount = $innerWidth - $fillCount

        $innerString = ([string]$FillChar * $fillCount) + ([string]$EmptyChar * $emptyCount)
        $pctText = "$Fill%"

        if ($PercentagePosition -in @('Start', 'Center', 'End')) {
            if ($innerWidth -ge $pctText.Length) {
                $insertIndex = 0
                if ($PercentagePosition -eq 'Center') { $insertIndex = [math]::Floor(($innerWidth - $pctText.Length) / 2) } 
                elseif ($PercentagePosition -eq 'End') { $insertIndex = $innerWidth - $pctText.Length }
                $innerString = $innerString.Remove($insertIndex, $pctText.Length).Insert($insertIndex, $pctText)
            }
        }

        $coloredInnerChars = [System.Collections.Generic.List[string]]::new()
        $innerCharArray = $innerString.ToCharArray()

        $emptyCode = (& $palette.GetStaticColor 'Empty')

        for ($i = 0; $i -lt $innerWidth; $i++) {
            $currentChar = $innerCharArray[$i]
            $code = $null

            if ($i -lt $fillCount) {
                $code = (& $palette.GetFillColor $i $fillCount)
            }
            else {
                $code = $emptyCode
            }

            $coloredInnerChars.Add((& $palette.Apply $currentChar $code))
        }

        $assembledInner = -join $coloredInnerChars

        $bracketCode = (& $palette.GetStaticColor 'Brackets')
        $borderCode = (& $palette.GetStaticColor 'Border')

        $coloredLeft = (& $palette.Apply $rawLeft $bracketCode)
        $coloredRight = (& $palette.Apply $rawRight $bracketCode)

        $barLine = -join ($coloredLeft, $assembledInner, $coloredRight)

        $output = if ($ui.HasBorder) {
            $horizontalCount = $Width - 2
            if ($horizontalCount -lt 1) { $horizontalCount = 1 }
            
            $topBorder = $ui.TopLeft + ($ui.Horizontal * $horizontalCount) + $ui.TopRight
            $bottomBorder = $ui.BottomLeft + ($ui.Horizontal * $horizontalCount) + $ui.BottomRight
            
            $coloredTop = (& $palette.Apply $topBorder $borderCode)
            $coloredBottom = (& $palette.Apply $bottomBorder $borderCode)
            $coloredVert = (& $palette.Apply $ui.Vertical $borderCode)

            $midLine = -join ($coloredVert, $barLine, $coloredVert)

            if ($PercentagePosition -eq 'Before') {
                $padSpace = " " * ($pctText.Length + 1)
                $coloredTop = "$padSpace$coloredTop"
                $coloredBottom = "$padSpace$coloredBottom"
                $midLine = "$pctText $midLine"
            }
            elseif ($PercentagePosition -eq 'After') {
                $midLine = "$midLine $pctText"
            }

            -join ($coloredTop, [Environment]::NewLine, $midLine, [Environment]::NewLine, $coloredBottom)
        }
        else {
            if ($PercentagePosition -eq 'Before') { "$pctText $barLine" } 
            elseif ($PercentagePosition -eq 'After') { "$barLine $pctText" }
            else { $barLine }
        }

        Write-Output $output
    }
}

# ------------------------------------------------------------------------------
# FUNCTION: Invoke-SimpleBarAnimation
# ------------------------------------------------------------------------------
function Invoke-SimpleBarAnimation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [hashtable]$BarParameters,

        [Parameter(Mandatory = $false)]
        [int]$DelayMilliseconds = 25
    )

    process {
        $esc = [char]27
        Write-Host -NoNewline "$esc[?25l"
        
        try {
            for ($i = 0; $i -le 100; $i++) {
                $BarParameters['Fill'] = $i
                $frame = New-SimpleBar @BarParameters
                
                Write-Host -NoNewline "`r$frame"
                Start-Sleep -Milliseconds $DelayMilliseconds
            }
            Write-Host ""
        }
        finally {
            Write-Host -NoNewline "$esc[?25h"
        }
    }
}

# ------------------------------------------------------------------------------
# FUNCTION: New-VerticalBar
# ------------------------------------------------------------------------------
function New-VerticalBar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Specialized.OrderedDictionary]$Data,

        [Parameter(Mandatory = $false)]
        [int]$Height = 10,

        [Parameter(Mandatory = $false)]
        [ValidateSet('FullBlock', 'ShadeStack', 'BrailleCol', 'ThinPipe', 'DoublePipe', 'DotRise', 'DiamondStack', 'ArrowRise', 'WaveCol', 'SegmentLED')]
        [string]$Style = 'FullBlock',

        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Thin', 'Double', 'Rounded')]
        [string]$BorderStyle = 'None',

        [Parameter(Mandatory = $false)]
        [hashtable]$ColorPalette = @{},

        [Parameter(Mandatory = $false)]
        [ValidateSet('Solid', 'Conditional')]
        [string]$ColorMode = 'Conditional',

        [Parameter(Mandatory = $false)]
        [hashtable]$ColorThresholds = @{ 30 = "38;5;46"; 70 = "38;5;226"; 100 = "38;5;196" } 
    )

    process {
        $ui = Get-TerminalUI -BorderStyle $BorderStyle
        $palette = Get-TerminalPalette -ColorPalette $ColorPalette -ColorMode $ColorMode -ColorThresholds $ColorThresholds

        $keys = $Data.Keys
        $values = $Data.Values

        $charSets = @{
            'FullBlock'    = @{ Empty = '░'; Full = '█'; Steps = @('░', '▁', '▂', '▃', '▄', '▅', '▆', '▇') }
            'ShadeStack'   = @{ Empty = '░'; Full = '█'; Steps = @('░', '▒', '▓') }
            'BrailleCol'   = @{ Empty = '⠀'; Full = '⣿'; Steps = @('⠀', '⣀', '⣄', '⣤', '⣦', '⣶', '⣷') }
            'ThinPipe'     = @{ Empty = '╎'; Full = '┃'; Steps = @('╎') }
            'DoublePipe'   = @{ Empty = '│'; Full = '║'; Steps = @('│') }
            'DotRise'      = @{ Empty = '·'; Full = '●'; Steps = @('·', '∘') }
            'DiamondStack' = @{ Empty = '◇'; Full = '◆'; Steps = @('◇') }
            'ArrowRise'    = @{ Empty = '·'; Full = '▴'; Steps = @('·', '▲') }
            'WaveCol'      = @{ Empty = '·'; Full = '∿'; Steps = @('·', '≈', '~') }
            'SegmentLED'   = @{ Empty = '╌'; Full = '▬'; Steps = @('╌') }
        }
        $set = $charSets[$Style]

        $columns = [System.Collections.Generic.List[Object]]::new()
        foreach ($val in $values) {
            $colPalette = Get-TerminalPalette -ColorPalette $ColorPalette -ColorMode $ColorMode -ColorThresholds $ColorThresholds -CurrentValue $val
            $fillLines = ($val / 100.0) * $Height
            $fullBlocks = [math]::Floor($fillLines)
            $remainder = $fillLines - $fullBlocks
            
            $stepIndex = [math]::Round($remainder * ($set.Steps.Count - 1))
            $tipChar = if ($remainder -gt 0) { $set.Steps[$stepIndex] } else { $set.Empty }

            $columns.Add([PSCustomObject]@{
                    Value     = $val
                    FullCount = $fullBlocks
                    TipChar   = $tipChar
                    Palette   = $colPalette
                })
        }

        $outputLines = [System.Collections.Generic.List[string]]::new()

        $valRowChars = [System.Collections.Generic.List[string]]::new()
        foreach ($key in $keys) { $valRowChars.Add($Data[$key].ToString().PadLeft(3).PadRight(4)) }
        $outputLines.Add(-join $valRowChars)

        for ($row = $Height; $row -gt 0; $row--) {
            $lineChars = [System.Collections.Generic.List[string]]::new()
            
            foreach ($col in $columns) {
                $char = $set.Empty
                if ($col.FullCount -ge $row) {
                    $char = $set.Full
                }
                elseif ($col.FullCount -eq ($row - 1)) {
                    $char = $col.TipChar
                }

                if ($Style -eq 'WaveCol' -and $char -eq $set.Full) {
                    $char = $set.Steps[$row % $set.Steps.Count]
                }

                $colorCode = (& $col.Palette.GetFillColor 1 1)
                $renderedChar = (& $col.Palette.Apply $char $colorCode)
                $lineChars.Add(" $renderedChar  ")
            }
            $outputLines.Add(-join $lineChars)
        }

        $headerRowChars = [System.Collections.Generic.List[string]]::new()
        foreach ($key in $keys) { 
            $truncKey = if ($key.Length -gt 3) { $key.Substring(0, 3) } else { $key.PadRight(3) }
            $headerRowChars.Add("$truncKey ") 
        }
        $outputLines.Add(-join $headerRowChars)

        if ($ui.HasBorder) {
            $contentWidth = ($keys.Count * 4)
            $borderCode = (& $palette.GetStaticColor 'Border')
            
            $topBorderStr = $ui.TopLeft + ($ui.Horizontal * $contentWidth) + $ui.TopRight
            $botBorderStr = $ui.BottomLeft + ($ui.Horizontal * $contentWidth) + $ui.BottomRight

            $topBorder = (& $palette.Apply $topBorderStr $borderCode)
            $bottomBorder = (& $palette.Apply $botBorderStr $borderCode)
            $vChar = (& $palette.Apply $ui.Vertical $borderCode)

            $framedLines = [System.Collections.Generic.List[string]]::new()
            $framedLines.Add($topBorder)
            foreach ($line in $outputLines) {
                $framedLines.Add("$vChar$line$vChar")
            }
            $framedLines.Add($bottomBorder)
            Write-Output ($framedLines -join [Environment]::NewLine)
        }
        else {
            Write-Output ($outputLines -join [Environment]::NewLine)
        }
    }
}

# ------------------------------------------------------------------------------
# FUNCTION: New-3DBar
# ------------------------------------------------------------------------------
function New-3DBar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [int]$Fill,

        [Parameter(Mandatory = $false)]
        [int]$Width = 40,

        [Parameter(Mandatory = $false)]
        [string]$Subtext = "",

        [Parameter(Mandatory = $false)]
        [hashtable]$ColorPalette = @{ Fill = "38;5;33"; Frame = "38;5;240" }
    )

    process {
        $palette = Get-TerminalPalette -ColorPalette $ColorPalette
        $frameCode = (& $palette.GetStaticColor 'Frame')
        $fillCode = (& $palette.GetStaticColor 'Fill')

        $innerWidth = $Width - 2
        $fillCount = [math]::Round(($Fill / 100.0) * $innerWidth)
        $emptyCount = $innerWidth - $fillCount

        $emptyDots = '·' * $emptyCount

        $topFill = '─' * $fillCount
        $rawTop = "╭$topFill╮$emptyDots"
        $coloredTop = (& $palette.Apply "[$rawTop]" $frameCode)

        $midFill = '█' * $fillCount
        $coloredMidFill = (& $palette.Apply $midFill $fillCode)
        $coloredMidEmpty = (& $palette.Apply $emptyDots $frameCode)
        $vBar = (& $palette.Apply '│' $frameCode)
            $bracketL = (& $palette.Apply '[' $frameCode)
            $bracketR = (& $palette.Apply ']' $frameCode)
        
            $coloredMid = "$bracketL$vBar$coloredMidFill$vBar$coloredMidEmpty$bracketR"

            $botFill = '─' * $fillCount
            $rawBot = "╰$botFill╯$emptyDots"
            $coloredBot = (& $palette.Apply "[$rawBot]" $frameCode)

            $out = [System.Collections.Generic.List[string]]::new()
            $out.Add("$Title")
            $out.Add("$coloredTop  $Fill%")
            $out.Add($coloredMid)
            $out.Add($coloredBot)
            if (![string]::IsNullOrWhiteSpace($Subtext)) { $out.Add($Subtext) }

            Write-Output ($out -join [Environment]::NewLine)
        }
}

# ------------------------------------------------------------------------------
# FUNCTION: New-DashboardBar
# ------------------------------------------------------------------------------
function New-DashboardBar {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Data,

        [Parameter(Mandatory = $false)]
        [int]$Width = 50,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Block', 'Wave', 'Braille')]
        [string]$Style = 'Block'
    )

    process {
        $props = $Data.psobject.properties
        $outLines = [System.Collections.Generic.List[string]]::new()

        foreach ($prop in $props) {
            $name = $prop.Name.PadRight(15)
            $val = $prop.Value.Percentage
            $lines = $prop.Value.Subtext

            $fillChar = '█'
            $emptyChar = '░'

            if ($Style -eq 'Wave') { $fillChar = '~'; $emptyChar = '·' }
            if ($Style -eq 'Braille') { $fillChar = '⣿'; $emptyChar = '⠀' }

            $bar = New-SimpleBar -Fill $val -Width $Width -FillChar $fillChar -EmptyChar $emptyChar -PercentagePosition After
            $outLines.Add("$name $bar")

            if ($null -ne $lines) {
                foreach ($line in $lines) {
                    $outLines.Add("                $line")
                }
            }
            $outLines.Add("")
        }

        Write-Output ($outLines -join [Environment]::NewLine)
    }
}

# ------------------------------------------------------------------------------
# FUNCTION: New-TrailingLog
# ------------------------------------------------------------------------------
function New-TrailingLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [Object]$LogData,

        [Parameter(Mandatory = $false)]
        [int]$MaxLines = 5,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Solid', 'GradientFade')]
        [string]$ColorMode = 'GradientFade',

        [Parameter(Mandatory = $false)]
        [int[]]$GradientStart = @(60, 60, 60), 

        [Parameter(Mandatory = $false)]
        [int[]]$GradientEnd = @(255, 255, 255), 

        [Parameter(Mandatory = $false)]
        [string]$SolidColor = "38;5;255"
    )

    process {
        $esc = [char]27
        $reset = "$esc[0m"

        $logArray = @($LogData)
        if ($logArray.Count -eq 0) { return "" }

        $startIndex = [math]::Max(0, $logArray.Count - $MaxLines)
        $displayLogs = $logArray[$startIndex..($logArray.Count - 1)]
        $count = $displayLogs.Count

        $halfCount = [math]::Floor($count / 2)
        $outLines = [System.Collections.Generic.List[string]]::new()

        for ($i = 0; $i -lt $count; $i++) {
            $line = $displayLogs[$i]
            if ([string]::IsNullOrWhiteSpace($line)) {
                $outLines.Add("")
                continue
            }

            if ($ColorMode -eq 'Solid') {
                $outLines.Add("$esc[$SolidColor`m$line$reset")
            }
            else {
                if ($i -lt ($count - $halfCount)) {
                    $fadeSteps = $count - $halfCount
                    $ratio = if ($fadeSteps -gt 1) { $i / ($fadeSteps - 1) } else { 1 }
                    $r = [math]::Round($GradientStart[0] + ($GradientEnd[0] - $GradientStart[0]) * $ratio)
                    $g = [math]::Round($GradientStart[1] + ($GradientEnd[1] - $GradientStart[1]) * $ratio)
                    $b = [math]::Round($GradientStart[2] + ($GradientEnd[2] - $GradientStart[2]) * $ratio)
                    $outLines.Add("$esc[38;2;$r;$g;$b`m$line$reset")
                } 
                else {
                    $r = $GradientEnd[0]; $g = $GradientEnd[1]; $b = $GradientEnd[2]
                    $outLines.Add("$esc[38;2;$r;$g;$b`m$line$reset")
                }
            }
        }

        Write-Output ($outLines -join [Environment]::NewLine)
    }
}

# ------------------------------------------------------------------------------
# FUNCTION: New-Separator
# ------------------------------------------------------------------------------
function New-Separator {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [char]$Char = '─',

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Repeat = 50,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Solid', 'Gradient')]
        [string]$ColorMode = 'Solid',

        [Parameter(Mandatory = $false)]
        [hashtable]$ColorPalette = @{ Fill = @(128, 128, 128) },

        [Parameter(Mandatory = $false)]
        [int[]]$GradientStart = @(60, 60, 60),

        [Parameter(Mandatory = $false)]
        [int[]]$GradientEnd = @(255, 255, 255)
    )

    process {
        $palette = Get-TerminalPalette -ColorPalette $ColorPalette -ColorMode $ColorMode -GradientStart $GradientStart -GradientEnd $GradientEnd -CurrentValue 100

        if ($ColorMode -eq 'Solid') {
            $rawString = [string]$Char * $Repeat
        
            $solidCode = (& $palette.GetStaticColor 'Fill')
            if ($null -eq $solidCode) { $solidCode = "38;5;255" } 
        
            $output = (& $palette.Apply $rawString $solidCode)
            Write-Output $output
        } 
        else {
            $coloredChars = [System.Collections.Generic.List[string]]::new()
        
            for ($i = 0; $i -lt $Repeat; $i++) {
                $code = (& $palette.GetFillColor $i $Repeat)
                $coloredChars.Add((& $palette.Apply $Char $code))
            }
        
            Write-Output (-join $coloredChars)
        }
    }
}

# Export-ModuleMember -Function New-SimpleBar, Invoke-SimpleBarAnimation, New-VerticalBar, New-3DBar, New-DashboardBar, New-TrailingLog, New-Separator