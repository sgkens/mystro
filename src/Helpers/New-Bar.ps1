function New-Bar {
    <#
    .SYNOPSIS
        Generates a progress bar colorized with an asciitokenizer gradient.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(0, 100)]
        [int]$Percent,

        [Parameter(Position = 1)]
        [int]$Width = 20,

        [char]$FillChar = '█',
        [char]$EmptyChar = '░',

        [int[]]$StartColor = @(0, 255, 100),
        [int[]]$EndColor   = @(0, 100, 255)
    )

    $fillCount = [math]::Round(($Percent / 100.0) * $Width)
    if ($fillCount -gt $Width) { $fillCount = $Width }
    if ($fillCount -lt 0) { $fillCount = 0 }
    $emptyCount = $Width - $fillCount

    $barText = ([string]$FillChar * $fillCount) + ([string]$EmptyChar * $emptyCount)

    # Tokenize and colorize using asciitokenizer BFS/gradient logic
    $tokens = ConvertTo-AsciiTokens -Lines @($barText)
    $esc = [char]27
    $sb = [System.Text.StringBuilder]::new()
    for ($x = 0; $x -lt $tokens.Width; $x++) {
        $c = $tokens.Lines[0][$x]
        $t = if ($tokens.Width -gt 1) { $x / ($tokens.Width - 1) } else { 0 }
        $color = Get-GradientColor -T $t -Start $StartColor -End $EndColor
        [void]$sb.Append("$esc[38;2;$color`m$c$esc[0m")
    }

    return $sb.ToString()
}
