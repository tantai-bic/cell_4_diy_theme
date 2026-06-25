PHẦN 1: ACCEPTANCE CRITERIA (TIÊU CHÍ NGHIỆM THU CHO DEV/TESTER)

Dưới đây là các tiêu chí nghiệm thu dạng User Story (Givven - When - Then) cho các luồng xử lý cốt lõi trong PRD nhằm đảm bảo chất lượng sản phẩm (QA/QC).

AC 1: Luồng tải dữ liệu tại Screen 1 (Loading)

Scenario: Tải dữ liệu theme cơ bản thành công.

Given: Người dùng vừa mở ứng dụng.

When: Hệ thống kiểm tra và tải xong cấu trúc dữ liệu theme.

Then: Ứng dụng lập tức tắt màn hình loading và chuyển tự động sang Screen 2 (Root). Không hiển thị bất kỳ logo nào, chỉ hiển thị hiệu ứng vòng xoay loading trên nền trống.

AC 2: Luồng Apply nhanh không Ads tại Screen 3 (Preview)

Scenario: Cài đặt hình nền mặc định từ kho dữ liệu.

Given: Người dùng đang ở Screen 3 và chọn một theme mặc định.

When: Người dùng nhấn nút "Apply" trên Nav bar.

Then: Hệ thống hiển thị trực tiếp Modal Set Wallpaper (Không được hiển thị quảng cáo video). Sau khi chọn Home/Lock/Both, hệ thống hiện Modal Loading (Processing...) ngầm và áp dụng hình nền thành công.

AC 3: Luồng Khóa tính năng bằng Video Ads tại Screen 4 (Edit)

Scenario: Người dùng áp dụng theme tự chế (DIY).

Given: Người dùng đã chỉnh sửa hình nền bằng bộ công cụ (Text, Sticker...).

When: Người dùng nhấn nút "Apply" trên Nav bar của Screen 4.

Then: Hệ thống phải kích hoạt Modal Xem Video Quảng Cáo.

Nếu bấm "Không xem": Tắt modal, giữ người dùng ở lại Screen 4, không đổi hình nền.

Nếu bấm "Đồng ý xem": Phát Reward Ads toàn màn hình. Khi xem hết 100% thời lượng, hệ thống tự động gọi tiếp Modal Set Wallpaper. Sau khi cài đặt xong, người dùng vẫn đứng ở Screen 4.

AC 4: Kiểm soát trạng thái chặn tương tác của Modal Loading (Dùng chung)

Scenario: Đảm bảo độ ổn định hệ thống khi xử lý tác vụ nặng (Xóa nền AI, Xóa hàng loạt, Đổi hình nền).

Given: Hệ thống đang hiển thị Modal Loading / Processing (Spinner xoay tròn).

When: Người dùng cố tình nhấn ra vùng ngoài (Click-outside) hoặc bấm nút Back vật lý của thiết bị.

Then: Hệ thống phải chặn hoàn toàn các tương tác này. Màn hình chỉ được giải phóng khi tác vụ chạy ngầm trả về kết quả thành công hoặc thất bại.

PHẦN 2: ACTION PLAN (KẾ HOẠCH HÀNH ĐỘNG BIẾN PRD THÀNH SẢN PHẨM)

Kế hoạch phân rã công việc chi tiết cho các phòng ban để chuẩn bị cho giai đoạn Sprint:

Lộ trình triển khai cụ thể:

Giai đoạn 1: UI/UX & Wireframing (Thời gian dự kiến: 1 - 2 tuần) - Giai đoạn hiện tại của bạn

[ ] Design: Vẽ Wireframe (Low-fidelity) cho 5 màn hình chính và hệ thống 3 Modal dùng chung dựa trên tài liệu đặc tả.

[ ] Design: Thiết kế giao diện độ nét cao (High-fidelity) trên Figma; xây dựng Prototype động mô phỏng luồng vuốt (Swipe feeds ở Screen 3) và luồng chỉnh sửa (Screen 4).

[ ] Product: Kiểm thử Prototype (User Testing) trên một nhóm nhỏ để đánh giá độ tiện dụng của bộ công cụ Edit (Text, Sticker, Remove BG).

Giai đoạn 2: Chuẩn bị Kỹ thuật (Thời gian dự kiến: 3 - 5 ngày)

[ ] Technical Lead: Lựa chọn giải pháp/Thư viện bên thứ ba (Third-party SDK) phù hợp cho tính năng Remove BG bằng AI và bộ công cụ chèn chữ/sticker.

[ ] Product/Dev: Đăng ký tài khoản nhà phát triển mạng lưới quảng cáo (ví dụ: Google AdMob, AppLovin) để lấy ID cấu hình cho Ads Native (Screen 3) và Reward Ads (Screen 4).

[ ] Dev: Thiết lập cấu trúc Local Storage (SQLite hoặc Room/CoreData) để lưu trữ dữ liệu cho Tab "Draft" và Tab "Wallpaper" của Thư viện.

Giai đoạn 3: Phát triển Code (Development) (Thời gian dự kiến: 2 - 3 tuần)

[ ] Frontend Dev: Cài đặt giao diện luồng Khám phá (Screen 1, Screen 2, Screen 3) và tích hợp hiển thị Ads Native.

[ ] Frontend Dev: Phát triển bộ canvas chỉnh sửa hình ảnh tại Screen 4 (Undo/Redo, xử lý text/sticker) và màn hình Preview giả lập (Screen 5).

[ ] Backend/Dev: Tích hợp API tách nền AI, luồng gọi SDK Ads Video Đổi thưởng, và hàm can thiệp hệ điều hành để đổi hình nền thiết bị (Home/Lock Screen).

Giai đoạn 4: Kiểm thử chất lượng (QC/Testing) (Thời gian dự kiến: 5 - 7 ngày)

[ ] QA/QC: Viết Test Cases chi tiết dựa trên phần Acceptance Criteria (AC) ở trên.

[ ] QA/QC: Kiểm thử các trường hợp đặc biệt (Edge Cases): Mất kết nối internet khi đang xem Reward Ads, tải ảnh dung lượng quá lớn (>20MB) từ máy vào bộ edit, bấm xóa hàng loạt 100 ảnh cùng lúc trong Thư viện.

Giai đoạn 5: Phát hành (Deploy & Go-live)

[ ] Product/Marketing: Chuẩn bị hình ảnh Mockup sản phẩm, viết mô tả ứng dụng (Store Listing), cấu hình Privacy Policy link (để gắn vào mục Setting).

[ ] Dev/PO: Đóng gói bản cài đặt (.apk, .aab, .ipa) và đẩy lên chợ ứng dụng Google Play Store và Apple App Store để chờ phê duyệt.