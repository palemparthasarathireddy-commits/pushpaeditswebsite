# extract_videos.ps1
# Extracts base64-encoded videos from portfolio.html into real .mp4 files

param(
    [string]$HtmlFile = "portfolio.html",
    [string]$OutputDir = "extracted_videos"
)

Write-Host "=== Video Extractor ===" -ForegroundColor Cyan
Write-Host "Reading $HtmlFile ..." -ForegroundColor Yellow

if (-not (Test-Path $HtmlFile)) {
    Write-Host "ERROR: $HtmlFile not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$content = Get-Content $HtmlFile -Raw -Encoding UTF8
Write-Host "File loaded: $([Math]::Round($content.Length / 1MB, 1)) MB" -ForegroundColor Green

$pattern = 'data:video/mp4;base64,([A-Za-z0-9+/=]+)'
$videoMatches = [regex]::Matches($content, $pattern)

Write-Host "Found $($videoMatches.Count) embedded video(s)" -ForegroundColor Cyan

if ($videoMatches.Count -eq 0) {
    Write-Host "No base64 videos found. Exiting." -ForegroundColor Red
    exit 1
}

$videoNames = @("hero_bg", "portfolio_1", "portfolio_2", "portfolio_3", "portfolio_4", "portfolio_5")

$absOutputDir = (Resolve-Path $OutputDir).Path

$i = 0
foreach ($m in $videoMatches) {
    $b64 = $m.Groups[1].Value
    $name = $videoNames[$i]
    $outFull = "$absOutputDir\video_$($i+1)_$name.mp4"

    Write-Host ""
    Write-Host "Extracting Video $($i+1) ($name)..." -ForegroundColor Yellow
    Write-Host "  Base64 chars: $($b64.Length)"
    Write-Host "  Estimated size: $([Math]::Round($b64.Length * 3 / 4 / 1MB, 1)) MB"
    Write-Host "  Output: $outFull"

    try {
        $bytes = [Convert]::FromBase64String($b64)
        [System.IO.File]::WriteAllBytes($outFull, $bytes)
        $actualSize = [Math]::Round((Get-Item $outFull).Length / 1MB, 1)
        Write-Host "  OK Saved: $actualSize MB" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: $_" -ForegroundColor Red
    }

    $i++
}

Write-Host ""
Write-Host "=== Extraction Complete ===" -ForegroundColor Cyan
Get-ChildItem $OutputDir | ForEach-Object {
    Write-Host "  $($_.Name) - $([Math]::Round($_.Length/1MB,1)) MB"
}
