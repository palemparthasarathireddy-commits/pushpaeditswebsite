# upload_to_r2.ps1
# Script to upload optimized videos to Cloudflare R2

# IMPORTANT: Set your R2 details here
$AccountID = "YOUR_ACCOUNT_ID"
$AccessKeyID = "YOUR_ACCESS_KEY_ID"
$SecretAccessKey = "YOUR_SECRET_ACCESS_KEY"
$BucketName = "YOUR_BUCKET_NAME"

# Check for optimized_videos directory
$OutputDir = "optimized_videos"
if (-not (Test-Path $OutputDir)) {
    Write-Host "ERROR: $OutputDir not found!" -ForegroundColor Red
    exit 1
}

$videos = Get-ChildItem -Path $OutputDir -Filter "*.mp4"

if ($videos.Count -eq 0) {
    Write-Host "No videos found in $OutputDir to upload." -ForegroundColor Red
    exit 1
}

Write-Host "Preparing to upload $($videos.Count) videos to R2..." -ForegroundColor Yellow

# Use Wrangler to upload if available, or AWS CLI
# This script assumes you have Cloudflare Wrangler installed: npm install -g wrangler

foreach ($vid in $videos) {
    Write-Host "Uploading $($vid.Name) ..." -ForegroundColor Cyan
    
    # Example command using wrangler r2 (requires wrangler auth or tokens)
    # npx wrangler r2 object put "$BucketName/$($vid.Name)" --file "$($vid.FullName)"
    
    # Or using AWS CLI (S3 compatible)
    # env:AWS_ACCESS_KEY_ID=$AccessKeyID; env:AWS_SECRET_ACCESS_KEY=$SecretAccessKey; 
    # aws s3 cp "$($vid.FullName)" "s3://$BucketName/$($vid.Name)" --endpoint-url "https://$AccountID.r2.cloudflarestorage.com"
}

Write-Host "Upload complete (simulated). Please un-comment the upload commands in the script and set your credentials." -ForegroundColor Green
