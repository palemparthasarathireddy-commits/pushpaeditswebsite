# compress_videos.ps1
# Compresses the extracted videos to optimal web formats using FFmpeg

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$InputDir = "extracted_videos"
$OutputDir = "optimized_videos"

Write-Host "=== Video Compressor ===" -ForegroundColor Cyan

if (-not (Test-Path $InputDir)) {
    Write-Host "ERROR: $InputDir not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$videos = Get-ChildItem -Path $InputDir -Filter "*.mp4"

if ($videos.Count -eq 0) {
    Write-Host "No videos found in $InputDir to compress." -ForegroundColor Red
    exit 1
}

Write-Host "Found $($videos.Count) videos to compress." -ForegroundColor Yellow

foreach ($vid in $videos) {
    $outPath = Join-Path $OutputDir ("opt_" + $vid.Name)
    Write-Host ""
    Write-Host "Compressing $($vid.Name) ..." -ForegroundColor Cyan
    
    # We use very fast preset for testing, but good web compression
    # -vcodec libx264 -crf 28 -preset fast -vf scale=-2:720 -pix_fmt yuv420p -an (for hero)
    # or -acodec aac -b:a 128k (for others)
    
    $isHero = $vid.Name -match "hero_bg"
    
    $args = @(
        "-y", # overwrite output
        "-i", $vid.FullName,
        "-vcodec", "libx264",
        "-crf", "28",
        "-preset", "fast",
        "-vf", "scale=-2:720",
        "-pix_fmt", "yuv420p"
    )
    
    if ($isHero) {
        # Mute and optimize hero background loop
        $args += "-an"
    } else {
        # Keep audio for other videos
        $args += "-acodec"
        $args += "aac"
        $args += "-b:a"
        $args += "128k"
    }
    
    $args += $outPath
    
    try {
        & ffmpeg @args
        $oldSize = [Math]::Round($vid.Length / 1MB, 2)
        $newSize = [Math]::Round((Get-Item $outPath).Length / 1MB, 2)
        Write-Host "  OK: Reduced from $oldSize MB to $newSize MB" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR compressing $($vid.Name): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Compression Complete ===" -ForegroundColor Cyan
Write-Host "Optimized files are in ./$OutputDir/" -ForegroundColor Green
Get-ChildItem $OutputDir | ForEach-Object {
    Write-Host "  $($_.Name) - $([Math]::Round($_.Length/1MB,2)) MB"
}
