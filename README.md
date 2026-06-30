# DIY Wallpaper — Build Guide

Hướng dẫn setup và build từ dev → preview → production.

---

## Mục lục

1. [Prerequisites](#1-prerequisites)
2. [Setup lần đầu](#2-setup-lần-đầu)
3. [Dev Build](#3-dev-build)
4. [Preview Build](#4-preview-build-apk-nội-bộ)
5. [Production Build](#5-production-build-play-store)
6. [Splash Screen](#6-cập-nhật-splash-screen)
7. [Dart Define Reference](#7-dart-define-reference)

---

## 1. Prerequisites

| Tool | Version tối thiểu | Ghi chú |
|------|-------------------|---------|
| Flutter SDK | 3.22+ | `flutter --version` |
| Dart SDK | 3.0+ | đi kèm Flutter |
| Java (JDK) | 17 | `java -version` |
| Android SDK | API 24+ | via Android Studio |
| Firebase CLI | latest | `npm install -g firebase-tools` |

```bash
# Kiểm tra môi trường
flutter doctor -v
```

---

## 2. Setup lần đầu

### 2.1 Clone & install dependencies

```bash
git clone <repo-url>
cd theme-project
flutter pub get
```

### 2.2 Code generation (Hive adapters + Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

> Chạy lại mỗi khi thêm `@HiveType`, `@riverpod`, hoặc thay đổi model.

### 2.3 Đặt `google-services.json`

File này **không được commit** (gitignored). Lấy từ Firebase Console → Project Settings → Android app.

```
<project-root>/
├── google-services.json   ← đặt tại đây (ROOT, không phải android/app/)
├── android/
│   └── app/
│       └── google-services.json  ← tự động copy khi build (đừng sửa file này)
```

> Gradle task `copyGoogleServices` tự copy trước mỗi build. Không cần làm thủ công.

### 2.4 Signing key (chỉ cần cho Preview & Production)

Tạo keystore nếu chưa có:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Tạo file `android/key.properties` (gitignored):

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=upload-keystore.jks
```

> ⚠️ Giữ keystore + key.properties an toàn. Mất file này = không thể update app trên Play Store.

### 2.5 Biến môi trường — Ad Unit IDs

Ad unit IDs được truyền qua `--dart-define`. Tạo file `.env.local` để lưu (gitignored):

```bash
# .env.local — KHÔNG commit file này
REWARDED_AD_UNIT_ID=ca-app-pub-xxxxx/yyyyy
NATIVE_AD_UNIT_ID=ca-app-pub-xxxxx/yyyyy
BANNER_AD_UNIT_ID=ca-app-pub-xxxxx/yyyyy
APPLOVIN_SDK_KEY=your_applovin_sdk_key_here
```

---

## 3. Dev Build

Dùng **Google test ad IDs** (mặc định trong `AppConfig`). Không cần `--dart-define`.

### 3.1 Run trên device thật

```bash
flutter run
```

Chọn device nếu có nhiều:

```bash
flutter devices          # xem danh sách
flutter run -d <device-id>
```

### 3.2 Run với hot reload

Khi đang chạy, nhấn:
- `r` — hot reload
- `R` — hot restart
- `q` — quit

### 3.3 Kiểm tra Analytics (DebugView)

```bash
# Bật Firebase DebugView trên device đang kết nối
adb shell setprop debug.firebase.analytics.app com.studio.diy_wallpaper

# Tắt
adb shell setprop debug.firebase.analytics.app .none.
```

Sau đó vào: **Firebase Console → Analytics → DebugView**

> Kill app rồi relaunch sau khi set property — Firebase đọc property lúc khởi động.

### 3.4 Xem Analytics logs trong console

```bash
adb logcat -s FA FA-SVC
```

---

## 4. Preview Build (APK nội bộ)

> ⚠️ **KHÔNG dùng real ad unit IDs cho bản nội bộ.** Testers click ads thật → Google đếm
> là invalid clicks → tài khoản AdMob bị suspend. Dùng **Google test IDs** (mặc định)
> kết hợp **test device IDs** để verify ad placement mà không vi phạm policy.

### 4.1 Lấy test device ID

Chạy app debug một lần, xem logcat:

```bash
adb logcat | grep "Use RequestConfiguration"
# Output: Use RequestConfiguration.Builder().setTestDeviceIds(["XXXXXXXX"])
```

Truyền ID qua `--dart-define` khi build (không cần sửa code):

```bash
flutter build apk --release \
  --dart-define=TEST_DEVICE_IDS=XXXXXXXX \
  --dart-define=REWARDED_AD_UNIT_ID=<real-id> \
  --dart-define=NATIVE_AD_UNIT_ID=<real-id> \
  --dart-define=BANNER_AD_UNIT_ID=<real-id> \
  --dart-define=APPLOVIN_SDK_KEY=<sdk-key>
```

Nếu có nhiều device:

```bash
--dart-define=TEST_DEVICE_IDS=XXXXXXXX,YYYYYYYY,ZZZZZZZZ
```

> `main.dart` tự parse danh sách và gọi `MobileAds.instance.updateRequestConfiguration`.
> Nếu không truyền `TEST_DEVICE_IDS` → bỏ qua, không gọi gì cả.
> Với test device ID: ads hiển thị đúng format/size như production, clicks không bị count.

### 4.2 Build APK (test IDs — an toàn với policy)

```bash
# Không cần --dart-define ad IDs — AppConfig tự dùng Google test IDs làm fallback
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 4.2 Phân phối qua Firebase App Distribution

```bash
# Login Firebase (lần đầu)
firebase login

# Upload lên Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <firebase-android-app-id> \
  --groups "internal-testers" \
  --release-notes "Preview build $(date +%Y-%m-%d)"
```

Hoặc build + distribute 1 lệnh (cần `google-services.json` và Firebase plugin trong gradle):

```bash
cd android && ./gradlew assembleRelease appDistributionUploadRelease
```

### 4.3 Kiểm tra trước khi approve preview

- [ ] Analytics events hiện trong Firebase DebugView
- [ ] Banner/Rewarded/Native ads load được
- [ ] IAP flow hoạt động (test account)
- [ ] Splash screen đúng trên Android 12+
- [ ] Không có crash trên Logcat

---

## 5. Production Build (Play Store)

### 5.1 Cập nhật version

Trong `pubspec.yaml`:

```yaml
version: 1.0.1+2   # format: versionName+versionCode
#         ^^^^^  versionName (hiển thị cho user)
#               ^ versionCode (số nguyên, tăng dần mỗi release)
```

### 5.2 Cập nhật signing config

Trong `android/app/build.gradle`, đổi signing release từ debug sang upload key:

```groovy
signingConfigs {
    release {
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release   // ← đổi từ signingConfigs.debug
        // ...
    }
}
```

Và thêm đầu file `build.gradle`:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

### 5.3 Build AAB

```bash
flutter build appbundle --release \
  --dart-define=REWARDED_AD_UNIT_ID=<real-id> \
  --dart-define=NATIVE_AD_UNIT_ID=<real-id> \
  --dart-define=BANNER_AD_UNIT_ID=<real-id> \
  --dart-define=APPLOVIN_SDK_KEY=<sdk-key>
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 5.4 Upload lên Play Console

1. Vào [Play Console](https://play.google.com/console) → chọn app
2. Production → Create new release
3. Upload `app-release.aab`
4. Fill release notes
5. Review → Start rollout

### 5.5 Tên app

| Nơi hiển thị | Tên | Chỉnh ở đâu |
|-------------|-----|-------------|
| Icon launcher (trên phone) | **DIY Themes** | `android/app/src/main/res/values/strings.xml` → `app_name` |
| Android task switcher | **DIY Themes** | `lib/main.dart` → `MaterialApp.title` |
| Play Store listing | **DIY Wall: Gamer & Cool Themes** | Play Console → Store listing → App name |

> Play Store title không liên quan đến code — đổi trực tiếp trên Play Console.

### 5.6 Checklist trước khi submit

- [ ] `versionCode` tăng so với release trước
- [ ] Signing config dùng upload key (không phải debug)
- [ ] Không có Google test ad IDs (`ca-app-pub-3940256099942544/...`)
- [ ] `AppLovin SDK key` không rỗng
- [ ] Play Store listing title: **DIY Wall: Gamer & Cool Themes**
- [ ] Privacy policy URL đã cập nhật trong settings_screen
- [ ] Release notes điền đầy đủ

---

## 6. Cập nhật Splash Screen

Khi thay đổi `assets/splash_logo.png` hoặc `assets/splash_logo_12.png`:

```bash
dart run flutter_native_splash:create
```

File được cấu hình trong `flutter_native_splash.yaml`:
- `image` — splash pre-Android 12
- `android_12.image` — splash Android 12+ (icon trong vòng tròn)

> Sau khi chạy lệnh, rebuild app để thấy thay đổi.

---

## 7. Dart Define Reference

| Key | Mô tả | Fallback (dev) |
|-----|-------|----------------|
| `REWARDED_AD_UNIT_ID` | Rewarded video ad unit | Google test ID |
| `NATIVE_AD_UNIT_ID` | Native ad unit (gallery) | Google test ID |
| `BANNER_AD_UNIT_ID` | Banner ad unit | Google test ID |
| `APPLOVIN_SDK_KEY` | AppLovin MAX SDK key | `""` (Google Ads fallback) |
| `TEST_DEVICE_IDS` | Comma-separated test device IDs | `""` (không đăng ký) |

Định nghĩa tập trung tại: `lib/core/config/app_config.dart`

Constants (package ID, email, IAP, channel): `lib/core/constants/app_constants.dart`

---

## Tóm tắt flow

```
Dev                Preview                    Production
────────────       ──────────────────────     ──────────────────────
flutter run    →   flutter build apk      →   flutter build appbundle
(test ads)         (test ads + device ID)      (real ads + upload key)
                   firebase distribute          Play Console upload
```

> Rule: **Real ad IDs chỉ được phép trong production build.** Dev + Preview luôn dùng test IDs.
