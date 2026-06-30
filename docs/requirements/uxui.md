# UI/UX SPEC — DIY WALLPAPER MODDING ENGINE (`SYSTEM.ROOT`)

> Tài liệu này được rút ra trực tiếp từ prototype `index.html`. Mục tiêu: mô tả chính xác hệ thống thiết kế, các màn hình và luồng tương tác đang chạy để Dev/QA bám theo. Phần cuối ghi rõ các khoảng cách so với brief gốc.

---

## 0. Triết lý thiết kế (Design Direction)

Chinh phục tệp user nam giới, gamer và người mê xe. Giao diện **KHÔNG** đi theo lối "ngọt ngào, bo góc, icon nhí nhảnh". Thay vào đó toát lên cảm giác của một **phần mềm tối ưu phần cứng / trạm điều khiển (Control Hub)** kiểu MSI Afterburner, ASUS Armoury Crate hay HUD trong game.

Nguyên tắc cốt lõi:
- Mạnh mẽ, chuyên nghiệp, trao toàn quyền kiểm soát cho user.
- True Dark / AMOLED làm nền tảng.
- Hình khối góc cạnh (chamfered), không bo tròn mềm mại.
- Tối giản số lần chạm để đến hành động (Min Clicks to Action).

---

## 1. Hệ thống Thiết kế Trực quan (Visual System)

### 1.1 Bảng màu (đang dùng trong code — CSS variables)

| Biến | Mã màu | Vai trò |
|------|--------|---------|
| `--bg-amoled` | `#050508` | Nền sâu nhất (loading, AMOLED) |
| `--bg-cyber` | `#0d0e15` | Nền màn hình chính |
| `--bg-card` | `#141622` | Nền card / panel / modal |
| `--neon-cyan` | `#00f3ff` | Accent chính (primary action, active, glow) |
| `--neon-pink` | `#ff0055` | Cảnh báo / destructive / premium badge |
| `--neon-yellow` | `#ffee00` | Highlight / quảng cáo / category active |
| `--text-main` | `#e2e8f0` | Chữ chính |
| `--text-muted` | `#64748b` | Chữ phụ / disabled |
| `--border-cyber` | `#1e293b` | Viền chuẩn |

> **Hướng nghệ thuật:** Cyberpunk (Cyan/Pink/Yellow). Chưa triển khai tùy biến HEX/RGB cho UI và chưa có preset ROG Red / Razer Green như brief gốc — xem mục 8.

### 1.2 Typography

- **`Orbitron`** (`--font-cyber`): tiêu đề, số liệu, nhãn kỹ thuật, nút — font góc cạnh tương lai.
- **`Rajdhani`** (`--font-sub`): chữ thân, mô tả, label cài đặt.
- Chữ kỹ thuật viết HOA, giãn ký tự (`letter-spacing`), nhiều nhãn dạng "code" (`SYSTEM.ROOT`, `NET.CRITICAL // 5G`).

### 1.3 Ngôn ngữ hình khối (Chamfered Tech)

- `.cyber-panel` / `.cyber-btn` / `.cyber-switch` / `.cyber-modal` đều dùng `clip-path: polygon(...)` để cắt vát góc — không `border-radius` mềm.
- Trạng thái **Active phát sáng** (Glow) qua `box-shadow` neon, mô phỏng đèn LED.
- Icon dùng Font Awesome 6 dạng outline/solid; icon active đổi sang màu neon + glow.
- Nút bấm có phản hồi nhấn: `:active { transform: scale(0.95); opacity: .8 }` (phản hồi cơ học bằng thị giác).
- **Haptic Feedback:** đã có qua `navigator.vibrate` (`haptic()`) — rung khi hiện toast, chọn sao, và set wallpaper thành công.

### 1.4 Khung giả lập thiết bị

Toàn app render trong `#phone-wrapper` (max 420×860px, viền + glow cyan) — mô phỏng màn hình smartphone, căn giữa viewport.

---

## 2. Kiến trúc Điều hướng (Navigation Architecture)

Mô hình **single-page, nhiều `.app-screen`** chồng lớp, chuyển bằng `switchScreen(screenId)` (toggle class `.active`). Không có URL/route.

Danh sách màn hình (`id`):

1. `screen-loading` — Boot/Loading
2. `screen-home` — SYSTEM.ROOT (Trang chủ / thư viện theme)
3. `screen-gallery` — THEME.PREVIEW (Feed cuộn ngang)
4. `screen-garage` — Modding Garage (Workspace chỉnh sửa)
5. `screen-zeroui-preview` — ZeroUI Preview (Xem trước toàn màn hình)
6. `screen-library` — MY.STORAGE (Lưu trữ)
7. `screen-lib-wall-detail` — Chi tiết wallpaper đã lưu
8. `screen-lib-draft-detail` — Chi tiết bản nháp
9. `screen-settings` — SYSTEM.CFG (Cài đặt)
10. `screen-share` — NODE.SHARE (Chia sẻ)

### Luồng chính (Core Flow)

```
LOADING → HOME → (chọn theme) → GALLERY/PREVIEW → GARAGE (mod)
        → ZEROUI PREVIEW (xem trước) → APPLY (paywall) → SET WALLPAPER → LIBRARY
```

---

## 3. Đặc tả từng Màn hình

### 3.1 `screen-loading` — Boot Sequence
- Tiêu đề glitch `SYSTEM.ROOT` (hiệu ứng `@keyframes glitch` lệch màu cyan/pink/yellow).
- Thanh quét "matrix fluid scan" + dòng bitstream nhị phân random cập nhật mỗi 150ms.
- 2 nút mock test mạng: `MẠNG: ON` / `MẠNG: OFF`.
- Tự chuyển sang Home sau ~2.5s (nếu mạng ON).

### 3.2 `screen-home` — SYSTEM.ROOT
- **Header:** nút Folder (→ Library) | tiêu đề | nút Gear (→ Settings).
- **Category scroll** (cuộn ngang): `ALL SYSTEM, JDM RACING, CYBERPUNK, SCI-FI HUD, HYPERCAR`. Tab active = nền vàng neon.
- **Filter bar:** nút `MỤC YÊU THÍCH` (lọc favorite) + chỉ báo `SIM_NET: ONLINE/OFFLINE` (bấm để toggle mô phỏng mạng).
- **Grid 2 cột** theme card: ảnh cover, nút tim (favorite toggle), badge `PREMIUM` nếu có.
- Empty state: `NO CORE MATRIX FOUND`.

### 3.3 `screen-gallery` — THEME.PREVIEW
- **Feed cuộn ngang scroll-snap** (`feed-container`), card 280px, có:
  - Card theme đã chọn.
  - **Native Ad card** (`SPONSORED FEED AD` — ROG Ally) chèn vào feed.
  - Các theme liên quan khác (bấm để đổi theme nền).
- Header có nút `APPLY` (→ paywall premium / set wallpaper).
- Action bar dưới: `CUSTOMIZE THEMING (MOD ENGINE)` → mở Garage.
- Khi cuộn lúc offline → bật modal lỗi mạng.

### 3.4 `screen-garage` — Modding Garage (Workspace)
Trái tim của app — "trạm độ".

- **Header:** Back (cảnh báo unsaved) | Undo + **Redo** + Preview (con mắt) | `APPLY` (**luôn** xem Reward Ads, kể cả phôi Free).
- **Workspace:** ảnh nền `#bg-target` + các sticker (`.canvas-sticker`) chồng lên.
- **Tương tác sticker (đã code đầy đủ):**
  - Kéo–thả (mouse `mousedown` + touch `touchstart`).
  - **Phóng to/thu nhỏ:** cuộn chuột (`wheel`, bước 0.1) hoặc **pinch 2 ngón** (giới hạn scale 0.3–4.0).
  - Chọn sticker → viền dashed cyan + nút xóa (X góc trên phải).
  - Bấm nền trống → bỏ chọn.
- **Sticker drawer** (pop-up grid 4 cột): chọn linh kiện/HUD/shape; 2 item gắn 👑 **Premium** (mở khóa qua ads → "Item Unlocked!").
- **Toolbar dưới (4 công cụ):**
  - `Rem BG` — AI xóa nền (**Premium** 👑: xem ads mở khóa → loading cloud → toast).
  - `Thêm Chữ` — prompt nhập Sci-Fi text (màu vàng neon).
  - `Sticker` — bật/tắt drawer.
  - `Thêm Ảnh` — mock upload ảnh từ thiết bị.
- **Đánh dấu Premium:** dùng tool/sticker khóa sẽ set cờ `usedPremiumInDesign` (dùng cho mở khóa item; Apply tại S4 nay luôn xem ads nên không còn phân nhánh theo cờ này).
- Overlay hướng dẫn: "Cuộn chuột hoặc Nhúm 2 ngón tay để Phóng to/Thu nhỏ linh kiện".

### 3.5 `screen-zeroui-preview` — ZeroUI Preview
- **Clone** toàn bộ workspace (ẩn nút xóa, viền chọn, overlay hướng dẫn) → xem thành phẩm sạch.
- **Mock HUD overlay** mô phỏng màn hình điện thoại thật:
  - Top: `NET.CRITICAL // 5G` + `BATTERY // 99%`.
  - Đồng hồ lớn (Orbitron) + ngày `OCTOBER 24 // NEO-TOKYO`.
- Nút `SWITCH DISPLAY MODE` đổi giữa **chế độ Đồng hồ** ↔ **lưới App icon** (Terminal/Proxy/Core.Mod/Nodes) — đúng tinh thần "ẩn toolbar để thấy rõ thành phẩm".
- Nút X thoát về Garage.

### 3.6 `screen-library` — MY.STORAGE
- 2 tab: `TOPIC WALLPAPER` (đã deploy) | `DRAFTS` (bản nháp).
- Grid 2 cột; bấm item → màn chi tiết tương ứng.
- **Bulk select:** nút `SELECT` → bật chế độ chọn nhiều (checkbox) → thanh `DELETE SELECTED MATRIX` (destructive, màu pink).
- Empty state: `STORAGE EMPTY`.
- Tab wallpaper yêu cầu mạng (offline → modal lỗi).

### 3.7 `screen-lib-wall-detail` / `screen-lib-draft-detail`
- **Wall detail:** ảnh full + Back + Download (loading "EXPORTING..." → Toast "Image Saved to Device Gallery") + `RE-MODDING` (về Garage) + `APPLY MATRIX` (`applyFromLibrary` — **bỏ qua ads**, set context = library).
- **Draft detail:** ảnh full + `CONTINUE MODDING` (về Garage tiếp tục chỉnh).

### 3.8 `screen-settings` — SYSTEM.CFG
Danh sách item dạng "terminal config":
- `FEEDBACK TO TERMINAL`, `SHARE SECURE NODE` (→ Share), `RATE APP ON NET.STORE` (**→ Modal Rate App 5 sao**), `PRIVACY MATRIX POLICY`, `SYSTEM LANGUAGE` (VIETNAMESE), `CORE VERSION` (v1.0.0).

### 3.9 `screen-share` — NODE.SHARE
- **Ảnh wallpaper vừa tạo** (preview `#share-preview-img`) + nút chia sẻ Facebook / Instagram / TikTok (mock loading) + nút **COPY LINK** (→ Toast "Link Copied to Clipboard").
- Back động (`handleShareBack`): về Settings hoặc về Garage tùy luồng đi vào.
- Là điểm cuối của **Viral Loop** khi set wallpaper thành công từ Garage.

---

## 4. Hệ thống Modal & Phản hồi (Feedback System)

| Modal / Overlay | Vai trò |
|-----------------|---------|
| `modal-global-loading` | Loading ngầm chuẩn (`showLoadingModal`) cho mọi tác vụ "nặng" (~1.5s) — thanh scan + text trạng thái |
| `modal-network-error` | Lỗi mất kết nối (pink) — SETTINGS / RETRY / kích hoạt mạng. Có cơ chế **lưu & retry tác vụ bị gián đoạn** (`interruptedTask`) |
| `modal-unsaved-changes` | Cảnh báo rời Garage chưa lưu — SAVE DRAFT / HỦY BỎ / KEEP EDITING |
| `modal-video-paywall` | Paywall — đồng ý xem Reward Video Ad để mở khóa |
| `modal-set-wallpaper` | Chọn phân vùng áp dụng — HOME / LOCK / BOTH; sau thành công điều hướng phân nhánh (garage→Share / gallery→Gallery / library→Library) |
| `modal-rate-app` | Rate App 5 sao (`setRating`/`confirmRating`) → direct store |
| `video-ads-overlay` | Màn hình quảng cáo giả lập đếm ngược 5s; mục đích `apply` hoặc `unlock` |
| `cyber-toast` | **Toast pill chung** (`showToast`) — glow + haptic, tự ẩn ~2.5s; biến thể `pink`/`flash` |
| `toast-network-status` | Toast `OFFLINE_MODE` (hiện ~2s) |

---

## 5. UX Cốt lõi (Core UX Patterns)

- **Tối giản số chạm:** Home → chọn phôi → Garage (mod) → Preview → Apply → Set. Bỏ bước rườm rà; Preview ẩn toolbar.
- **Trực tiếp & cơ học:** kéo–thả, pinch-zoom, scroll-scale cho cảm giác "độ" linh kiện như thật. Nút có phản hồi scale khi nhấn.
- **An toàn dữ liệu:** chặn mất việc bằng modal Unsaved Changes; cho lưu Draft và tiếp tục sau.
- **Bền với mạng yếu:** mọi tác vụ phụ thuộc mạng đều kiểm tra `checkNetworkStatus()`, lưu lại tác vụ để **RETRY** khi có mạng.

---

## 6. UX Kiếm tiền (Monetization UX)

- **Minh bạch, không pop-up phá đám:** Reward Ads chỉ bật khi user chủ động bấm (mở khóa item Premium, hoặc bấm `APPLY`). Riêng `APPLY` tại Screen 4 **luôn** kèm 1 lượt ads (kể cả phôi Free) — vẫn do user chủ động, không phải pop-up tự nhảy.
- **Đánh dấu Premium:** badge `PREMIUM` (pink) trên card.
- **Rewarded Ads tự nguyện:** modal đề nghị xem video (đồng ý / không), sau khi xem mới mở khóa Set Wallpaper.
- **Native Ad** chèn khéo trong feed gallery (không che hành động chính).

---

## 7. State & Data (Mock)

- `MOCK_THEMES` (6 theme: GTR, Neo-Tokyo, HUD Orbital, Lambo, NSX, Chiron) + `CATEGORIES`.
- State runtime: `selectedCategory`, `favoriteFilterActive`, `selectedTheme`, `libraryActiveTab`, `bulkSelectMode`, `selectedLibraryItems`, `savedWallpapers`, `savedDrafts`, `undoStackStickers`, `redoStackStickers`, `isOnlineSimulation`, `interruptedTask`, `previewDisplayState`.
- State premium/điều hướng mới: `usedPremiumInDesign`, `wallpaperSetContext`, `pendingPremiumUnlock`, `rewardVideoPurpose`, `shareBackContext`, `currentRating`.
- Lưu trữ trong bộ nhớ JS (chưa persist) — reload là mất.

---

## 8. Khoảng cách so với Brief gốc (Gaps / Backlog)

Những điểm brief ban đầu nêu nhưng **chưa có trong prototype** — đã thống nhất chuyển sang Roadmap Phase 2 (xem `prd.md` §9):

1. ✅ **Haptic Feedback** — ĐÃ triển khai (`navigator.vibrate`).
2. **Slider thông số** (cường độ sấm sét, tốc độ quạt, dải RGB): hiện thay bằng pinch/scroll scale sticker — chưa có slider hiệu ứng động.
3. **Tùy biến mã màu HEX/RGB cho UI** & preset ROG Red / Razer Green: chưa có (đang cố định Cyberpunk Cyan/Pink/Yellow).
4. **HUD Dashboard widget số liệu thật** (Nhiệt độ pin, RAM, dung lượng dạng speedometer/HP bar): mới có HUD tĩnh trong ZeroUI Preview.
5. **Persist dữ liệu** (localStorage/back-end): chưa có.

> Đề xuất ưu tiên (UX): (4) widget số liệu thật → khác biệt mạnh nhất với tệp gamer; (3) bộ chọn màu accent → tăng cảm giác "trao quyền"; (2) slider hiệu ứng động trong Garage để đúng tinh thần "độ".
