# سامانه مدیریت تحویل سفارش

سامانهٔ production-oriented برای تحویل سفارش توسط ویزیتور/راننده: Laravel 12 API + Filament Admin + Flutter Android. رابط موبایل فارسی و RTL است و کد تحویل خام هرگز در API بازگردانده نمی‌شود.

## پیش‌نیازها

- PHP 8.2 یا جدیدتر، Composer 2، MySQL 8، Node 20 (برای assetهای پنل)
- Flutter stable (Dart 3.3+) و Android SDK/JDK 17

## نصب Backend

```powershell
cd backend
copy .env.example .env
composer install
php artisan key:generate
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan migrate --seed
php artisan serve
```

در `.env` نام دیتابیس، مشخصات MySQL، `APP_URL` و متغیرهای SMS را تعیین کنید. پیاده‌سازی فعلی SMS در development از `log` استفاده می‌کند؛ برای Kavenegar/SMS.ir/FarazSMS یک کلاس مطابق `SmsService` بسازید و binding را در `AppServiceProvider` تغییر دهید.

ورود نمونه: `09120000000` / `Password123!` (Super Admin)، یا `09120000001` تا `...003` با همان رمز برای ویزیتورها. پنل دفتر در `http://127.0.0.1:8000/admin` است.

## API و امنیت

Base URL توسعه: `http://10.0.2.2:8000/api`. تمام endpointها پاسخ استاندارد `success/message/data` دارند. Visitor/Driver فقط به سفارش خودش دسترسی دارد و این کنترل با `OrderPolicy` نیز روی مسیر جزئیات و عملیات تحویل اعمال می‌شود. کد ۶ رقمی فقط هش شده، ۲۴ ساعته، یک‌بارمصرف، rate-limited و پس از ۵ خطا قفل می‌شود. صدور مجدد، هش قبلی را جایگزین می‌کند. هر عملیات حساس در `delivery_logs` یا `audit_logs` ثبت می‌شود.

## اجرای Flutter و APK

```powershell
cd mobile
flutter pub get
flutter analyze
flutter build apk --release
```

APK خروجی: `mobile/build/app/outputs/flutter-apk/app-release.apk`.

برای امضای release، فایل `android/key.properties` (که نباید commit شود) با `storeFile`، `storePassword`، `keyAlias` و `keyPassword` بسازید و signing config استاندارد Android را به `android/app/build.gradle` وصل کنید. پیش از release مقدار `AppConfig.environment` را `production` و URL تولید را تغییر دهید. برای Android Emulator از `10.0.2.2` و برای گوشی واقعی از IP/LAN یا دامنه HTTPS سرور استفاده کنید.

## بررسی کیفیت

```powershell
cd backend; php artisan test
cd ..\mobile; flutter analyze; flutter test; flutter build apk --release
```

محیط تحویل فعلی PHP/Composer/Flutter/Android SDK ندارد؛ بنابراین اجرای واقعی این دستورها و ایجاد APK در همین workspace ممکن نبوده است. پیش از استقرار، این سه دستور باید در CI یا ماشین دارای پیش‌نیازها سبز شوند.
