# Project Audit — 2026-08-31

## Path and tooling

The project is now located at `C:\delivery-system`, an ASCII path suitable for PHP, Composer, Gradle and Flutter. The prior Persian/space path caused the terminal work-directory creation failure, so using the standard path is required.

## Implemented

- Laravel 12 skeleton with Sanctum, Spatie roles and a Filament panel provider declared.
- Core delivery domain migrations/models: customer, product, order, item, payment, delivery log, code attempt, audit log and settings.
- Visitor ownership policy, login/logout/me API endpoints, order workflow endpoints, hashed delivery codes and payment completion transaction.
- Development log SMS abstraction and demo seeder.
- Flutter app skeleton with Persian strings, RTL locale, secure token storage, Dio headers, login, order list/detail, delivery-code and basic payment flow.

## Incomplete

- Filament has only an Orders resource; required resources, dashboard widgets, reports and detailed order relations are absent.
- Flutter uses a single large `main.dart`, has no repositories/services feature separation, lacks order cache/offline handling, route navigation, dynamic payment fields, delivery-failure UI, correct status workflow and Jalali formatting.
- Android project configuration is incomplete for a reproducible Flutter build (generated Gradle wrapper/assets/tests are absent).
- SMS sending is synchronous and emits raw codes through the log driver without a production-safe environment guard or queue.

## Missing

- Required feature-test suite: authentication, generation/valid/expired/regenerated/reused codes, payment validation, failure workflow, audit validation, and full visitor operation isolation.
- Admin management resources for customers, products, users/visitors, payments, deliveries, attempts, audit logs and settings.
- APK icon/signing example and automation scripts.
- `phpunit.xml` SQLite test configuration verification, `config/permission.php` published config and Sanctum migration verification.

## Needs Fix

- Toolchain unavailable: PHP, Composer, Git, Flutter, Dart and ADB are not installed; installed Java is 9.0.4 and is incompatible with current Android Gradle Plugin requirements.
- No package installer (winget/chocolatey) is available, so safe in-environment setup cannot continue.
- Existing handwritten source cannot yet be compiled; its Laravel/Filament and Flutter compatibility must be validated after dependencies are installed.
- Delivery-code production logging, configurable maximum attempts, request idempotency persistence and state transition rules require strengthening.

## Changes applied during this audit

- Added a Sanctum `personal_access_tokens` migration so token authentication is deployable without relying on an unpublished vendor migration.
- Added configurable delivery-code attempt limit and fixed verification to reject reuse after a successful verification.
- Added repeatable PowerShell helpers: `check-project.ps1`, `setup-backend.ps1`, `run-backend.ps1`, `test-backend.ps1`, `run-mobile.ps1`, and `build-apk.ps1`.
- Added `key.properties.example` and strengthened `.gitignore` for release secrets and IDE-local files.

## Needs Testing

| Check | Status |
| --- | --- |
| Backend install / migration / seeder / tests | NOT RUN — PHP and Composer unavailable |
| Flutter pub get / analyze / tests | NOT RUN — Flutter/Dart unavailable |
| Debug and release APK | NOT RUN — Flutter, Android SDK, ADB and compatible JDK unavailable |
| Filament UI / end-to-end workflow | NOT RUN — backend cannot run |
