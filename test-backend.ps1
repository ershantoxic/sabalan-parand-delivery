$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot\backend"
php artisan test
