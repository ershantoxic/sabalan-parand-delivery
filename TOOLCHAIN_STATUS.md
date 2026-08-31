# Toolchain Status — 2026-08-31

The following commands were executed in PowerShell from `C:\delivery-system`.

| Tool | Command | Status | Observed result |
| --- | --- | --- | --- |
| PHP | `php --version` | FAIL | Command not found |
| Composer | `composer --version` | FAIL | Command not found |
| Git | `git --version` | FAIL | Command not found |
| Flutter | `flutter --version` | FAIL | Command not found |
| Dart | `dart --version` | FAIL | Command not found |
| Java | `java --version` | FAIL | Java 9.0.4 is installed; it is not compatible with the Android Gradle Plugin configured for this project |
| ADB | `adb --version` | FAIL | Command not found |
| Android SDK | `flutter doctor -v` | NOT RUN | Flutter command is unavailable |
| Android licences | `flutter doctor --android-licenses` | NOT RUN | Flutter command is unavailable |

Neither `winget` nor Chocolatey is installed. No backend, Flutter, APK, or integration command has been run in this phase because required executables are unavailable.
