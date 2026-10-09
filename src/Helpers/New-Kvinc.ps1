<#
.SYNOPSIS
    Creates a string with a key-value pair in a specific format.
.DESCRIPTION
    Creates a string with a key-value pair in a specific format.
.PARAMETER keyName
    The name of the key.
.PARAMETER KeyValue
    The value of the key.
.PARAMETER type
    The type of the key-value pair.
.EXAMPLE
    New-kvstring -message "This is a test message with a {kv:username=JohnDoe}"
    New-KvString -message "This is a test message with a {kv:username=JohnDoe} and a {prop:kv:userid=12345}"
    New-KvString -message "This is a test message with a {kv:username=JohnDoe} and a {prop:kv:userid=12345} and a {meta:kv:session=abcde"
#>
function New-Kvinc {
    [CmdletBinding()]
    [alias('kvinc')]
    param(
        [parameter(Mandatory, Position = 0)]
        [string]$keyName,

        [parameter(Mandatory, Position = 1)]
        [string]$KeyValue,

        [parameter(Mandatory = $false, Position = 2)]
        [string]$type
    )
    
    [string]$string = ''
    
    if (!$type) {
        $type = 'none'
    }

    $utility = @{
        kvinc_bracket_color  = "95"
        kvinc_bracket_format = ";1"
        kvinc_type_color     = "90"
        kvinc_type_format    = ";1"
        kvinc_key_color      = "94"
        kvinc_key_format     = ";1"
        kvinc_value_color    = "90"
        kvinc_value_format   = ";1"
    }
    
    $lowerType = $type.ToLower()
    if ($lowerType -eq 'none') {
        
        $string += "`e[$($utility.kvinc_bracket_color)$($utility.kvinc_bracket_format)m{`e[0m"
      
        $string += " `e[$($utility.kvinc_key_color)$($utility.kvinc_key_format)m$keyName`e[0m"
        $string += " `e[$($utility.kvinc_bracket_color)$($utility.kvinc_bracket_format)m:`e[0m"
        $string += " `e[$($utility.kvinc_value_color)$($utility.kvinc_value_format)m$KeyValue`e[0m"
      
        $string += "`e[$($utility.kvinc_bracket_color)$($utility.kvinc_bracket_format)m }`e[0m"
      
        return $string.replace("^\{", "")
    
    }
    else {

        $string += "`e[$($utility.kvinc_bracket_color)$($utility.kvinc_bracket_format)m{`e[0m "

        $color = "31" # default to red for property/meta/etc.
        if ($lowerType -in @('inf', 'info')) {
            $color = "37" # White
        } elseif ($lowerType -in @('suc', 'success')) {
            $color = "32" # Green
        } elseif ($lowerType -in @('wrn', 'warning', 'wrd')) {
            $color = "33" # Yellow
        } elseif ($lowerType -in @('err', 'error')) {
            $color = "31" # Red
        }

        $string += "`e[$color$($utility.kvinc_type_format)m$type`e[0m ≡"
        $string += " `e[$($utility.kvinc_key_color)$($utility.kvinc_key_format)m$keyName`e[0m"
        $string += " `e[$($utility.kvinc_bracket_color)$($utility.kvinc_bracket_format)m:`e[0m"
        $string += " `e[$($utility.kvinc_value_color)$($utility.kvinc_value_format)m$KeyValue`e[0m"
       
        $string += " `e[$($utility.kvinc_bracket_color)$($utility.kvinc_bracket_format)m}`e[0m"

        return $string
    }
}

# Example usage:
# $message = "This is a test message with a {kv:username=JohnDoe}"
# $result = New-Kvinc -keyName 'username' -KeyValue 'JohnDoe' -type inf