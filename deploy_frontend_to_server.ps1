$ErrorActionPreference = "Stop"

$SERVER = "root@91.99.106.230"
$REMOTE_PATH = "/var/www/souqmatbakh/frontend"
$LOCAL_BUILD = "frontend\kitchentech_app\build\web"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deploy Frontend to souqmatbakh.com" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Build Flutter for production
Write-Host "[1/4] Building Flutter..." -ForegroundColor Yellow
Push-Location "frontend\kitchentech_app"
flutter build web --release
Pop-Location
Write-Host "Done building" -ForegroundColor Green
Write-Host ""

# 2. Create temporary archive
Write-Host "[2/4] Creating archive..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$archiveName = "frontend_$timestamp.zip"
Compress-Archive -Path "$LOCAL_BUILD\*" -DestinationPath $archiveName -Force
Write-Host "Done: $archiveName" -ForegroundColor Green
Write-Host ""

# 3. Upload to server
Write-Host "[3/4] Uploading to server..." -ForegroundColor Yellow
scp $archiveName "${SERVER}:/tmp/"
Write-Host "Done uploading" -ForegroundColor Green
Write-Host ""

# 4. Extract on server and restart nginx
Write-Host "[4/4] Extracting and reloading nginx..." -ForegroundColor Yellow
ssh $SERVER "cd /tmp && sudo rm -rf /var/www/souqmatbakh/frontend/* && sudo unzip -o -q $archiveName -d /var/www/souqmatbakh/frontend/ && sudo chown -R www-data:www-data /var/www/souqmatbakh/frontend && sudo systemctl reload nginx && rm $archiveName && echo 'Done'"
Write-Host ""

# Cleanup local archive
Remove-Item $archiveName -Force

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Deploy completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Website: https://souqmatbakh.com" -ForegroundColor Cyan
Write-Host ""
