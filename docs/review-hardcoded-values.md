# Code Review — Hardcoded Values

**Reviewed:** 2026-06-30  
**Branch:** quick-dev  
**Reviewer:** Amelia (Dev Agent)  
**Scope:** Các giá trị hardcode cần tách ra config/env trước khi ship  

---

## Tóm tắt

| ID | Priority | File | Vấn đề |
|---|---|---|---|
| HCV-001 | 🔴 Critical | `ad_service.dart:6,133` | Google test Ad Unit IDs — không swap tự động theo build flavor |
| HCV-002 | 🔴 Critical | `main.dart:33` | AppLovin SDK key là empty string |
| HCV-003 | 🟠 High | 5 chỗ | Package ID + Play Store URL lặp lại |
| HCV-004 | 🟠 High | `settings_screen.dart:71` | Email support hardcode trong UI widget |
| HCV-005 | 🟠 High | `iap_service.dart:4` | IAP product ID hardcode |
| HCV-006 | 🟡 Medium | 2 file | MethodChannel name khai báo trùng |
| HCV-007 | 🟡 Medium | `strings_en.dart:59`, `strings_vi.dart:59` | Giá IAP hardcode thay vì fetch từ store |

---

## Chi tiết

### HCV-001 — Google test Ad Unit IDs

**File:** `lib/core/services/ad_service.dart`

```dart
// Line 6
const String _kRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

// Line 133
static const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
```

**Rủi ro:** Ship Google test ads lên production — toàn bộ ad revenue = 0  
**Fix:** Đưa vào `dart-define`, tách biệt debug/release

```dart
// app_config.dart
static const String rewardedAdUnitId = String.fromEnvironment(
  'REWARDED_AD_UNIT_ID',
  defaultValue: 'ca-app-pub-3940256099942544/5224354917', // test fallback
);
```

---

### HCV-002 — AppLovin SDK key là empty string

**File:** `lib/main.dart`

```dart
// Line 33
await adService.initialize(''); // DEV: swap to AppLovin key when shipping
```

**Rủi ro:** Ads SDK không khởi tạo được khi release → mất toàn bộ ad revenue  
**Fix:** dart-define + assert non-empty khi release build

```dart
static const String appLovinSdkKey = String.fromEnvironment('APPLOVIN_SDK_KEY');
// Trong main(): assert(!kReleaseMode || appLovinSdkKey.isNotEmpty, 'APPLOVIN_SDK_KEY missing');
```

---

### HCV-003 — Package ID + Play Store URL lặp ở 5 chỗ

**Files:**

| File | Dòng | Value |
|---|---|---|
| `settings_screen.dart` | 80 | `https://play.google.com/store/apps/details?id=com.studio.diy_wallpaper` |
| `settings_screen.dart` | 255 | `com.studio.diy_wallpaper` |
| `share_screen.dart` | 164 | `https://play.google.com/store/apps/details?id=com.studio.diy_wallpaper` |
| `share_screen.dart` | 205 | `https://play.google.com/store/apps/details?id=com.studio.diy_wallpaper` |

**Rủi ro:** Đổi package ID → phải sửa thủ công 5 chỗ, dễ miss  
**Fix:** `AppConstants.packageId` + `AppConstants.playStoreUrl`

---

### HCV-004 — Email support hardcode trong UI

**File:** `lib/features/settings/settings_screen.dart`

```dart
// Line 71
final uri = Uri.parse('mailto:claudecell04@gmail.com?subject=DIY Wallpaper Feedback');
```

**Rủi ro:** Đổi email support → phải tìm trong widget code  
**Fix:** `AppConstants.supportEmail = 'claudecell04@gmail.com'`

---

### HCV-005 — IAP product ID hardcode

**File:** `lib/core/services/iap_service.dart`

```dart
// Line 4
const kPremiumProductId = 'com.studio.diy_wallpaper.premium';
```

**Rủi ro:** Thêm subscription tier / bundle → không có nơi quản lý tập trung  
**Fix:** `AppConstants.iapPremiumId` — hoặc `enum IapProduct` nếu nhiều sản phẩm

---

### HCV-006 — MethodChannel name khai báo trùng

**Files:**

```dart
// wallpaper_service.dart:7
const MethodChannel _pickerChannel = MethodChannel('com.studio.diy_wallpaper/wallpaper');

// miui_service.dart:5
static const _channel = MethodChannel('com.studio.diy_wallpaper/wallpaper');
```

**Rủi ro:** Native side đổi channel name → phải nhớ update 2 file Dart riêng biệt  
**Fix:** Extract `const kWallpaperChannel = 'com.studio.diy_wallpaper/wallpaper'` vào `AppConstants`

---

### HCV-007 — Giá IAP hardcode trong l10n

**Files:**

```dart
// strings_en.dart:59
String get premiumLifetimePrice => '29.000 ₫ / lifetime';

// strings_vi.dart:59
String get premiumLifetimePrice => '29.000 ₫ / trọn đời';
```

**Rủi ro:** Đổi giá trên Play Console → UI hiển thị giá sai cho user  
**Fix:** Fetch `ProductDetails.price` từ `IapService.fetchProduct()`, render dynamic

---

## Đề xuất fix order

```
HCV-007  →  HCV-002  →  HCV-001  →  HCV-006  →  HCV-003 + HCV-004 + HCV-005
(l10n)      (SDK key)   (Ad IDs)    (channel)   (bundle vào AppConstants)
```

## Proposed solution

Tạo 2 file mới:

```
lib/core/constants/app_constants.dart   ← packageId, playStoreUrl, email, iapIds, channelName
lib/core/config/app_config.dart         ← dart-define wrappers (ad unit IDs, SDK key)
```

Không commit secrets vào source — truyền qua `--dart-define` khi build.
