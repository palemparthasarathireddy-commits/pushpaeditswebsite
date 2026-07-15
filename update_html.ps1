# update_html.ps1
# Replaces base64 encoded videos with CDN URLs
$HtmlFile = "portfolio.html"
$content = Get-Content $HtmlFile -Raw -Encoding UTF8

$cdnBase = "https://YOUR-R2-BUCKET-URL.r2.dev"

Write-Host "Updating HTML..."

# Define the 4 unique videos based on size/content mapping
# Match 1: Hero bg
# Match 2: Portfolio 1
# Match 3: Portfolio 2
# Match 4: Portfolio 1 (duplicate)
# Match 5: Hero bg (duplicate)
# Match 6: Portfolio 2 (duplicate)
# Match 7: Portfolio 3
# Match 8: Portfolio 1 (duplicate)

# Let's replace the src based on string length to guarantee correctness across duplicates

# Lengths we noted earlier:
# 6960042 -> hero_bg.mp4
# 3958738 -> portfolio_1.mp4
# 4974738 -> portfolio_2.mp4
# 11112702 -> portfolio_3.mp4

$pattern = 'src="data:video/mp4;base64,([^"]+)"'
$matches = [regex]::Matches($content, $pattern)

foreach ($m in $matches) {
    if ($m.Length -gt 100) {
        $len = $m.Groups[1].Value.Length
        $fileName = ""
        
        if ([Math]::Abs($len - 6960042) -lt 1000) {
            $fileName = "opt_video_1_hero_bg.mp4"
        } elseif ([Math]::Abs($len - 3958738) -lt 1000) {
            $fileName = "opt_video_2_portfolio_1.mp4"
        } elseif ([Math]::Abs($len - 4974738) -lt 1000) {
            $fileName = "opt_video_3_portfolio_2.mp4"
        } elseif ([Math]::Abs($len - 11112702) -lt 1000) {
            $fileName = "opt_video_7_.mp4"
        } else {
            $fileName = "opt_video_unknown_$($len).mp4"
        }
        
        $newSrc = 'src="' + $cdnBase + '/' + $fileName + '" loading="lazy" preload="metadata"'
        
        # If it is the hero background video, keeping preload="none" or letting autoplay handle it
        if ($fileName -match "hero") {
             $newSrc = 'src="' + $cdnBase + '/' + $fileName + '" preload="none"'
        }
        
        # Replace the match in the content
        # Note: We replace the exact matched string $m.Value
        $content = $content.Replace($m.Value, $newSrc)
    }
}

# The user explicitly wanted `<source>` tag format: <source src="URL" type="video/mp4">
# We can just keep the <video src="URL"> format as it is universally supported, but let's just make sure
# we save the cleaned HTML.
[System.IO.File]::WriteAllText((Resolve-Path .).Path + "\portfolio.cleaned.html", $content, [System.Text.Encoding]::UTF8)

Write-Host "Replaced $( $matches.Count ) base64 elements."
Write-Host "New file size: $( [Math]::Round( (Get-Item portfolio.cleaned.html).Length / 1KB ) ) KB"
