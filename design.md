---

### BẢNG ĐẶC TẢ VỊ TRÍ & TRẢI NGHIỆM GIAO DIỆN (UI/UX BLUEPRINT)

| Khu vực / Màn hình | Vị trí | Thành phần UI | Styling & Visual (Thiết kế trực quan) | UX / Trải nghiệm (Tương tác) |
| --- | --- | --- | --- | --- |
| **Hệ thống (Global)** | Toàn App | Màu nền & Chữ | Nền True Dark Mode (#000000). Font chữ Orbitron/Rajdhani. Số liệu dạng LED. | Nổi bật chi tiết hình nền. Giảm mỏi mắt cho gamer. |
| **Hệ thống (Global)** | Toàn App | Nút bấm & Icon | Dạng Outline, góc cạnh (lục giác/hình thang). Có màu Accent (Đỏ/Xanh/Vàng). | Phát sáng (Glow) nhấp nháy khi được chọn hoặc Active. |
| **Screen 1: Loading** | Trung tâm | Vòng xoay Loading | Hiệu ứng cơ học/neon công nghệ quay tròn. Không có Logo app. | Kích hoạt Network Check ngầm. Mượt mà, chuyển cảnh ngay khi xong. |
| **Screen 2: Control Hub** | Nav Bar (Top) | Title, Icon Arsenal, Icon Cài đặt | Title dạng Digital LED. Icon Arsenal dạng hộp vũ khí. Icon bánh răng cơ khí. | Chạm mượt, phản hồi sáng viền khi bấm chuyển màn. |
| **Screen 2: Control Hub** | Dưới Nav Bar | Factions (Tabs) & Filter | Các khối tab góc cạnh. Filter dạng Toggle switch cơ học. | Lướt ngang (Horizontal Scroll) trơn tru giữa các hệ. |
| **Screen 2: Control Hub** | Body | Card Theme & Nút Yêu thích | Lưới Grid. Icon tim outline góc phải trên của Card. | Bấm tim ➔ Icon phát sáng (Glow) + Hiện Toast "Added to Favorites". |
| **Screen 3: Preview** | Nav Bar (Top) | Nút Back, Title, Nút APPLY | Chữ "PREVIEW SYSTEM". Nút APPLY thiết kế khối kỹ thuật nổi bật. | Bấm APPLY ➔ Gọi ngay Modal Set Wallpaper (Không có quảng cáo). |
| **Screen 3: Preview** | Body | Feeds toàn màn hình | Ảnh full màn. Khung Ads Native lồng ghép viền bảng điện tử. | Vuốt trái/phải mượt mà. Mất mạng khi vuốt gọi Modal Lỗi kết nối. |
| **Screen 3: Preview** | Bottom Bar | Nút MODDING GARAGE | Nút to, chính giữa, viền Neon chớp nháy thu hút ánh nhìn. | Chạm để tiến vào màn độ xe (Screen 4). |
| **Screen 4: Modding** | Nav Bar (Top) | Back, Undo/Redo, Preview, APPLY | Mũi tên Undo/Redo sắc nét. Nút APPLY có thể kèm icon Khóa nhỏ nếu đang dùng đồ Premium. | Bấm Back ➔ Gọi Modal Unsaved. Bấm Apply ➔ Gọi Modal Video Ads hoặc Set Wallpaper. |
| **Screen 4: Modding** | Bottom Bar | Các Tab Phụ tùng (Parts) | Hiển thị dạng khay chứa linh kiện. Icon khóa Neon cho vật phẩm Premium. | Bấm Item Premium ➔ Bật Modal Ads Unlock + Toast "Item Unlocked" khi xong. |
| **Screen 4: Modding** | Body (Tương tác) | Sliders & HUD Dashboard | Thanh trượt cơ học. Widget (Pin, RAM) dạng đồng hồ xe đua/thanh máu. | Kéo thanh trượt ➔ Phát rung Haptic. Kéo thả Widget linh hoạt. |
| **Screen 5: Full Preview** | Toàn màn hình | Nút "X" (Top) & Toggle (Bottom) | Nút X viền Neon. Toggle chuyển đổi UI giả lập dạng công tắc gạt. | Ẩn hoàn toàn công cụ độ. Cho góc nhìn thực tế 100%. |
| **Arsenal (Kho)** | Nav Bar (Top) | Title, Back, Nút Select/DELETE | Nút Select đổi thành DELETE màu Đỏ phát sáng khi được Active. | Bấm Delete ➔ Modal Loading (Đang giải phóng bộ nhớ) + Toast Xóa thành công. |
| **Arsenal (Kho)** | Tabs & Body | Tab Wallpaper & Draft | Card hiển thị góc cạnh. Nhấn vào Wallpaper hiện 2 nút [RE-MODDING] & [APPLY]. | Bấm [RE-MODDING] hoặc [CONTINUE MODDING] đi thẳng vào Screen 4. |
| **Cài đặt & Share** | Màn hình List | Custom UI Color, Links, Buttons | Bảng chọn mã HEX/RGB. Nút Share dẫn đến cổng API mạng xã hội. | Chọn màu ➔ Đổi toàn bộ màu Accent của App + Toast "System Color Updated". |
| **Modal 1, 2, 3 (Action)** | Chính giữa | Modal Ads, Set Wallpaper, Unsaved | Khối hộp góc cạnh Cyberpunk. Các option là thanh ngang cơ học. | Rõ ràng, minh bạch. Nút hành động chính có viền rực rỡ hơn nút Hủy. |
| **Modal 4, 5 (Block)** | Toàn màn hình | Loading Spinner & Connection Error | Nền mờ (Dim). Loading dạng lõi lò phản ứng. Nút Retry/Settings cứng cáp. | Chặn Click-outside. Không cho user thoát ngang gây lỗi hệ thống. |
| **Toast Message** | Cạnh Trên/Dưới | Bảng thông báo nhỏ (Pill) | Nền đen mờ 80%, viền nhấp nháy. Font chữ gõ máy (Typewriter). | Rung Haptic nhẹ (Pop). Tự biến mất sau 2-3s. Không chặn thao tác (Non-blocking). |