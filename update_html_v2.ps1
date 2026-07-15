# update_html_v2.ps1
$HtmlFile = "portfolio.html"
$content = Get-Content $HtmlFile -Raw -Encoding UTF8

$cdnBase = "https://YOUR-R2-BUCKET-URL.r2.dev"

Write-Host "Updating HTML..."

$pattern = 'data:video/mp4;base64,([A-Za-z0-9+/=]+)'
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
        
        $newSrc = $cdnBase + '/' + $fileName
        
        # Replace the base64 string directly in the content
        $content = $content.Replace($m.Value, $newSrc)
    }
}

[System.IO.File]::WriteAllText((Resolve-Path .).Path + "\portfolio.cleaned.html", $content, [System.Text.Encoding]::UTF8)

Write-Host "Replaced $( $matches.Count ) base64 elements."
Write-Host "New file size: $( [Math]::Round( (Get-Item portfolio.cleaned.html).Length / 1KB ) ) KB"
