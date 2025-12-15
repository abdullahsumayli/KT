$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Deploy Landing Page to souqmatbakh.com" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$SERVER = "root@91.99.106.230"

# Step 1: Upload index.html
Write-Host "[1/4] Uploading index.html..." -ForegroundColor Yellow
scp "d:\KT\deploy\landing\index.html" "${SERVER}:/tmp/"
Write-Host "Done" -ForegroundColor Green
Write-Host ""

# Step 2: Upload nginx config
Write-Host "[2/4] Uploading Nginx config..." -ForegroundColor Yellow
scp "d:\KT\deploy\nginx\souqmatbakh.com.conf" "${SERVER}:/tmp/"
Write-Host "Done" -ForegroundColor Green
Write-Host ""

# Step 3: Execute setup on server
Write-Host "[3/4] Setting up on server..." -ForegroundColor Yellow
ssh $SERVER "sudo mkdir -p /var/www/souqmatbakh/landing && sudo mv /tmp/index.html /var/www/souqmatbakh/landing/ && sudo chown -R www-data:www-data /var/www/souqmatbakh/landing && sudo chmod 644 /var/www/souqmatbakh/landing/index.html && sudo cp /etc/nginx/sites-available/souqmatbakh.com /etc/nginx/sites-available/souqmatbakh.com.backup && sudo mv /tmp/souqmatbakh.com.conf /etc/nginx/sites-available/souqmatbakh.com && sudo chown root:root /etc/nginx/sites-available/souqmatbakh.com && sudo chmod 644 /etc/nginx/sites-available/souqmatbakh.com && echo 'Setup complete'"
Write-Host "Done" -ForegroundColor Green
Write-Host ""

# Step 4: Test and reload Nginx
Write-Host "[4/4] Testing and reloading Nginx..." -ForegroundColor Yellow
ssh $SERVER "sudo nginx -t && sudo systemctl reload nginx && echo 'Nginx reloaded successfully'"
Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host "  Landing page deployed successfully!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Landing page available at:" -ForegroundColor Cyan
Write-Host "  https://souqmatbakh.com/landing/" -ForegroundColor White
Write-Host ""
