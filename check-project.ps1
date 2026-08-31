$ErrorActionPreference = 'Continue'
$tools = @('php','composer','git','flutter','dart','java','adb')
Write-Host "Delivery System environment check" -ForegroundColor Cyan
foreach ($tool in $tools) {
    $command = Get-Command $tool -ErrorAction SilentlyContinue
    if ($null -eq $command) { Write-Host "[MISSING] $tool" -ForegroundColor Yellow; continue }
    Write-Host "[FOUND]   $tool -> $($command.Source)" -ForegroundColor Green
    & $tool --version 2>&1 | Select-Object -First 2
}
if (Get-Command flutter -ErrorAction SilentlyContinue) { flutter doctor -v }
