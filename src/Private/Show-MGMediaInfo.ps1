function Show-MGMediaInfo {
    <#
    .SYNOPSIS
        Displays information about common media formats and their best use cases.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('mginfo')]
    param(
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Default')]
        [string]$Format,

        [Parameter(Mandatory = $true, ParameterSetName = 'Help')]
        [switch]$Help
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Help') {
            Show-MGTuiHelp -CmdletName 'Show-MGMediaInfo'
            return
        }

        $mediaData = @{
            png  = @{
                Name = "Portable Network Graphics"
                BestFor = "Logos, icons, and images with transparency."
                Pros = "Lossless compression, alpha channel support."
                Cons = "Larger file sizes compared to lossy formats."
                Wiki = "https://en.wikipedia.org/wiki/PNG"
            }
            webp = @{
                Name = "WebP"
                BestFor = "Modern web applications, high-performance sites."
                Pros = "Superior compression (both lossy and lossless)."
                Cons = "Older browser compatibility (mostly legacy now)."
                Wiki = "https://en.wikipedia.org/wiki/WebP"
            }
            ico  = @{
                Name = "Windows Icon"
                BestFor = "Favicons, desktop icons."
                Pros = "Supports multiple resolutions in one file."
                Cons = "Limited to specific platforms/use-cases."
                Wiki = "https://en.wikipedia.org/wiki/ICO_(file_format)"
            }
            jpg  = @{
                Name = "Joint Photographic Experts Group"
                BestFor = "Photographs and complex images."
                Pros = "Highly adjustable compression, universal support."
                Cons = "Lossy, no transparency."
                Wiki = "https://en.wikipedia.org/wiki/JPEG"
            }
            svg  = @{
                Name = "Scalable Vector Graphics"
                BestFor = "Illustrations, icons, and diagrams."
                Pros = "Resolution independent, editable via code/CSS."
                Cons = "Can become complex and slow to render if overly detailed."
                Wiki = "https://en.wikipedia.org/wiki/SVG"
            }
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Help') { return }

        if ($Format) {
            $keys = @($Format.ToLower())
        } else {
            $keys = $mediaData.Keys | Sort-Object
        }

        foreach ($key in $keys) {
            if ($mediaData.ContainsKey($key)) {
                $item = $mediaData[$key]
                Write-Host "`n💠 Format: $(ctstr "{ct:yellow:b:$($key.ToUpper())}") ($($item.Name))" -ForegroundColor DarkCyan
                Write-Host "$(New-Kvinc -keyName 'Best For' -KeyValue $item.BestFor -type inf)"
                Write-Host "$(New-Kvinc -keyName 'Pros' -KeyValue $item.Pros -type inf)"
                Write-Host "$(New-Kvinc -keyName 'Cons' -KeyValue $item.Cons -type wrn)"
                Write-Host "$(New-Kvinc -keyName 'Wiki' -KeyValue $item.Wiki -type inf)"
            }
        }
        Write-Host ""
    }
}
