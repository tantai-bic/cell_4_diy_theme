# Tech-Spec: DIY-WALLPAPER — Port Flutter (Android) + AppLovin MAX

**Created:** 2026-06-26
**Status:** Ready for Development
**Bet:** bet-001 (fail-fast-tracker.yaml) · **Phase:** P1-spec → P2-build
**Author:** Barry (quick-flow-solo-dev) · **Stack chốt:** Flutter / Dart / AppLovin MAX (studio_stack)

---

## Overview

### Problem Statement

Prototype web `index.html` (vanilla JS, ~3000 dòng) đã **validate xong UI/flow** của app "Trạm độ giao diện" cho tệp Gamer/Tech Android. Nhưng web KHÔNG lên production được vì: (1) set wallpaper Home/Lock cần native API, (2) ads trong WebView eCPM thấp + không mediation → mâu thuẫn mục tiêu "không bỏ sót ads", (3) chưa persist library/draft. Cần port sang **production app Flutter/Android**, nhúng **AppLovin MAX** thật (Rewarded + Native) đạt kill-gate: crash-free ≥ 99%, D1 ≥ 25%, eCPM ≥ $2.5.

### Solution

Dựng lại 10 screen + 8 modal + hệ toast/haptic của prototype bằng Flutter, **giữ nguyên 1:1 hành vi đã validate** (nguồn: `frd.md`, `ac.md`, `uxui.md`, `design.md`, `prd.md`). Thay tầng mock ads bằng **AppLovin MAX mediation** (waterfall + in-app bidding qua AdMob/Meta/Unity/ironSource) để tối đa fill-rate. Đóng gap persistence (library/draft) bằng local DB. Ship **Android trước** (codebase cross-platform, iOS bật sau, không viết lại).

### Scope (In/Out)

**IN:**
- Port đầy đủ 10 screen + 8 modal + toast + haptic (1:1 với prototype).
- AppLovin MAX: **Rewarded Ad** (apply S4, apply premium S3, unlock item S4) + **Native Ad** (chèn feed gallery S3).
- Entitlement persistence (unlocked stickers/themes/premium) + Library/Draft persistence (đóng gap uxui §8).
- Canvas editor Garage (drag / pinch-scale 0.3–4.0 / undo-redo / add text-sticker-photo).
- Set wallpaper Android (HOME/LOCK/BOTH) + điều hướng phân nhánh sau apply (Viral Loop).
- Bundle 169 theme + 44 sticker (dùng `output/sticker` đã tách nền) vào assets.
- Remove BG in-app qua **cloud API** (runtime, cần mạng) — riêng biệt với tool build-time.
- Network check + retry tác vụ gián đoạn · Share (FB/IG/TikTok/Copy link) · Rate App · Settings.

**OUT (theo quyết định scope + prd §9 Roadmap):**
- iOS build/release (codebase sẵn sàng nhưng release sau).
- Interstitial / App-open / Banner ads (cố ý loại — bảo vệ UX edge).
- IAP / mua Premium (model thuần IAA, unlock bằng Rewarded).
- Modding Sliders RGB, VFX động, HUD Dashboard số liệu thật, custom HEX/RGB color, đa ngôn ngữ runtime (chỉ VI) — Roadmap Phase 2.

---

## Context for Development

### Codebase Patterns (nguồn chân lý: prototype + 5 docs)

**Prototype (`index.html`) — pattern phải bảo toàn:**
- **Navigation:** SPA, `switchScreen(screenId)` toggle `.active`. 10 screen id: `screen-loading`, `screen-home`, `screen-gallery`, `screen-garage`, `screen-zeroui-preview`, `screen-library`, `screen-lib-wall-detail`, `screen-lib-draft-detail`, `screen-settings`, `screen-share`.
- **Entitlement:** `localStorage` keys `LS_UNLOCKED` (sticker), `LS_UNLOCKED_THEMES`, `LS_PREMIUM`. Đã unlock → dùng thẳng không ads.
- **Monetization API:** `openRewardModal(purpose)` với `purpose ∈ {'apply','unlock'}` → `startRewardVideoSequence()` → overlay đếm ngược → callback theo purpose.
- **Reward trigger chuẩn:** Apply tại S4 **luôn** ads (kể cả phôi Free); Apply Premium tại S3 ads; Apply từ Library **bỏ ads** (`applyFromLibrary`); unlock item Premium = lượt ads riêng.
- **State runtime:** `selectedCategory`, `favoriteFilterActive`, `selectedTheme`, `libraryActiveTab`, `bulkSelectMode`, `selectedLibraryItems`, `savedWallpapers`, `savedDrafts`, `undoStackStickers`, `redoStackStickers`, `isOnlineSimulation`, `interruptedTask`, `previewDisplayState`, `usedPremiumInDesign`, `wallpaperSetContext`, `pendingPremiumUnlock`, `rewardVideoPurpose`, `shareBackContext`, `currentRating`.
- **Feedback:** `showToast(msg, opts)` (pill, glow, haptic, tự ẩn ~2.5s, biến thể `pink`/`flash`); `haptic()` qua `navigator.vibrate`; `showLoadingModal()` blocking 100%; modal network có `interruptedTask` retry.
- **Set wallpaper điều hướng phân nhánh:** từ Garage(S4) → Share; từ Gallery(S3) → Gallery; từ Library → Library.

**Design system (`uxui.md` §1) — map sang Flutter `ThemeData`:**
- Màu: `--bg-amoled #050508`, `--bg-cyber #0d0e15`, `--bg-card #141622`, `--neon-cyan #00f3ff` (primary/active/glow), `--neon-pink #ff0055` (destructive/premium), `--neon-yellow #ffee00` (highlight/category), `--text-main #e2e8f0`, `--text-muted #64748b`, `--border-cyber #1e293b`.
- Font: **Orbitron** (tiêu đề/số/nút), **Rajdhani** (body) — qua `google_fonts` hoặc bundle.
- Hình khối **chamfered** (clip-path polygon) → Flutter `ClipPath` + custom `CustomClipper` (KHÔNG `BorderRadius` mềm). Glow active = `BoxShadow` neon.
- Khung giả lập phone 420×860 chỉ là artefact web preview → **bỏ** khi lên mobile thật (full screen).

**Asset pipeline (đã có):**
- `assets/theme/` 169 ảnh + `manifest.json` ({file,id,size,title}). `assets/sticker/` 44 ảnh + manifest. `output/sticker/` 42 ảnh **đã die-cut nền** (dùng bản này cho sticker drawer).
- `tools/bg-remover/` (Node/TS, `sharp` flood-fill, `npm run cut`) = **build-time**, không port vào app. Giữ nguyên để pre-process asset mới.

### Files to Reference

| File | Dùng cho |
|---|---|
| `index.html` | Nguồn hành vi 1:1 (function names, flow, modal logic, entitlement) |
| `frd.md` | Đặc tả từng screen + 7 modal dùng chung |
| `ac.md` | Acceptance Criteria AC1–AC13 (map trực tiếp xuống dưới) |
| `uxui.md` | Design system, screen id, state vars, gap list (§8) |
| `design.md` | Bảng vị trí UI từng khu vực (styling + UX) |
| `prd.md` | Monetization model (§5), NFR (§7), Roadmap out-scope (§9) |
| `assets/theme/manifest.json`, `assets/sticker/manifest.json` | Data model theme/sticker, bundle danh mục |
| `output/sticker/` | Ảnh sticker đã tách nền cho drawer |

### Technical Decisions

| Quyết định | Chọn | Lý do |
|---|---|---|
| State management | **Riverpod** (hoặc Provider) | Entitlement + library global, testable, ít boilerplate |
| Navigation | **go_router** | 10 screen + deep params (context apply), back-stack rõ |
| Entitlement persist | **shared_preferences** | Map 1:1 với localStorage keys hiện tại |
| Library/Draft persist | **Hive** (hoặc Isar) | Lưu object wallpaper/draft + ảnh path, query nhanh, đóng gap §8 |
| Ad mediation | **applovin_max** (AppLovin MAX) | `MaxRewardedAd` + `MaxNativeAdView`; mediation maximize fill |
| Set wallpaper | **async_wallpaper** (+ platform channel fallback) | HOME/LOCK/BOTH Android; iOS fallback (save-to-photos) sau |
| Canvas editor | `Stack` + `GestureDetector` (scale/pan) tự code | Bám sát tương tác đã validate; tránh lib nặng |
| Remove BG runtime | **Cloud API** (remove.bg / API tự chọn ở P2) | NFR: tác vụ nặng chặn UI bằng loading modal |
| Haptic / Share / Rate / Net / Picker | `HapticFeedback` · `share_plus` · `in_app_review` · `connectivity_plus` · `image_picker` | Boring, well-maintained |

> **Quy ước "không bỏ sót ads":** mọi điểm gọi ads đi qua **1 service duy nhất** (`AdService`) bọc AppLovin MAX. Service phải: (a) preload sẵn rewarded sau mỗi lần show, (b) có **retry/backoff** khi load fail, (c) **fallback gọi lại** nếu impression chưa fire, (d) log mọi event (load/display/clicked/revenue/failed) cho tracking. Native ad preload theo pool cho feed.

---

## Implementation Plan

### Tasks

**EPIC A — Bootstrap & Design System**
- [ ] A1: Khởi tạo Flutter project (org id, Android `minSdk 24`, package name), cấu trúc thư mục theo qa-engineer layer (lib/core, features, services).
- [ ] A2: Bundle assets (169 theme từ `assets/theme`, 44 sticker từ `output/sticker`) + load 2 `manifest.json` thành model `ThemeItem`/`StickerItem` (id, file, size, title, isPremium).
- [ ] A3: Dựng `ThemeData` Cyberpunk (palette + Orbitron/Rajdhani) + widget chung: `CyberPanel`, `CyberButton`, `ChamferClipper`, glow `BoxShadow`.
- [ ] A4: Hệ feedback dùng chung: `CyberToast` (glow + `HapticFeedback`, variant pink/flash), `LoadingModal` (blocking, không dismiss-outside/back), `showHaptic()`.

**EPIC B — Navigation & State core**
- [ ] B1: go_router 10 route + back-stack; quản lý `wallpaperSetContext` (garage/gallery/library) & `shareBackContext`.
- [ ] B2: Riverpod providers: `entitlementProvider` (shared_preferences ↔ `LS_UNLOCKED/_THEMES/_PREMIUM`), `libraryProvider` (Hive: wallpapers + drafts), `networkProvider` (connectivity + retry `interruptedTask`).
- [ ] B3: Network guard: mọi tác vụ cần mạng gọi `checkNetwork()` → fail → `NoInternetModal` (Settings/Retry, chặn outside) → Retry chạy lại đúng tác vụ.

**EPIC C — Screens Khám phá (S1–S3)**
- [ ] C1: Screen Loading — matrix scan + bitstream, network check ngầm, auto → Home. Wordmark hiển thị **tên app "DIY WALLPAPER"** (giữ hiệu ứng glitch, thay chuỗi `SYSTEM.ROOT` cũ — PO chốt 2026-06-26).
- [ ] C2: Screen Home — header (Library/Settings), category scroll, favorite filter, grid 2 cột card (tim toggle + badge Premium), empty state.
- [ ] C3: Screen Gallery — feed cuộn ngang scroll-snap, swipe đổi theme, **Native Ad card chèn feed**, nút Apply (logic phân nhánh Free/Premium), nút vào Garage. Offline khi swipe → modal lỗi.

**EPIC D — Garage Editor (S4–S5)**
- [ ] D1: Canvas workspace: ảnh nền + lớp sticker (`Stack`), drag (pan), pinch + scroll scale (clamp 0.3–4.0), chọn → viền dashed cyan + nút X, bấm nền bỏ chọn.
- [ ] D2: Sticker drawer grid 4 cột (item Premium gắn 👑), Add Text (Sci-Fi), Add Photo (`image_picker` + loading), Remove BG (cloud API + loading + Premium lock).
- [ ] D3: Undo/Redo stack sticker (AC6): thêm mới xóa nhánh redo; ngăn rỗng → toast "Nothing to Undo/Redo".
- [ ] D4: Back → `UnsavedChangesModal` (Save Draft → Hive + về Library / Hủy / Keep). Cờ `usedPremiumInDesign`.
- [ ] D5: Screen 5 ZeroUI Preview — clone workspace sạch (ẩn control) + mock HUD overlay + toggle Clock ↔ App-grid + nút X.

**EPIC E — Monetization (AppLovin MAX) — lõi "không bỏ sót ads"**
- [ ] E1: Tích hợp SDK `applovin_max` (init, SDK key, mediation networks AdMob/Meta/Unity/ironSource; consent/UMP GDPR + ATT iOS sau).
- [ ] E2: `AdService` — Rewarded: preload + show + **retry/backoff** + reward callback theo `purpose ∈ {apply, unlock}`; đảm bảo impression fire, log event (load/display/revenue/fail).
- [ ] E3: `AdService` — Native: pool preload, render `MaxNativeAdView` dạng Cyber-card chèn feed gallery (E/C3).
- [ ] E4: Wire reward triggers đúng spec: Apply S4 luôn ads; Apply Premium S3 ads; unlock item S4 ads riêng; Apply Library bỏ ads. Sau unlock → persist entitlement + toast "Item Unlocked!".
- [ ] E5: `RewardModal` text đổi theo ngữ cảnh (S3 unlock theme / S4 apply / S4 unlock item) — đồng ý → loading đệm → ads → chạy hành động chờ; không xem → giữ nguyên.

**EPIC F — Apply / Set Wallpaper / Viral Loop**
- [ ] F1: `SetWallpaperModal` HOME/LOCK/BOTH → `async_wallpaper` (Android) → loading "System Applying..." → success + haptic + toast.
- [ ] F2: Điều hướng phân nhánh sau success: S4 → Share (kèm phôi vừa tạo); S3 → về Gallery; Library → về Library.
- [ ] F3: Lưu wallpaper đã set vào Hive (Tab Wallpaper, đánh dấu unlocked vĩnh viễn).

**EPIC G — Library / Share / Settings**
- [ ] G1: Screen Library 2 tab (Wallpaper/Draft), grid, bulk select + delete (loading giải phóng + toast). Empty state. Tab Wallpaper cần mạng.
- [ ] G2: Wall detail (Save ảnh về máy + Edit→Garage + Apply bỏ ads `applyFromLibrary`) · Draft detail (Continue Modding→Garage).
- [ ] G3: Screen Share — preview phôi + FB/IG/TikTok (`share_plus`) + Copy Link (toast) + back động.
- [ ] G4: Screen Settings — Feedback (email), Share App, Rate App (`in_app_review` 5 sao→store), Privacy, Version, Language (VI tĩnh).

**EPIC H — Quality gate & Ship-prep (cổng P2→P3, không skip — playbook #16)**
- [ ] H1: Test crash-free luồng gọi ads (load fail, no-fill, mất mạng giữa video, double-tap apply, back khi đang ads).
- [ ] H2: Tracking analytics events (ad impression/revenue, apply rate, ads completion rate, retention hooks) — chuẩn bị số liệu kill-gate.
- [ ] H3: Build AAB Android release (ký, ProGuard/R8 giữ SDK ads), checklist Play Store (privacy, data safety).

### Acceptance Criteria

> Map trực tiếp từ `ac.md` (AC1–AC13). Mọi AC phải pass trên thiết bị Android thật.

- [ ] **AC1 (Loading→Home):** Given mở app, When network OK + load xong manifest, Then tắt loading tự chuyển Home; loading hiển thị wordmark **"DIY WALLPAPER"** (glitch effect). Mất mạng → NoInternetModal, Retry có mạng mới đi tiếp.
- [ ] **AC2 (Apply Free S3 — no ads):** Given theme Free ở S3, When Apply, Then mở thẳng SetWallpaperModal (KHÔNG ads) → loading → success.
- [ ] **AC3 (Apply S4 — LUÔN ads):** Given độ ở Garage (Free hay Premium), When Apply, Then **luôn** RewardModal. "Không xem" → giữ nguyên ở S4. "Đồng ý" → reward ads xem 100% → SetWallpaperModal.
- [ ] **AC3B (Unlock item S4):** Given bấm sticker/tool 👑 Premium, When chọn dùng, Then RewardModal (text unlock) → xem xong → áp item + set `usedPremiumInDesign` + persist entitlement + toast "Item Unlocked!" (flash).
- [ ] **AC3C (Viral Loop):** Given set wallpaper thành công từ S4, When loading "System Applying..." kết thúc, Then haptic + đẩy sang Share kèm phôi vừa tạo.
- [ ] **AC4 (Loading blocking):** Given LoadingModal hiện, When tap-outside / back vật lý, Then chặn hoàn toàn; chỉ tắt bằng code sau success/fail.
- [ ] **AC5 (Favorites S2/S3):** Given xem card, When bấm tim, Then đảo trạng thái + toast Added/Removed; filter "Đã yêu thích" chỉ hiện theme đã tim, không đụng Draft.
- [ ] **AC6 (Undo/Redo S4):** Given ≥1 sticker, When Undo→gỡ phần tử mới nhất vào Redo; Redo→khôi phục; thêm mới→xóa nhánh Redo; ngăn rỗng→toast.
- [ ] **AC7 (Unsaved Changes):** Given ở S4, When Back, Then modal 3 lựa chọn: Save Draft (→Tab Draft, về Library) / Hủy / Keep Edit.
- [ ] **AC8 (Set Wallpaper options + điều hướng):** Given modal mở (S3/S4/Library), When chọn HOME/LOCK/BOTH, Then loading → success + haptic + toast; điều hướng: S4→Share, S3→Gallery, Library→Library.
- [ ] **AC9 (Bulk delete + Save ảnh):** Given Tab Wallpaper/Draft, When Select→chọn→Delete, Then loading → cập nhật list + toast. And Save ảnh ở wall detail → loading export → toast "Image Saved to Device Gallery".
- [ ] **AC10 (Apply lại từ Library — free):** Given theme đã set ở Tab Wallpaper, When Apply, Then mở thẳng SetWallpaperModal KHÔNG ads.
- [ ] **AC11 (Rate App):** Given Settings, When Rate, Then modal 5 sao; bắt buộc ≥1 sao mới confirm; confirm → direct store.
- [ ] **AC12 (Share + Copy link):** Given Share screen, When bấm social → check mạng → loading → app thứ ba; Copy Link → toast; Back về đúng context.
- [ ] **AC13 (No-Internet retry):** Given mất mạng khi tác vụ cần net, When bật lại mạng + Retry, Then chạy lại đúng tác vụ gián đoạn; không tắt modal bằng outside.
- [ ] **AC-ADS (mới — "không bỏ sót ads"):** Given reward ad load fail/no-fill, When user kích hoạt apply/unlock, Then AdService retry/backoff + báo trạng thái rõ; không bao giờ "nuốt" hành động (hoặc cho qua sau khi log fallback, hoặc giữ nguyên + toast) — không treo.

---

## Additional Context

### Dependencies

- **Flutter SDK** (stable). Android `minSdk 24` (AppLovin MAX yêu cầu).
- Packages: `applovin_max`, `flutter_riverpod`, `go_router`, `shared_preferences`, `hive`/`hive_flutter`, `async_wallpaper`, `image_picker`, `share_plus`, `in_app_review`, `connectivity_plus`, `google_fonts` (Orbitron/Rajdhani), `http`/`dio` (cloud Remove BG).
- **Tài khoản/keys (chuẩn bị trước P2 — ac.md GĐ2):** AppLovin MAX SDK key + ad unit ids (Rewarded, Native); kích hoạt mediation networks (AdMob/Meta/Unity/ironSource) trên dashboard MAX; API key dịch vụ Remove BG.
- Build-time (không vào app): Node + `tsx` + `sharp` cho `tools/bg-remover`.

### Testing Strategy

- **Unit:** entitlement logic (unlock persist), undo/redo stack, apply-branch (S3 free/premium, S4 always-ads, library free), reward purpose routing.
- **Widget:** modal blocking (AC4), toast/haptic, canvas scale clamp 0.3–4.0, favorite filter.
- **Integration/E2E (Playwright/Flutter integration_test — theo tea):** luồng AC1–AC13 trên emulator + 1 device thật.
- **Ad crash-free (Murat gate, H1 — bắt buộc):** load fail, no-fill, mất mạng giữa video, double-tap apply, back/lifecycle khi ads đang mở, rotation. Mục tiêu **crash-free ≥ 99%**.
- **Test ads:** dùng AppLovin **test mode / test ad units**, KHÔNG click ads thật.

### Notes

- ✅ **RESOLVED (ac.md AC1 — PO chốt 2026-06-26):** giữ loading-text (glitch effect), thay chuỗi `SYSTEM.ROOT` cũ bằng **tên app "DIY WALLPAPER"**. (Nếu sau này chốt brand name chính thức khác → swap đúng 1 chuỗi hằng số ở C1.)
- **Reward vs Native rạch ròi:** chỉ Rewarded + Native. KHÔNG thêm Interstitial/App-open/Banner (bảo vệ edge "tôn trọng UX" — đây là khác biệt sống còn với đối thủ).
- **"Không bỏ sót ads" = mediation, không phải nhồi format:** tối đa fill-rate qua waterfall+bidding của MAX trong 2 format đã chọn; mọi điểm ads đi qua `AdService` duy nhất (preload/retry/log).
- **Persist là gap mới đóng:** prototype mất data khi reload; Flutter phải persist entitlement (shared_preferences) + library/draft (Hive). Đây là yêu cầu production, không có trong prototype.
- **iOS:** codebase cross-platform sẵn sàng nhưng KHÔNG release đợt này; tránh code khóa cứng Android-only ngoài lớp set-wallpaper (đặt sau interface để iOS bổ sung sau).
- Cập nhật `fail-fast-tracker.yaml`: set `artifacts.tech_spec` = đường dẫn file này + ghi `decision_log` khi PO duyệt (cổng #8 playbook).
