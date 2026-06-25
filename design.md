---

### BẢNG ĐẶC TẢ VỊ TRÍ & TRẢI NGHIỆM GIAO DIỆN (UI/UX BLUEPRINT)

> 🔄 **Đã sync với build `index.html` + `frd.md` (v1.0.1).** Các mục đánh dấu ⚠️ **ROADMAP Phase 2** là tầm nhìn chưa có trong MVP (chi tiết `prd.md` §9). Màu/Modal/Tools phản ánh đúng bản đang chạy.

| Khu vực / Màn hình | Vị trí | Thành phần UI | Styling & Visual (Thiết kế trực quan) | UX / Trải nghiệm (Tương tác) |
| --- | --- | --- | --- | --- |
| **Hệ thống (Global)** | Toàn App | Màu nền & Chữ | Nền AMOLED Dark `#050508` (card `#141622`). Font Orbitron/Rajdhani. Số liệu dạng LED. | Nổi bật chi tiết hình nền. Giảm mỏi mắt cho gamer. |
| **Hệ thống (Global)** | Toàn App | Nút bấm & Icon | Dạng Outline, góc cạnh (clip-path). Accent **Cyberpunk**: Cyan `#00f3ff` / Pink `#ff0055` / Yellow `#ffee00`. *(Preset ROG Red / Razer Green = Roadmap.)* | Phát sáng (Glow) khi được chọn hoặc Active. |
| **Screen 1: Loading** | Trung tâm | Thanh scan + bitstream | Thanh "matrix fluid scan" neon + dòng nhị phân random. ⚠️ *Spec "không Logo" nhưng build có wordmark glitch `SYSTEM.ROOT` — chờ PO quyết.* | Kích hoạt Network Check ngầm. Chuyển cảnh ngay khi xong. |
| **Screen 2: Control Hub** | Nav Bar (Top) | Title, Icon Arsenal, Icon Cài đặt | Title dạng Digital LED. Icon Arsenal dạng hộp vũ khí. Icon bánh răng cơ khí. | Chạm mượt, phản hồi sáng viền khi bấm chuyển màn. |
| **Screen 2: Control Hub** | Dưới Nav Bar | Factions (Tabs) & Filter | Các khối tab góc cạnh (tab active nền vàng neon). Filter "Mục yêu thích" dạng nút bấm active viền cyan. | Lướt ngang (Horizontal Scroll) trơn tru giữa các hệ. |
| **Screen 2: Control Hub** | Body | Card Theme & Nút Yêu thích | Lưới Grid. Icon tim outline góc phải trên của Card. | Bấm tim ➔ Icon phát sáng (Glow) + Hiện Toast "Added to Favorites". |
| **Screen 3: Preview** | Nav Bar (Top) | Nút Back, Title, Nút APPLY | Chữ "PREVIEW SYSTEM". Nút APPLY thiết kế khối kỹ thuật nổi bật. | Bấm APPLY ➔ Gọi ngay Modal Set Wallpaper (Không có quảng cáo). |
| **Screen 3: Preview** | Body | Feeds toàn màn hình | Ảnh full màn. Khung Ads Native lồng ghép viền bảng điện tử. | Vuốt trái/phải mượt mà. Mất mạng khi vuốt gọi Modal Lỗi kết nối. |
| **Screen 3: Preview** | Bottom Bar | Nút MODDING GARAGE | Nút to, chính giữa, viền Neon chớp nháy thu hút ánh nhìn. | Chạm để tiến vào màn độ xe (Screen 4). |
| **Screen 4: Modding** | Nav Bar (Top) | Back, Undo/Redo, Preview, APPLY | Mũi tên Undo/Redo sắc nét. Nút APPLY có thể kèm icon Khóa nhỏ nếu đang dùng đồ Premium. | Bấm Back ➔ Gọi Modal Unsaved. Bấm Apply ➔ Gọi Modal Video Ads hoặc Set Wallpaper. |
| **Screen 4: Modding** | Bottom Bar | 4 công cụ: Rem BG, Thêm Chữ, Sticker, Thêm Ảnh | Khay tool dạng icon. Rem BG gắn 👑 Premium. | Bấm tool/sticker Premium ➔ Modal Ads Unlock → Toast "Item Unlocked!" (viền chớp). Rem BG/Thêm Ảnh gọi Modal Loading. |
| **Screen 4: Modding** | Body (Tương tác) | Canvas Workspace (ảnh nền + sticker) | Ảnh full + lớp sticker chồng. Sticker active có viền dashed cyan + nút xóa. Khay sticker pop-up 4 cột (item Premium gắn 👑). | Kéo–thả, pinch 2 ngón / cuộn chuột để zoom (0.3–4.0). Bấm nền trống để bỏ chọn. |
| **Screen 4: Modding** | Body | *Sliders RGB + HUD Dashboard số liệu thật* | *Thanh trượt cơ học + Widget Pin/RAM dạng đồng hồ xe đua/thanh máu.* | ⚠️ **ROADMAP Phase 2** — chưa có trong MVP build (xem `prd.md` §9). |
| **Screen 5: Full Preview** | Toàn màn hình | Nút "X" (Top) & Toggle (Bottom) | Nút X viền Neon. Toggle chuyển đổi UI giả lập dạng công tắc gạt. | Ẩn hoàn toàn công cụ độ. Cho góc nhìn thực tế 100%. |
| **Arsenal (Kho)** | Nav Bar (Top) | Title, Back, Nút Select/DELETE | Nút Select đổi thành DELETE màu Đỏ phát sáng khi được Active. | Bấm Delete ➔ Modal Loading (Đang giải phóng bộ nhớ) + Toast Xóa thành công. |
| **Arsenal (Kho)** | Tabs & Body | Tab Wallpaper & Draft | Card hiển thị góc cạnh. Nhấn vào Wallpaper hiện 2 nút [RE-MODDING] & [APPLY]. | Bấm [RE-MODDING] hoặc [CONTINUE MODDING] đi thẳng vào Screen 4. |
| **Cài đặt (Settings)** | Màn hình List | Feedback, Share, Rate, Privacy, Version, Language | Danh sách item "terminal config" góc cạnh, icon accent cyan. | Rate ➔ Modal 5 sao → direct store. Feedback ➔ mở email. |
| **Cài đặt (Settings)** | Màn hình List | *Custom UI Color (HEX/RGB picker)* | *Bảng chọn mã màu accent.* | ⚠️ **ROADMAP Phase 2** — Toast "System Color Updated" chưa active (xem `prd.md` §9). |
| **Màn Share** | Màn hình | Ảnh wallpaper + Social + Copy Link | Preview phôi vừa tạo (viền glow cyan) + nút FB/IG/TikTok + nút Copy Link. | Điểm cuối Viral Loop khi set từ Garage. Copy ➔ Toast "Link Copied to Clipboard". Back động về Setting/Garage. |
| **Modal Action** | Chính giữa | Reward Ads, Set Wallpaper, Unsaved Changes | Khối hộp góc cạnh Cyberpunk. Option là thanh ngang cơ học. | Minh bạch. Set Wallpaper (HOME/LOCK/BOTH) sau thành công **điều hướng phân nhánh**: S4→Share, S3→Gallery, Library→Library. |
| **Modal Block** | Toàn màn hình | Loading Spinner & Connection Error | Nền mờ (Dim). Loading dạng thanh scan. Nút Retry/Settings cứng cáp. | Chặn Click-outside. Retry chạy lại đúng tác vụ bị gián đoạn. |
| **Modal Hỗ trợ** | Chính giữa | Rate App (5 sao) & Share App | Hộp Cyberpunk; 5 sao vàng glow khi chọn. | Rate: chọn sao → xác nhận → direct store. Share: icon MXH → direct chia sẻ kèm link. |
| **Toast Message** | Cạnh Trên/Dưới | Bảng thông báo nhỏ (Pill) | Nền đen mờ 80%, viền nhấp nháy. Font chữ gõ máy (Typewriter). | Rung Haptic nhẹ (Pop). Tự biến mất sau 2-3s. Không chặn thao tác (Non-blocking). |