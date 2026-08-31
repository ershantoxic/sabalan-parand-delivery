# Windows toolchain installation

Install to ASCII-only paths, then close and reopen PowerShell before verification. Do not install Flutter, PHP, or the Android SDK inside the project directory.

## 1. PHP and Composer

1. Download the current PHP 8.4 x64 Thread Safe ZIP from [windows.php.net/download](https://windows.php.net/download/), extract it to `C:\tools\php84`.
2. Copy `php.ini-development` to `php.ini`; enable `extension=curl`, `extension=fileinfo`, `extension=mbstring`, `extension=openssl`, `extension=pdo_mysql`, `extension=pdo_sqlite`, `extension=sqlite3`, `extension=zip` and configure `extension_dir = "ext"`.
3. Add `C:\tools\php84` to the user PATH.
4. Install Composer from [getcomposer.org/download](https://getcomposer.org/download/), selecting `C:\tools\php84\php.exe` when prompted.
5. Verify: `php --version` and `composer --version`.

## 2. Git

Install current Git for Windows from [git-scm.com/download/win](https://git-scm.com/download/win), choose the option to add Git to PATH, then run `git --version`.

## 3. Flutter and Android Studio

1. Extract the stable Flutter SDK from [docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows) to `C:\src\flutter`.
2. Add `C:\src\flutter\bin` to user PATH. Run `flutter --version` and `dart --version`.
3. Install current Android Studio from [developer.android.com/studio](https://developer.android.com/studio). In SDK Manager install: Android SDK Platform, Build-Tools, Command-line Tools and Platform-Tools. Let Flutter use Android Studio's bundled JDK (17+); do not retain Java 9 as `JAVA_HOME`.
4. Add `%LOCALAPPDATA%\Android\Sdk\platform-tools` to PATH, and set `ANDROID_SDK_ROOT` to `%LOCALAPPDATA%\Android\Sdk`.
5. Run `flutter doctor -v`, then `flutter doctor --android-licenses` and accept all prompts.

## 4. Continue this project

Open a new PowerShell window and run:

```powershell
Set-Location C:\delivery-system
.\check-project.ps1
.\setup-backend.ps1
Set-Location .\backend
php artisan migrate:fresh --seed
php artisan test
Set-Location ..\mobile
flutter clean
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

The project uses `ir.sabalanparand.delivery` as the intended Android package identifier. After the toolchain is available, first fix actual command errors before reporting any item as PASS.
