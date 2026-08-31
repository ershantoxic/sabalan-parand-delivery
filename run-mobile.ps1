$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot\mobile"
flutter pub get
flutter run --dart-define=APP_ENV=development
