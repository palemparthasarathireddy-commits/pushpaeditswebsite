# fix_html.ps1
$content = [System.IO.File]::ReadAllText("portfolio.backup.html", [System.Text.Encoding]::UTF8)

# The four lengths of unique base64 encoded videos
$map = @{
    6960042 = "opt_video_1_hero_bg.mp4"
    3958738 = "opt_video_2_portfolio_1.mp4"
    4974738 = "opt_video_3_portfolio_2.mp4"
    11112702 = "opt_video_7_.mp4"
}

# Find all base64 occurrences
$pattern = 'src="data:video/mp4;base64,([A-Za-z0-9+/=]+)"'
$matches = [regex]::Matches($content, $pattern)

foreach ($m in $matches) {
    if ($m.Length -gt 100) {
        $len = $m.Groups[1].Value.Length
        
        $fileName = "opt_video_unknown_$($len).mp4"
        foreach ($k in $map.Keys) {
            if ([Math]::Abs($len - $k) -lt 1000) {
                $fileName = $map[$k]
                break
            }
        }
        
        $isHero = $fileName -match "hero"
        
        # New string to replace the base64 part
        if ($isHero) {
            $newSrc = 'src="./optimized_videos/' + $fileName + '" preload="none"'
        } else {
            $newSrc = 'src="./optimized_videos/' + $fileName + '" preload="metadata" loading="lazy"'
        }
        
        $content = $content.Replace($m.Value, $newSrc)
    }
}

# Write the final result back without BOM so text tools can easily read it
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("portfolio.html", $content, $utf8NoBom)
Write-Host "Success, new portfolio.html is $($content.Length) characters."
