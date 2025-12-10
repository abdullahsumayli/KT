$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$frontendPath = Join-Path $repoRoot "frontend\kitchentech_app"
$docsPath = Join-Path $repoRoot "docs"

Write-Host "Building Flutter web..." -ForegroundColor Cyan

Push-Location $frontendPath
flutter build web --release --base-href /KT/
Pop-Location

Write-Host "Syncing build/web -> docs/ ..." -ForegroundColor Cyan

if (!(Test-Path $docsPath)) {
    New-Item -ItemType Directory -Path $docsPath | Out-Null
}

Get-ChildItem $docsPath -Exclude "*.md", "wireframes" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

$buildWebPath = Join-Path $frontendPath "build\web"
Copy-Item "$buildWebPath\*" $docsPath -Recurse -Force

Write-Host "Done! Next steps:" -ForegroundColor Green
Write-Host "   git add docs" -ForegroundColor Yellow
Write-Host "   git commit -m 'Deploy KitchenTech Flutter Web'" -ForegroundColor Yellow
Write-Host "   git push" -ForegroundColor Yellow
Write-Host ""
Write-Host "Your app will be live at:" -ForegroundColor Cyan
Write-Host "   https://abdullahsumayli.github.io/KT/" -ForegroundColor White
