Set-Location "d:\KT\frontend\kitchentech_app\build\web"
Write-Host "Starting HTTP Server from: $PWD"
Write-Host "Server will be available at: http://localhost:8080"
Write-Host "Press Ctrl+C to stop the server"
python -m http.server 8080
