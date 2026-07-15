# fix_html_final.ps1
$content = [System.IO.File]::ReadAllText("portfolio.backup.html", [System.Text.Encoding]::UTF8)

# The four lengths of unique base64 encoded videos
$map = @{
    6960042 = "opt_video_1_hero_bg.mp4"
    3958738 = "opt_video_2_portfolio_1.mp4"
    4974738 = "opt_video_3_portfolio_2.mp4"
    11112702 = "opt_video_7_.mp4"
}

# 1. Replace ALL base64 data regardless of HTML or JS location
$pattern = 'data:video/mp4;base64,([A-Za-z0-9+/=]+)'
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
        
        $newSrc = './optimized_videos/' + $fileName
        $content = $content.Replace($m.Value, $newSrc)
    }
}

# 2. Safely inject loading="lazy" preload="metadata" into existing <video> tags
# We will do this specifically for <video ...> that do not have autoplay loop
# Actually, the user asked to ensure HTML snippet: <video controls preload="metadata" width="100%">
# Let's inspect existing tags:
#   <video class="hero-bg-vid" autoplay muted loop playsinline src="..." ...
#   <video id="modalVideo" controls playsinline style="..." src="..." ...

# Simple replace to inject preload and loading where they belong:
$content = $content.Replace('<video class="hero-bg-vid"', '<video class="hero-bg-vid" preload="none"')
$content = $content.Replace('<video id="modalVideo"', '<video id="modalVideo" preload="metadata" loading="lazy"')

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("portfolio.html", $content, $utf8NoBom)
Write-Host "Success, new portfolio.html is $($content.Length) characters."
