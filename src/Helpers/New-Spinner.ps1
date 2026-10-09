function New-Spinner {
    <#
    .SYNOPSIS
        Generates a stateful colorized spinner character using asciitokenizer logic.
    #>
    [CmdletBinding()]
    param(
        [string[]]$Steps = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'),
        [int[]]$StartColor = @(0, 150, 255),
        [int[]]$EndColor   = @(255, 0, 150),
        [switch]$Reset
    )

    if ($Reset) {
        $script:PwslSpinnerIdx = 0
        return
    }

    if ($null -eq $script:PwslSpinnerIdx) {
        $script:PwslSpinnerIdx = 0
    }

    $frame = $Steps[$script:PwslSpinnerIdx % $Steps.Count]
    $script:PwslSpinnerIdx++

    # Tokenize and colorize using asciitokenizer logic
    $tokens = ConvertTo-AsciiTokens -Lines @($frame)
    $color = Get-GradientColor -T 0 -Start $StartColor -End $EndColor
    $esc = [char]27
    return "$esc[38;2;$color`m$frame$esc[0m"
}