PHẦN 1: ACCEPTANCE CRITERIA (TIÊU CHÍ NGHIỆM THU CHO DEV/TESTER)

Dưới đây là các tiêu chí nghiệm thu dạng User Story (Givven - When - Then) cho các luồng xử lý cốt lõi trong PRD nhằm đảm bảo chất lượng sản phẩm (QA/QC).

AC 1: Luồng tải dữ liệu tại Screen 1 (Loading)

Scenario: Tải dữ liệu theme cơ bản thành công.

Given: Người dùng vừa mở ứng dụng.

When: Hệ thống kiểm tra và tải xong cấu trúc dữ liệu theme.

Then: Ứng dụng lập tức tắt màn hình loading và chuyển tự động sang Screen 2 (Root). Không hiển thị bất kỳ logo nào, chỉ hiển thị hiệu ứng vòng xoay loading trên nền trống.

> ⚠️ OPEN ISSUE (spec↔build): Build hiện tại hiển thị wordmark glitch `SYSTEM.ROOT` ở màn loading — mâu thuẫn với yêu cầu "không logo". Cần PO quyết: (a) coi đây là loading-text được phép, hay (b) gỡ bỏ để đúng FRD.

AC 2: Luồng Apply nhanh không Ads tại Screen 3 (Preview)

Scenario: Cài đặt hình nền mặc định từ kho dữ liệu.

Given: Người dùng đang ở Screen 3 và chọn một theme mặc định.

When: Người dùng nhấn nút "Apply" trên Nav bar.

Then: Hệ thống hiển thị trực tiếp Modal Set Wallpaper (Không được hiển thị quảng cáo video). Sau khi chọn Home/Lock/Both, hệ thống hiện Modal Loading (Processing...) ngầm và áp dụng hình nền thành công.

AC 3: Luồng Apply tại Screen 4 (Edit) — Phân nhánh Premium

Scenario A: Phôi Free + chỉ dùng công cụ Free.

Given: Người dùng độ hình từ phôi Free và KHÔNG dùng phụ tùng/công cụ Premium nào.

When: Người dùng nhấn "Apply" trên Nav bar Screen 4.

Then: Hệ thống bỏ qua Video Ads, mở thẳng Modal Set Wallpaper.

Scenario B: Phôi Premium HOẶC có dùng phụ tùng/công cụ Premium.

Given: Phôi gốc là Premium, hoặc người dùng đã dùng ít nhất một item Premium (sticker khóa / Remove BG).

When: Người dùng nhấn "Apply".

Then: Hệ thống kích hoạt Modal Xem Video Quảng Cáo.
- Nếu bấm "Không xem": tắt modal, giữ nguyên trạng thái, ở lại Screen 4.
- Nếu bấm "Đồng ý xem": phát Reward Ads. Xem hết 100% → tự động gọi Modal Set Wallpaper.

Scenario C (Điều hướng sau khi set thành công - Viral Loop):

Given: Người dùng vừa set wallpaper thành công từ Screen 4.

When: Modal Loading "System Applying..." kết thúc.

Then: Phát Haptic + đẩy người dùng sang Màn hình Chia sẻ (kèm chính phôi vừa tạo). (Lưu ý: KHÔNG còn ở lại Screen 4 như spec cũ.)

AC 3B: Mở khóa phụ tùng Premium 1 lần (Screen 4)

Scenario: Dùng item Premium bị khóa.

Given: Người dùng bấm vào sticker/công cụ gắn Icon Vương miện Premium.

When: Chọn dùng item đó.

Then: Hệ thống bật Modal Xem Video Quảng Cáo (text ngữ cảnh "mở khóa"). Xem xong → áp dụng item + đánh dấu bản độ đã chứa Premium + hiện Toast "Item Unlocked!" (viền chớp sáng).

AC 4: Kiểm soát trạng thái chặn tương tác của Modal Loading (Dùng chung)

Scenario: Đảm bảo độ ổn định hệ thống khi xử lý tác vụ nặng (Xóa nền AI, Xóa hàng loạt, Đổi hình nền).

Given: Hệ thống đang hiển thị Modal Loading / Processing (Spinner xoay tròn).

When: Người dùng cố tình nhấn ra vùng ngoài (Click-outside) hoặc bấm nút Back vật lý của thiết bị.

Then: Hệ thống phải chặn hoàn toàn các tương tác này. Màn hình chỉ được giải phóng khi tác vụ chạy ngầm trả về kết quả thành công hoặc thất bại.

AC 5: Yêu thích (Favorites) tại Screen 2/3

Given: Người dùng xem một Card Theme.
When: Bấm Icon Trái tim trên card.
Then: Đảo trạng thái yêu thích + hiện Toast "Added to Favorites" / "Removed from Favorites". Bộ lọc "Đã yêu thích" chỉ hiển thị các theme đã tim (không ảnh hưởng Draft).

AC 6: Hoàn tác / Làm lại (Undo / Redo) tại Screen 4

Given: Người dùng đã thêm ≥1 sticker/text vào canvas.
When: Bấm Undo → phần tử mới nhất bị gỡ và đẩy vào ngăn Redo. Bấm Redo → phần tử được khôi phục.
Then: Một hành động thêm mới sẽ xóa nhánh Redo. Khi ngăn rỗng, hiện Toast "Nothing to Undo/Redo".

AC 7: Modal Unsaved Changes khi Back từ Screen 4

Given: Người dùng đang ở Screen 4.
When: Bấm Back trên Nav bar.
Then: Hiện Modal với 3 lựa chọn: Save Draft (lưu vào Tab Draft → về Gallery), Hủy bỏ (về Gallery không lưu), Keep Edit (đóng modal, ở lại).

AC 8: Set Wallpaper — Options & Điều hướng phân nhánh

Given: Modal Set Wallpaper mở (từ S3 / S4 / Thư viện).
When: Chọn HOME_SCREEN / LOCK_SCREEN / BOTH.
Then: Đóng modal → Modal Loading "System Applying..." → thành công + Haptic + Toast "Wallpaper Applied". Điều hướng: từ S4 → Màn Share; từ S3 → về Gallery; từ Thư viện → về Library.

AC 9: Thư viện — Bulk Delete & Lưu ảnh

Given: Người dùng ở Tab Wallpaper/Draft.
When: Bấm "Select" → chọn nhiều item → "Delete".
Then: Modal Loading giải phóng ổ đĩa → cập nhật danh sách + Toast "Items Deleted Successfully".
And: Tại màn chi tiết Wallpaper, bấm Lưu ảnh → Modal Loading export → Toast "Image Saved to Device Gallery".

AC 10: Apply lại từ Thư viện — miễn phí Ads

Given: Theme đã set thành công nằm ở Tab Wallpaper.
When: Mở chi tiết và bấm "Apply Matrix".
Then: Mở thẳng Modal Set Wallpaper, KHÔNG hiển thị Video Ads (đã mở khóa vĩnh viễn).

AC 11: Modal Rate App (5 sao)

Given: Người dùng ở Settings.
When: Bấm "Rate App".
Then: Hiện Modal 5 sao chưa active. Phải chọn ≥1 sao mới cho xác nhận (nếu 0 sao → Toast nhắc). Xác nhận → đóng modal + direct sang CH Play/App Store.

AC 12: Chia sẻ & Copy link (Màn Share)

Given: Người dùng ở Màn hình Chia sẻ.
When: Bấm icon mạng xã hội (FB/IG/TikTok) → Kiểm tra mạng → Modal Loading đóng gói → direct app thứ ba. Bấm "Copy Link".
Then: Sao chép link + Toast "Link Copied to Clipboard". Nút Back về đúng context (Setting hoặc Screen 4 tùy luồng).

AC 13: Modal Lỗi mạng — Retry tác vụ bị gián đoạn

Given: Mất mạng khi thực hiện tác vụ cần Internet (loading, swipe feed, mở tab Wallpaper).
When: Modal No-Internet hiện ra, người dùng bật lại mạng và bấm "Thử lại".
Then: Hệ thống chạy lại đúng tác vụ vừa bị gián đoạn. Không cho tắt modal bằng click-outside.

PHẦN 2: ACTION PLAN (KẾ HOẠCH HÀNH ĐỘNG BIẾN PRD THÀNH SẢN PHẨM)

Kế hoạch phân rã công việc chi tiết cho các phòng ban để chuẩn bị cho giai đoạn Sprint:

Lộ trình triển khai cụ thể:

Giai đoạn 1: UI/UX & Wireframing (Thời gian dự kiến: 1 - 2 tuần) - Giai đoạn hiện tại của bạn

[ ] Design: Vẽ Wireframe (Low-fidelity) cho các màn hình chính và hệ thống 7 Modal dùng chung (Reward Ads, Set Wallpaper, Unsaved Changes, Loading, No-Internet, Rate App, Share App) + hệ thống Toast dựa trên tài liệu đặc tả.

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