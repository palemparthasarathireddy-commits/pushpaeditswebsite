$content = [System.IO.File]::ReadAllText("portfolio.html", [System.Text.Encoding]::UTF8)
$pattern = '(?s)(const\s+videoSrcs\s*=\s*\{.*?})'
$match = [regex]::Match($content, $pattern)
if ($match.Success) {
    Write-Host "Found videoSrcs:"
    Write-Host $match.Value.Substring(0, [Math]::Min($match.Value.Length, 800))
} else {
    Write-Host "Not found"
}
