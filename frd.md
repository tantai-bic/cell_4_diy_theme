# ĐẶC TẢ LUỒNG MÀN HÌNH & CHỨC NĂNG (SCREEN FLOW SPECIFICATION)

## Screen 1: Loading

* **Chức năng chính:** Tải các theme cơ bản của ứng dụng và khởi tạo hệ thống.
* **Giao diện:** Màn hình trống hoặc hiệu ứng vòng xoay loading, **không hiển thị logo**.
* **Luồng hoạt động & Kiểm tra mạng:** Hệ thống tự động kích hoạt tiến trình kiểm tra kết nối mạng (Network Check). Nếu không có mạng: Kích hoạt ngay Modal Lỗi kết nối mạng. Khi người dùng bấm "Thử lại" và có mạng thành công mới tiếp tục tiến trình. Nếu có mạng: Tải dữ liệu theme. Ngay khi load xong dữ liệu (dù sớm hay muộn) sẽ lập tức chuyển tự động sang Screen 2.

---

## Screen 2: Root (Trang chủ / Khám phá)

* **Nav bar:** Title của App (bên trái/chính giữa) + Icon Thư mục (bên phải - dẫn đến Screen Thư viện) + Icon Bánh răng (bên phải - dẫn đến Screen Setting).
* **Category Labels:** Danh sách các tab chủ đề (Ví dụ: Anime, Thiên nhiên, Tối giản...). Khi chọn category nào thì danh sách theme bên dưới tự động thay đổi theo chủ đề đó.
* **Filter:** Lọc theo các category "Đã yêu thích" (Favorite). Mặc định ban đầu là không chọn filter (Hiển thị tất cả).
* **Body:** Danh sách các Card Theme hiển thị dưới dạng lưới (Grid). Mỗi Card Theme có một **Icon Trái tim (Yêu thích)** nằm ở góc trên bên phải. **[Logic Premium]** Các theme thuộc nhóm cao cấp sẽ hiển thị thêm **Huy hiệu Premium (Badge)** hoặc **Icon Khóa/Vương miện** ở góc trên bên trái. Các theme cơ bản (Free) không có huy hiệu này.
* **Luồng hoạt động:** Bấm vào Icon Trái tim trên Card: Theme được đưa vào bộ lọc "Đã yêu thích" ngay tại màn hình này (Không ảnh hưởng đến mục "Draft" trong Thư viện) + Kích hoạt Toast: "Added to/Removed from Favorites". Bấm vào vùng khác của Card Theme: Chuyển sang Screen 3.

---

## Screen 3: Preview Theme & Swipe Feeds

* **Nav bar:** Button Back (bên trái - quay về Screen 2) + Title "Preview Theme" + Button "Apply" (bên phải).
* **Body (Feeds):** Hiển thị theme toàn màn hình, hỗ trợ thao tác vuốt (swipe) sang trái/phải để chuyển đổi theme. **[Kiểm tra Mạng]** Khi vuốt để tải theme/Ads, nếu mất mạng ngầm -> Hiện Modal Lỗi kết nối mạng. Giữa các card theme sẽ có vị trí chèn quảng cáo tự nhiên (Ads Native).
* **Bottom Bar:** Button "Edit" nằm chính giữa để tùy chỉnh lại theme.
* **Luồng hoạt động:** Hành động "Edit" hoặc "Apply" sẽ tác động trực tiếp lên Theme đang hiển thị trên màn hình tại thời điểm đó. Bấm "Edit": Chuyển sang Screen 4.
* **Bấm "Apply" [Logic Phân nhánh Premium]:** Trường hợp 1 (Theme Free): Kích hoạt trực tiếp Modal Set Wallpaper (Không có quảng cáo). Trường hợp 2 (Theme Premium): Bắt buộc kích hoạt Modal Xem Video Quảng Cáo. Xem xong mới gọi tiếp Modal Set Wallpaper.

---

## Screen 4: Edit / Custom Theme

* **Nav bar:** Icon Back (bên trái) + Bộ đôi Icon Hoàn tác (Undo) & Làm lại (Redo) (chính giữa) + Icon Preview (bên phải - sang Screen 5) + Button "Apply" (bên phải).
* **Body:** Ảnh hiển thị đầy đủ của Theme đang trong trạng thái chỉnh sửa.
* **Bottom Bar Tools:** *Remove BG (Xóa nền):* Yêu cầu mạng, gọi Modal Loading/Processing trong lúc AI xử lý. *Thêm Text (Chữ) / Thêm Sticker.* *Add photo:* Kích hoạt Modal Loading ngắn khi import. **[Logic Premium]** Các công cụ nâng cao được gắn Icon Premium.
* **Luồng bấm Back (Nav bar):** Xuất hiện Modal Unsaved Changes với 3 lựa chọn (Save draft, Hủy bỏ, Keep edit).
* **Luồng bấm Icon Premium (Tool):** Khi chọn vào phụ tùng/hiệu ứng có khóa -> Hiện Modal Xem Video Quảng Cáo để mở khóa dùng 1 lần -> Xem xong hiện Toast "Item Unlocked!".
* **Luồng bấm nút Preview:** Chuyển sang Screen 5.
* **Luồng bấm nút Apply [Logic Phân nhánh Premium]:** Nếu Phôi gốc là Premium HOẶC có sử dụng bất kỳ công cụ/phụ tùng Premium nào: Kích hoạt Modal Xem Video Quảng Cáo. Trái lại, nếu Phôi gốc Free VÀ chỉ dùng công cụ Free: Chuyển thẳng sang Modal Set Wallpaper.

---

## Screen 5: Full Preview Chế độ hiển thị

* **Mục đích:** Chỉ thuần túy dùng để xem trước giao diện thực tế khi áp dụng lên điện thoại, **không có nút "Apply" trực tiếp tại đây**.
* **Nav bar:** Button "X" (dùng để tắt chế độ xem trước và quay về Screen 4).
* **Body:** Giao diện theme full màn hình giả lập.
* **Bottom Bar:** Button thay đổi kiểu hiển thị: "Có icon App" <---> "Chỉ hiển thị màn hình khóa (Clock screen)".

---

## Screen Thư viện lưu trữ (My Library)

* **Nav bar:** Title "Thư viện của tôi" + Button Back (về Screen 2) + Button "Select" (kích hoạt Bulk Select). Khi bấm "Select" -> Xuất hiện Button "Delete".
* **Tabs phân loại:** Tab Wallpaper (Đã set làm hình nền thành công) và Tab Draft (Bản nháp lưu từ Screen 4).
* **Luồng hoạt động xóa (Bulk Select):** Chọn các theme -> Bấm "Delete" -> Kích hoạt Modal Loading để giải phóng ổ đĩa -> Hoàn tất, đóng loading + Cập nhật danh sách + Hiện Toast "Items Deleted Successfully".
* **Luồng Click Tab Wallpaper:** Đẩy vào màn hình hiển thị trung gian. Nav bar có Nút Back + Icon Lưu ảnh (Bật Modal Loading render ảnh -> Hiện Toast "Image Saved"). Body có Nút Edit (Sang Screen 4) và nút Apply. Các theme trong tab này mặc định bỏ qua Ads khi bấm Apply.
* **Luồng Click Tab Draft:** Đẩy vào màn hình Full Theme nháp. Giao diện có Nút "X" (Quay lại) + Button "Edit" nằm chính giữa dưới cùng. Bấm "Edit" tiến thẳng vào Screen 4.

---

## Screen Setting

* **Bố cục:** Nav bar có Icon Back (quay về Screen 2).
* **Danh sách tác vụ:**
* **Feedback:** Mở ứng dụng email trên thiết bị để gửi góp ý.
* **Share:** Dẫn đến Modal chia sẻ app.
* **Rate app:** Dẫn đến Modal đánh giá app.
* **Privacy policy:** Hiển thị chính sách bảo mật.
* **App Version:** Hiển thị thông tin phiên bản hiện tại.
* **Ngôn ngữ (Language):** Tùy chọn thay đổi ngôn ngữ hiển thị trong app.

---

## Màn hình chia sẻ Wallpaper (Cổng cộng đồng)

* **Nav bar:** Bên trái (Nút Back về Setting hoặc Screen 4 tùy luồng) + Bên phải (Nút Home về thẳng Screen 2 chỉ với 1 chạm).
* **Body:** Hiển thị **wallpaper vừa tạo thành công** cùng các công cụ và nút API chia sẻ mạng xã hội (Facebook, Instagram, TikTok...).
* **Tương tác:** Nhấn nút chia sẻ -> Kiểm tra Mạng -> Bật Modal Loading đóng gói tệp tin -> Chuyển sang App thứ ba. Bấm copy link -> Hiện Toast "Link Copied to Clipboard".

---

## Hệ thống các Modal tương tác (Dùng chung)

### 1. Modal Xem Video Quảng Cáo (Reward Ads)

* **Trạng thái kích hoạt:** Khi Apply Theme/Bản độ Premium, hoặc Mở khóa phụ tùng Premium.
* **Nội dung:** Thông báo linh hoạt dựa trên ngữ cảnh. Mở khóa theme Screen 3: "Bạn cần xem một video quảng cáo ngắn để mở khóa giao diện Cao cấp này." Mở khóa item Screen 4: "Bản thiết kế của bạn có chứa các vật phẩm Cao cấp. Hãy xem một video quảng cáo để áp dụng chúng."
* **Lựa chọn:** Bấm "Không xem" sẽ tắt modal, giữ nguyên trạng thái cũ. Bấm "Đồng ý xem" sẽ bật Modal Loading đệm, phát quảng cáo toàn màn hình, và gọi tiếp hành động chờ sau khi xem xong.

### 2. Modal Set Wallpaper

* **Nội dung:** Xuất hiện ngay khi bấm Apply (hợp lệ) ở Screen 3, Screen 4 (sau ads), hoặc Tab Wallpaper trung gian.
* **Lựa chọn:** `[ SYSTEM_HOME_SCREEN ]` (Màn hình chính), `[ SYSTEM_LOCK_SCREEN ]` (Màn hình khóa), hoặc `[ SET_BOTH_COMBAT ]` (Cả hai).
* **Luồng kết thúc & Điều hướng:** Sau khi chọn, đóng modal ➔ Hiện Modal Loading ("System Applying...") ➔ Thành công, phát rung (Haptic Feedback) và tự động tắt loading.
* **Phân nhánh điều hướng:** * **TRƯỜNG HỢP A (Từ Screen 4):** Đẩy người dùng tiến thẳng sang **Màn hình chia sẻ Wallpaper** kèm theo phôi hình nền họ vừa thiết kế thành công để kích thích hành vi khoe thành quả.
* **TRƯỜNG HỢP B (Từ Screen 3 / Thư viện):** Tự động trả người dùng về đúng màn hình nền (context) trước đó họ đang đứng.



### 3. Modal Unsaved Changes

* **Nội dung:** Xuất hiện khi bấm Back từ Nav bar Screen 4.
* **Lựa chọn:** Save Draft (Lưu vào thư viện nháp), Hủy bỏ (Thoát không lưu), hoặc Keep Edit (Ở lại tiếp tục).

### 4. Modal Loading / Processing (Chặn tương tác)

* **Giao diện:** Overlay mờ phủ toàn màn (Background Dim), giữa có Spinner xoay tròn. Text thay đổi theo tác vụ (Processing..., Saving..., Applying...).
* **Đặc tính:** Tuyệt đối chặn (Blocking 100%). Không cho phép bấm Click-outside hoặc phím Back vật lý. Chỉ tắt bằng trigger code sau khi API Success/Failed.

### 5. Modal Lỗi kết nối mạng (No Internet Connection)

* **Trạng thái kích hoạt:** Khi hệ thống kiểm tra thấy mất mạng lúc đang thao tác chức năng cần Internet.
* **Nội dung:** "Không có kết nối mạng. Vui lòng kiểm tra lại Wifi hoặc Dữ liệu di động để tiếp tục sử dụng dịch vụ."
* **Lựa chọn:** Bấm "Cài đặt" gọi API mở mục Cài đặt mạng của điện thoại. Bấm "Thử lại" để kích hoạt lại tác vụ vừa bị gián đoạn. Không cho phép bấm tắt ra ngoài.

### 6. Modal Đánh giá App (Rate App)

* **Nội dung:** Hiển thị 5 ngôi sao chưa active để user chọn.
* **Lựa chọn:** Sau khi user click chọn số sao mong muốn và bấm nút xác nhận, hệ thống sẽ tự động direct sang CH Play / App Store để đánh giá.

### 7. Modal Chia sẻ App (Share App)

* **Nội dung:** Hiển thị modal với các icon mạng xã hội.
* **Lựa chọn:** Khi user bấm vào icon tương ứng, hệ thống tự động direct đến tính năng chia sẻ của mạng xã hội đó với nội dung chứa link tải app (CH Play / App Store).

---

## Hệ thống Toast Message (Thông báo nhanh không gián đoạn)

* **Giao diện & UX:** Dạng thanh Pill nổi (Cạnh trên/dưới), nền đen mờ 80% kèm viền phát sáng (Glow), font chữ kỹ thuật. Kèm nhịp rung cực nhẹ (Haptic Pop).
* **Đặc tính:** Tự biến mất sau 2 - 3 giây. Không chặn thao tác (Non-blocking).
* **Danh sách Trigger kích hoạt:**
* Thả/bỏ tim (Screen 2/3): `"Added to Favorites"` / `"Removed from Favorites"`.
* Xem xong Ads mở khóa công cụ (Screen 4): `"Item Unlocked!"` (Kèm viền chớp sáng).
* Xóa xong trong Thư viện: `"Items Deleted Successfully"`.
* Lưu ảnh máy ở màn trung gian: `"Image Saved to Device Gallery"`.
* Đổi màu UI ở Setting: `"System Color Updated"`.
* Copy link ở Share: `"Link Copied to Clipboard"`.