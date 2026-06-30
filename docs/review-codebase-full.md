# Code Review — Full Codebase

**Reviewed:** 2026-06-30  
**Branch:** quick-dev  
**Reviewer:** Amelia (Dev Agent)  
**Scope:** Toàn bộ lib/ — logic bugs, crash, analytics, architecture, best practices  
**Status:** Log only — chưa fix gì

---

## Tóm tắt

| ID | Priority | File | Vấn đề |
|---|---|---|---|
| BUG-001 | 🔴 Crash | `loading_screen.dart:2,53` | `flutter_native_splash` import nhưng không có trong pubspec |
| BUG-002 | 🟠 Logic | `home_screen.dart:260`, `gallery_screen.dart:308` | Toast yêu thích logic ngược |
| BUG-003 | 🟠 Analytics | `reward_modal.dart:156` | `isFirstUnlock` luôn hardcode `true` |
| BUG-004 | 🟠 Analytics | `gallery_screen.dart:169` | `logWallpaperSetAs` hardcode `homeScreen` |
| BUG-005 | 🟠 Reliability | `share_screen.dart:53` | Silent catch nuốt lỗi copy file |
| BUG-006 | 🟠 State | `gallery_screen.dart:100-108` | `_themes` không reactive sau đổi filter |
| BUG-007 | 🟡 Memory | `garage_screen.dart:86` | Temp PNG không được xóa sau khi dùng |
| BUG-008 | 🟡 Observability | `pubspec.yaml` | Thiếu Firebase Crashlytics |
| BUG-009 | 🟡 Pattern | `home_screen.dart:94` | `WidgetRef` truyền qua constructor |
| BUG-010 | 🟡 Arch | `garage_screen.dart:219`, `share_screen.dart:94` | SharedPreferences trực tiếp trong UI layer |
| BUG-011 | 🟡 Provider | `theme_state_provider.dart:12` | `Future.microtask` trong `build()` |

> Xem thêm: `docs/review-hardcoded-values.md` — 7 findings riêng về hardcoded config/env (HCV-001 → HCV-007)

---

## Chi tiết

---

### BUG-001 — flutter_native_splash không có trong pubspec

**Severity:** 🔴 Crash  
**File:** `lib/features/loading/loading_screen.dart`

```dart
// Line 2
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Line 53
FlutterNativeSplash.remove();
```

**Vấn đề:** Package `flutter_native_splash` không có trong `pubspec.yaml` → compile error / crash ngay khi launch.  
**Fix:** Thêm `flutter_native_splash: ^2.4.0` vào pubspec, hoặc xóa import và dùng cơ chế khác (delay + navigate).

---

### BUG-002 — Toast yêu thích logic ngược

**Severity:** 🟠 Logic Bug  
**Files:**
- `lib/features/home/home_screen.dart:260`
- `lib/features/gallery/gallery_screen.dart:308`

```dart
// home_screen.dart:260
CyberToast.show(
  context,
  theme.isFavorite ? s.removedFromFavorites : s.addedToFavorites,
  // ^^^ đọc TRƯỚC khi toggle → ngược
);
ref.read(themeStateProvider.notifier).toggleFavorite(theme.id);
```

**Vấn đề:** `theme.isFavorite` đọc TRƯỚC khi `toggleFavorite()` → khi thêm yêu thích hiện "Đã xóa", khi xóa hiện "Đã thêm".  
**Fix:** Đọc state SAU toggle hoặc invert điều kiện: `!theme.isFavorite ? s.removedFromFavorites : s.addedToFavorites`.

---

### BUG-003 — isFirstUnlock luôn hardcode true

**Severity:** 🟠 Analytics Bug  
**File:** `lib/features/garage/reward_modal.dart:156`

```dart
analyticsService.logItemUnlocked(
  itemType: _analyticsItemType,
  itemId: itemId ?? '',
  itemName: itemName ?? '',
  method: AnalyticsValue.watchAd,
  isFirstUnlock: true,  // ← luôn true
);
```

**Vấn đề:** Mọi unlock event đều log `isFirstUnlock: true` — không phân biệt được lần đầu unlock vs lần sau. Data analytics sai.  
**Fix:** Truyền `isFirstUnlock` từ caller (đã biết entitlement state trước khi gọi `RewardModal.show()`).

---

### BUG-004 — logWallpaperSetAs hardcode homeScreen trong gallery

**Severity:** 🟠 Analytics Bug  
**File:** `lib/features/gallery/gallery_screen.dart:168-173`

```dart
// gallery_screen.dart
analyticsService.logWallpaperSetAs(
  themeId: theme.id.toString(),
  target: AnalyticsValue.homeScreen,  // ← luôn 'home'
);
```

```dart
// Đúng như garage_screen.dart:243-250
target: switch (target) {
  WallpaperTarget.home => AnalyticsValue.homeScreen,
  WallpaperTarget.lock => AnalyticsValue.lockScreen,
  WallpaperTarget.both => AnalyticsValue.both,
},
```

**Vấn đề:** Target thực tế user chọn (home/lock/both) không được log — luôn ghi là `home`.  
**Fix:** `SetWallpaperModal.showLocalized` cần trả về target được chọn để truyền vào analytics.

---

### BUG-005 — Silent catch nuốt lỗi copy file

**Severity:** 🟠 Reliability  
**File:** `lib/features/share/share_screen.dart:53`

```dart
try {
  final src = File(widget.args.imagePath);
  if (src.existsSync()) {
    final docsDir = await getApplicationDocumentsDirectory();
    final dest = File('${docsDir.path}/wallpaper_${...}.png');
    await src.copy(dest.path);
    persistedPath = dest.path;
  }
} catch (_) {}  // ← nuốt hoàn toàn
```

**Vấn đề:** Nếu copy thất bại (hết dung lượng, permission, v.v.), `persistedPath` vẫn trỏ vào cache dir. User thấy ảnh trong library nhưng file có thể bị OS xóa bất cứ lúc nào.  
**Fix:** Log lỗi tối thiểu (`debugPrint`) + hiện toast cảnh báo "Lưu thất bại, ảnh có thể bị mất".

---

### BUG-006 — _themes không reactive sau đổi filter

**Severity:** 🟠 State Bug  
**File:** `lib/features/gallery/gallery_screen.dart:100-108`

```dart
@override
void initState() {
  super.initState();
  final selectedCat = ref.read(selectedCategoryProvider);  // đọc 1 lần
  final favOnly = ref.read(favFilterActiveProvider);       // đọc 1 lần
  final allThemes = ref.read(themeStateProvider);
  _themes = allThemes.where(...).toList();  // snapshot tĩnh
  // ...
}
```

**Vấn đề:** `_themes` chỉ build 1 lần trong `initState`. Nếu user: mở Gallery → back → đổi category → mở lại Gallery → thấy danh sách cũ.  
**Fix:** Snapshot filter state tại thời điểm push route (truyền qua `GalleryArgs`), hoặc dùng `didChangeDependencies` để rebuild khi provider thay đổi.

---

### BUG-007 — Temp PNG từ canvas capture tích lũy dung lượng

**Severity:** 🟡 Memory Leak  
**File:** `lib/features/garage/garage_screen.dart:85-86`

```dart
final file = File(
  '${(await getTemporaryDirectory()).path}/wp_canvas_${DateTime.now().millisecondsSinceEpoch}.png'
);
await file.writeAsBytes(bytes);
return file.path;
```

**Vấn đề:** Mỗi lần capture tạo 1 file PNG mới với tên timestamp. File không bao giờ bị xóa sau khi navigate sang ShareScreen. User apply nhiều lần → cache dir phình to.  
**Fix:** Dùng tên cố định `wp_canvas_preview.png` và ghi đè, hoặc delete file sau khi `ShareScreen` lưu xong.

---

### BUG-008 — Thiếu Firebase Crashlytics

**Severity:** 🟡 Observability  
**File:** `pubspec.yaml`

```yaml
# Có:
firebase_core: ^3.6.0
firebase_analytics: ^11.3.3

# Thiếu:
# firebase_crashlytics
```

**Vấn đề:** Kill criteria trong `fail-fast-tracker.yaml` yêu cầu `crash_free_min: 0.99` nhưng không có Crashlytics để đo. Crashes trên production = blind spot hoàn toàn.  
**Fix:**
```dart
// main.dart — thêm sau Firebase.initializeApp()
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

---

### BUG-009 — WidgetRef truyền qua constructor

**Severity:** 🟡 Flutter Anti-pattern  
**File:** `lib/features/home/home_screen.dart:89-98`

```dart
class _CategoryScroll extends StatelessWidget {
  final String selectedCat;
  final bool favActive;
  final WidgetRef ref;  // ← anti-pattern

  const _CategoryScroll({
    required this.selectedCat,
    required this.favActive,
    required this.ref,  // ← không nên store ref
  });
```

**Vấn đề:** `WidgetRef` chỉ valid trong scope của build method gốc. Store nó trong field StatelessWidget có thể gây lỗi nếu widget được dùng sau build frame.  
**Fix:** Đổi `_CategoryScroll` thành `ConsumerWidget` và dùng `ref` trực tiếp trong `build()`.

---

### BUG-010 — SharedPreferences trực tiếp trong UI layer

**Severity:** 🟡 Architecture  
**Files:**
- `lib/features/garage/garage_screen.dart:219-221, 261-263`
- `lib/features/share/share_screen.dart:94`
- `lib/features/loading/loading_screen.dart:51`

```dart
// garage_screen.dart:219
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('pending_garage_theme_id', widget.themeId);
await prefs.setStringList('pending_garage_stickers', ...);
```

**Vấn đề:** MIUI restart recovery logic (pending state) nằm rải rác trong 3 screens khác nhau với raw string keys. Khó test, dễ miss khi key thay đổi, logic bị phân mảnh.  
**Fix:** Extract sang `PendingRestoreService` với typed methods: `savePendingGarage()`, `loadPendingGarage()`, `clear()`.

---

### BUG-011 — Future.microtask trong build() của Notifier

**Severity:** 🟡 Provider Best Practice  
**File:** `lib/providers/theme_state_provider.dart:12`

```dart
class ThemeStateNotifier extends Notifier<List<ThemeItem>> {
  @override
  List<ThemeItem> build() {
    Future.microtask(_loadFavorites);  // ← side effect trong build()
    return kThemes.map(...).toList();
  }
}
```

**Vấn đề:** `build()` của Riverpod Notifier có thể được gọi lại (invalidation, hot reload). Mỗi lần build schedule thêm 1 microtask `_loadFavorites`. Bình thường không crash nhưng là bad practice.  
**Fix:** Dùng `AsyncNotifier<List<ThemeItem>>` thay vì `Notifier` để load favorites trong `build()` async, hoặc dùng `ref.listenSelf` để chỉ load 1 lần.

---

## Fix Order

```
BUG-001  →  BUG-002  →  BUG-004  →  BUG-005
(crash)     (UX bug)    (analytics) (reliability)

BUG-003  →  BUG-006  →  BUG-007  →  BUG-008
(analytics) (state)     (memory)    (crashlytics)

BUG-009  →  BUG-010  →  BUG-011
(pattern)   (arch)      (provider)
```

## Related

- `docs/review-hardcoded-values.md` — HCV-001 đến HCV-007 (config/env issues)
- `docs/fail-fast-tracker.yaml` — kill criteria: crash_free >= 99%
