$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot\backend"
if (-not (Get-Command php -ErrorAction SilentlyContinue)) { throw 'PHP 8.2+ is required.' }
if (-not (Get-Command composer -ErrorAction SilentlyContinue)) { throw 'Composer 2 is required.' }
composer install
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
php artisan key:generate
Write-Host 'Configure MySQL values in backend/.env, then run: php artisan migrate --seed' -ForegroundColor Yellow
