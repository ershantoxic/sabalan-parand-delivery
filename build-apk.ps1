$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot\mobile"
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=APP_ENV=production
Write-Host "APK: $PSScriptRoot\mobile\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
