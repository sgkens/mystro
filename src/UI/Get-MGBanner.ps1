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
        $ascii = @"
  __  __             _         _____           _            
 |  \/  |           (_)       / ____|         | |           
 | \  / | __ _  __ _ _  ___  | |  __  ___  ___| |_ ___ _ __ 
 | |\/| |/ _` |/ _` | |/ __| | | |_ |/ _ \/ __| __/ _ \ '__|
 | |  | | (_| | (_| | | (__  | |__| |  __/\__ \ |_  __/ |   
 |_|  |_|\__,_|\__, |_|\___|  \_____|\___||___/\__\___|_|   
                __/ |                                       
               |___/                                        
"@

        # Using New-AsciiGradient if available, otherwise fallback to simple color
        if (Get-Command New-AsciiGradient -ErrorAction SilentlyContinue) {
            New-AsciiGradient -Text $ascii -Color1 $Color1 -Color2 $Color2
        } else {
            Write-Host $ascii -ForegroundColor $Color2
        }
        Write-Host " [v$((Get-Module magicgester).Version)] - High-Performance Asset Engine" -ForegroundColor Gray
        Write-Host ""
    }
}
