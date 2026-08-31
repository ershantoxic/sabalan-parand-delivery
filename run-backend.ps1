$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot\backend"
php artisan serve --host=0.0.0.0 --port=8000
