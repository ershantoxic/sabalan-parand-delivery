# ساخت APK با GitHub Actions

این پروژه برای ساخت APK به Android SDK محلی وابسته نیست. Workflow از Android SDK از پیش نصب‌شده روی runner `ubuntu-24.04` گیت‌هاب استفاده می‌کند و `sdkmanager` اجرا نمی‌کند.

1. تغییرات را در repository Git commit و push کنید.
2. repository را در GitHub باز کنید.
3. وارد تب **Actions** شوید.
4. workflow با نام **Build Android APK** را انتخاب کنید.
5. روی **Run workflow** کلیک کنید.
6. پس از موفقیت job، بخش **Artifacts** را باز کنید.
7. artifact با نام **sabalan-parand-delivery-apk** را دانلود کنید. فایل داخل آن `app-release.apk` است.

مسیر خروجی workflow: `mobile/build/app/outputs/flutter-apk/app-release.apk`.

تا زمانی که keystore تولید در GitHub Secrets قرار نگرفته، build release با امضای debug استاندارد Gradle در CI انجام می‌شود. هیچ keystore، گذرواژه یا فایل `key.properties` در repository قرار نمی‌گیرد.
