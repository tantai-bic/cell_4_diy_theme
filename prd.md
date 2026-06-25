# TÀI LIỆU YÊU CẦU SẢN PHẨM (PRODUCT REQUIREMENTS DOCUMENT - PRD)

## 1. Thông tin chung (Tổng quan dự án)

* **Tên dự án (Tạm thời):** DIY Wallpaper & Theme Customizer App (Modding Engine)
* **Phiên bản:** 1.0.0 (Giai đoạn MVP - Minimum Viable Product)
* **Nền tảng mục tiêu:** iOS & Android
* **Người sở hữu sản phẩm (PO):** [Tên của bạn]

---

## 2. Tầm nhìn & Mục tiêu sản phẩm

### Tầm nhìn (Vision)

Trở thành "Trạm độ giao diện" (Control Hub / Modding Engine) hàng đầu dành cho điện thoại, nơi người dùng có thể can thiệp và tùy biến sâu (modding) màn hình thiết bị của mình thành một cỗ máy gaming, bảng điều khiển siêu xe hoặc giao diện Cyberpunk đậm chất cá nhân.

### Mục tiêu kinh doanh (Business Objectives)

* **Thâm nhập thị trường:** Tiếp cận mạnh mẽ cộng đồng game thủ và tín đồ công nghệ thông qua các chiến dịch UA (User Acquisition) phô diễn tính năng "độ" hình nền động, thông số phần cứng (HUD).
* **Tối ưu hóa doanh thu (Monetization):** Xây dựng luồng doanh thu thông minh, **tuyệt đối tôn trọng trải nghiệm người dùng**. Chuyển hóa thói quen "cày game lấy skin" thành hành vi tự nguyện xem Reward Ads để lấy hiệu ứng cao cấp.
* **Gia tăng lòng trung thành:** Giữ chân người dùng bằng chất lượng tài nguyên khắt khe (chuẩn 4K/8K, hiệu ứng hạt mượt mà) và không gây hao pin, nóng máy.

---

## 3. Khách hàng mục tiêu & Trải nghiệm người dùng (Persona)

* **Nhân khẩu học:** Nam giới, từ 13 đến 35 tuổi (Chủ đạo là Gen Z và Millennials).
* **Sở thích & Đam mê:** Thể thao điện tử (Esports), phần cứng máy tính (PC building), siêu xe (JDM, Supercars), văn hóa Anime/Manga, Sci-fi và Cyberpunk.
* **Hành vi & Tâm lý cốt lõi:**
* **Tech-savvy & Modding:** Có kiến thức công nghệ, thích can thiệp sâu vào thiết bị. Coi smartphone như một cỗ máy phần cứng cần được "độ" cho ngầu.
* **Khắt khe về hiệu năng:** Đề cao tính tối ưu, không dung túng cho các app rác gây giật lag, hao pin. Tiêu chuẩn hình ảnh rất cao (dễ nhận ra ảnh upscale giả mạo, yêu cầu chuẩn 4K/8K thực tế).
* **Tâm lý chi trả (Premium Value):** Sẵn sàng chi tiền hoặc "trả phí" bằng thời gian (xem Ads) cho các vật phẩm kỹ thuật số nếu chúng mang lại giá trị độc quyền, "tiền nào của nấy" (giống như mua skin trong game).


* **Rào cản & Thách thức (Ad-Aversion):** Nhóm này cực kỳ ghét quảng cáo rác (Interstitial/Pop-up nhảy bất thình lình) và thường xuyên dùng Ad-blocker. Ép xem quảng cáo vô lý = Xóa app ngay lập tức.

---

## 4. Phạm vi sản phẩm & Tính năng cốt lõi (Product Scope)

Ứng dụng sẽ tập trung xoay quanh 5 trụ cột tính năng chính để đáp ứng tiêu chuẩn của tệp Gamer/Tech-enthusiasts:

### 4.1 Khám phá & Phân loại Nội dung (Database / Classes)

* Cung cấp bộ lọc thông minh (Factions/Classes) tiếp cận kho theme chất lượng cao (JDM, Hypercar, Cyberpunk, Anime).
* **Hệ thống phân cấp nội dung:** Kho dữ liệu phân tách rõ ràng giữa nội dung Miễn phí (Free) và Cao cấp (Premium). Các Theme Premium được đánh dấu rõ ràng bằng **Icon Khóa Neon / Huy hiệu VIP** ở góc trên bên trái của Card Theme.

### 4.2 Trải nghiệm nhanh (Luồng Preview & Apply)

* Cho phép lướt chọn (Swipe Feeds) tại Screen 3 để xem trước Theme toàn màn hình.
* **Yêu thích (Favorites):** Người dùng thả/bỏ tim ngay trên Card Theme (Screen 2/3), kèm Toast xác nhận. Bộ lọc "Đã yêu thích" hiển thị nhanh các theme đã đánh dấu (không trộn lẫn với Draft).
* **Xem trước thực tế (Full Preview - Screen 5):** Chế độ xem trước toàn màn hình mô phỏng thiết bị thật, có công tắc chuyển giữa *"Hiển thị icon App"* và *"Màn hình khóa (Clock screen)"*. Màn này thuần xem trước, **không có nút Apply trực tiếp**.
* **Quy tắc Áp dụng (Apply Logic):**
* *Với Theme Free:* Áp dụng trực tiếp không rào cản để tạo trải nghiệm "Wow" ban đầu.
* *Với Theme Premium:* Người dùng phải mở khóa vật phẩm bằng cách tự nguyện xem Reward Ads.
* **Modal Set Wallpaper:** Sau khi Apply hợp lệ, người dùng chọn phân vùng áp dụng: `HOME_SCREEN`, `LOCK_SCREEN`, hoặc `BOTH`.



### 4.3 Trạm độ Giao diện (Modding Garage)

* **Bộ công cụ "độ" MVP (Screen 4):** Xóa nền AI (Remove BG - tác vụ cloud, gọi Modal Loading), Thêm Chữ (Sci-Fi Text), Thêm Sticker/Phụ tùng, Thêm Ảnh từ thiết bị, cùng cặp **Hoàn tác / Làm lại (Undo / Redo)**.
* **Khóa vật phẩm:** Các "Phụ tùng" (Parts) và công cụ cao cấp được gắn Icon Khóa/Vương miện Premium. Bấm vào item khóa → xem Reward Ads để **mở khóa dùng 1 lần** → Toast "Item Unlocked!".
* **An toàn dữ liệu:** Bấm Back khi đang chỉnh sửa → Modal Unsaved Changes (Save Draft / Hủy bỏ / Keep Edit).
* **Bộ lọc kiểm duyệt trước khi Apply:**
* *Chỉ gọi Video Ads khi:* Phôi gốc là Premium HOẶC người dùng có sử dụng bất kỳ phụ tùng/công cụ Premium nào.
* *Bỏ qua Video Ads khi:* Phôi gốc là Free VÀ chỉ dùng đồ Free.

> ⚠️ **Lưu ý đồng bộ (Sync FRD→PRD):** Các tính năng *Modding Sliders (RGB/thông số hạt), VFX động (Khói/Tia lửa/Glitch), HUD Dashboard số liệu thật (thanh máu/đồng hồ tốc độ/% pin)* thuộc **tầm nhìn** nhưng **CHƯA nằm trong luồng FRD/MVP hiện tại** → chuyển sang Roadmap (xem §9). Tránh quảng bá UA tính năng chưa tồn tại với tệp user tech-savvy.



### 4.4 Quản lý cá nhân & Chính sách tái sử dụng (Arsenal Storage)

* Hệ thống quản lý phân tách "Sản phẩm đã set" (Tab Wallpaper) và "Bản độ dang dở" (Tab Draft).
* **Đảm bảo UX thân thiện:** Tại Tab Wallpaper, các theme đã set thành công (dù gốc là Premium) đều được xem là *Đã mở khóa vĩnh viễn*. Khi click vào để Apply lại, hệ thống miễn phí hoàn toàn (không bắt xem lại Ads).
* **Bulk Select & Delete:** Cho phép chọn nhiều mục để xóa hàng loạt → Modal Loading giải phóng ổ đĩa → Toast "Items Deleted Successfully".
* **Màn trung gian Wallpaper:** Click item Tab Wallpaper mở màn chi tiết có nút **Lưu ảnh về thiết bị** (Toast "Image Saved to Device Gallery"), nút **Edit** (về Screen 4) và **Apply** (bỏ qua Ads). Click item Tab Draft mở thẳng bản nháp full với nút Edit để tiếp tục độ.

### 4.5 Lan tỏa cộng đồng

* Tích hợp cổng API chia sẻ lên các mạng xã hội (Facebook, TikTok, Instagram, Discord) để tận dụng traffic Organic từ việc khoe "Góc máy/Màn hình độ".
* **Viral Loop (kích hoạt khoe thành quả):** Sau khi Set Wallpaper thành công **từ Trạm độ (Screen 4)**, hệ thống tự động đẩy người dùng sang Màn hình Chia sẻ kèm chính phôi vừa thiết kế — đánh đúng tâm lý khoe đồ độ. (Apply từ Screen 3 / Thư viện thì trả về context cũ, không ép chia sẻ.)
* **Copy Link:** Nút copy liên kết chia sẻ nhanh, kèm Toast "Link Copied to Clipboard".

### 4.6 Cấu hình hệ thống & Hỗ trợ (Settings)

* Màn Settings cung cấp các tác vụ: **Feedback** (mở app email), **Share App** (Modal icon mạng xã hội), **Rate App** (Modal 5 sao → direct CH Play/App Store), **Privacy Policy**, **App Version**, và **Ngôn ngữ** (tùy chọn đổi ngôn ngữ hiển thị).

---

## 5. Mô hình doanh thu (Monetization Model)

Vì tệp người dùng có **mức độ chịu đựng quảng cáo rác bằng 0**, ứng dụng sử dụng mô hình B2C khéo léo, minh bạch và tự nguyện:

* **Ads Native (Quảng cáo tự nhiên):** Chèn xen kẽ vào luồng lướt theme (Screen 3) dưới dạng bảng LED quảng cáo Cyberpunk. Đảm bảo lượt hiển thị (Impressions) cao mà không phá vỡ vibe của app, không gây ức chế như Pop-up.
* **Reward Ads (Quảng cáo video đổi thưởng):** Nguồn thu eCPM cao nhất. Được thiết kế như một cơ chế "Cày 30s lấy đồ VIP", kích hoạt tại các điểm nút:
* Khi Apply Theme Premium (tại Screen 3).
* Khi mở khóa phụ tùng Premium trong Trạm độ (tại Screen 4).


* **Tương tác Thông điệp (Minh bạch 100%):** Nội dung hỏi xem Ads thay đổi linh hoạt:
* *Ngữ cảnh Screen 3:* "Bạn cần xem một video quảng cáo ngắn để mở khóa giao diện Cao cấp này."
* *Ngữ cảnh Screen 4:* "Bản độ của bạn có chứa phụ tùng Cao cấp. Đồng ý truyền tải luồng dữ liệu quảng cáo (Watch Ads) để áp dụng?"



---

## 6. Chỉ số đo lường thành công (Key Product Metrics - KPIs)

* **DAU / MAU:** Lượng người dùng hoạt động hàng ngày/hàng tháng.
* **Wallpaper Apply Rate:** Tỷ lệ cài đặt hình nền thành công trên tổng số lượt click xem theme.
* **Premium Part Usage Rate:** Tỷ lệ người dùng click chọn sử dụng các công cụ/hiệu ứng hạt có gắn mác Premium.
* **Ads Video Completion Rate:** Tỷ lệ xem hết 100% video Reward Ads. (Chỉ số sống còn: Nếu tỷ lệ này thấp, chứng tỏ các hiệu ứng Premium chưa đủ "đã" để game thủ đánh đổi 30s cuộc đời).
* **Modding Completion Rate:** Tỷ lệ đi từ bước "Edit" đến "Apply/Save Draft" thành công.
* **Retention Rate (Day 1, 7, 30):** Tỷ lệ quay lại ứng dụng.

---

## 7. Yêu cầu phi chức năng (Non-Functional Requirements)

* **Chất lượng hiển thị (Graphics Quality):** Tuyệt đối không dùng ảnh upscale giả mạo. Phôi theme và hiệu ứng VFX phải hỗ trợ độ phân giải cao (Native 4K/8K), không răng cưa, không mờ nhòe.
* **Tối ưu phần cứng & Pin (Performance):**
* Sử dụng base **True Dark Mode (AMOLED Black)** để tiết kiệm pin tối đa cho thiết bị.
* Màn hình Loading (Screen 1) phải tối ưu xử lý dưới 3 giây.
* Các tác vụ nặng (Xóa nền AI, Render đồ họa, Giải phóng bộ nhớ) bắt buộc dùng **Modal Loading chặn tương tác** để tránh Double-tap gây crash hệ thống.


* **Tương tác Cơ học (Haptics & Usability):** Ưu tiên thanh trượt (Sliders) thay vì menu dropdown. Các thao tác kéo trượt, Apply, Save phải đi kèm phản hồi rung xúc giác (Haptic feedback) tạo cảm giác nảy, chắc chắn như phím cơ. Các nút bấm phản hồi < 100ms.
* **Xử lý ngoại lệ (Error Handling):** Hệ thống liên tục kiểm tra Internet. Mất mạng phải gọi **Modal Lỗi Mạng** chặn tương tác lập tức thay vì để app treo vô thời hạn.
* **Bảo mật:** Tuân thủ chính sách quyền riêng tư khi truy cập kho ảnh (Gallery) của thiết bị.

---

## 8. Hệ thống Modal & Phản hồi UX (Feedback System)

Toàn bộ tương tác hệ thống chuẩn hóa qua bộ Modal & Toast dùng chung (nguồn chi tiết: `frd.md`).

### 8.1 Bộ Modal dùng chung

| Modal | Vai trò & Quy tắc |
|-------|-------------------|
| **Reward Ads (Video)** | Kích hoạt khi Apply Premium (S3) hoặc mở khóa phụ tùng Premium (S4). Nội dung text đổi theo ngữ cảnh. "Không xem" → giữ nguyên trạng thái; "Đồng ý" → phát ads → chạy tiếp hành động chờ. |
| **Set Wallpaper** | HOME / LOCK / BOTH. Sau chọn → Modal Loading "System Applying..." → thành công + **phát Haptic**. Điều hướng phân nhánh: từ S4 → Màn Share; từ S3/Thư viện → trả về context. |
| **Unsaved Changes** | Khi Back từ Screen 4: Save Draft / Hủy bỏ / Keep Edit. |
| **Loading / Processing** | Overlay chặn 100% (không click-outside, không Back vật lý). Chỉ tắt bằng code sau API success/fail. Dùng cho tác vụ nặng (Remove BG, Render, Purge). |
| **No Internet** | Mất mạng khi thao tác cần Internet. "Cài đặt" (mở settings mạng OS) / "Thử lại" (chạy lại tác vụ bị gián đoạn). Không cho tắt ra ngoài. |
| **Rate App** | 5 sao chọn → xác nhận → direct store. |
| **Share App** | Icon mạng xã hội → direct chia sẻ kèm link tải app. |

### 8.2 Hệ thống Toast (Non-blocking, tự ẩn 2–3s, kèm Haptic Pop)

Dạng pill nổi, nền đen mờ + viền glow, font kỹ thuật. Trigger: Thả/bỏ tim · Mở khóa item ("Item Unlocked!" có viền chớp) · Xóa thư viện · Lưu ảnh về máy · Đổi màu UI · Copy link.

> **Nguyên tắc bất biến (đối chiếu persona §3):** Tuyệt đối KHÔNG Interstitial/Pop-up nhảy bất thình lình. Mọi rào cản quảng cáo phải do người dùng chủ động kích hoạt.

---

## 9. Roadmap / Hậu MVP (Deferred Scope)

Các tính năng thuộc tầm nhìn nhưng đã được chủ động hoãn khỏi MVP (chưa có trong FRD/bản build) để bảo toàn chất lượng và tốc độ ra mắt:

* **Modding Sliders:** chỉnh dải màu RGB cho UI, thông số hạt (cường độ sấm sét, tốc độ quạt tản nhiệt).
* **VFX động:** Khói, Tia lửa, Glitch màn hình theo thời gian thực.
* **HUD Dashboard số liệu thật:** Widget kéo-thả hiển thị Nhiệt độ pin / RAM / Dung lượng dạng đồng hồ tốc độ / thanh máu.
* **Tùy biến mã màu HEX/RGB + preset** (ROG Red / Razer Green...) và Toast "System Color Updated".
* **Persist dữ liệu** (local/cloud) cho thư viện & draft.

> Đề xuất ưu tiên Phase 2 (theo giá trị khác biệt với tệp gamer/mê xe): (1) HUD Dashboard số liệu thật → "wow factor" mạnh nhất; (2) bộ chọn màu accent → cảm giác trao quyền; (3) Slider hiệu ứng động → đúng tinh thần "độ".

---

## Changelog

* **v1.0.1 — Sync ngược FRD → PRD:** Bổ sung Settings (§4.6), Favorites & Full Preview (§4.2), Viral Loop & Copy link (§4.5), Bulk Delete & Save-to-device (§4.4), Hệ thống Modal & Toast (§8); reconcile bộ công cụ Modding về đúng MVP và chuyển Sliders/VFX/HUD Dashboard sang Roadmap (§9).