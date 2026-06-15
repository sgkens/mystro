function Get-MGSvgDimensions {
    <#
    .SYNOPSIS
        Extracts dimensions (width, height, viewbox) from an SVG file using .NET XML parsing.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    process {
        try {
            $xml = [System.Xml.XmlDocument]::new()
            $xml.Load($Path)
            
            $svg = $xml.DocumentElement
            if ($svg.LocalName -ne 'svg') {
                throw "Root element is not 'svg'"
            }

            $width = $svg.GetAttribute('width')
            $height = $svg.GetAttribute('height')
            $viewbox = $svg.GetAttribute('viewBox')

            # Parse numeric values, stripping 'px', 'pt', etc.
            function Parse-Dim {
                param($val)
                if ($val -match '(?<num>[\d\.]+)') {
                    return [double]$Matches['num']
                }
                return $null
            }

            $w = Parse-Dim $width
            $h = Parse-Dim $height

            # Fallback to viewBox if width/height are missing or percentage
            if (($null -eq $w -or $null -eq $h) -and $viewbox) {
                $vbParts = $viewbox -split '[\s,]+'
                if ($vbParts.Count -eq 4) {
                    $w = [double]$vbParts[2]
                    $h = [double]$vbParts[3]
                }
            }

            return [PSCustomObject]@{
                Width   = $w
                Height  = $h
                ViewBox = $viewbox
            }
        }
        catch {
            Write-LazyLog -Level wrn -Title "SVG" -Message "Failed to parse dimensions for ${Path}: $($_.Exception.Message)"
            return $null
        }
    }
}
