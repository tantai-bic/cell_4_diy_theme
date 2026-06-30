import 'app_strings.dart';

class ViStrings extends AppStrings {
  const ViStrings();

  @override String get cancel => 'HỦY';
  @override String get settings => 'SETTINGS';
  @override String get retry => 'THỬ LẠI';
  @override String get loading => 'ĐANG TẢI...';
  @override String get saving => 'ĐANG LƯU...';
  @override String get deleting => 'ĐANG XÓA...';
  @override String get sharing => 'ĐANG CHIA SẺ...';
  @override String get systemApplying => 'ĐANG ÁP DỤNG...';

  @override String get favorites => '❤ YÊU THÍCH';
  @override String get noFavorites => 'CHƯA CÓ YÊU THÍCH';
  @override String get noResults => 'KHÔNG TÌM THẤY';
  @override String get addedToFavorites => 'ĐÃ THÊM VÀO YÊU THÍCH';
  @override String get removedFromFavorites => 'ĐÃ XÓA KHỎI YÊU THÍCH';

  @override String get enterGarage => 'VÀO CHỈNH SỬA';
  @override String get applyLabel => 'ÁP DỤNG';
  @override String get lockedGarage => '🔒 CHỈNH SỬA';
  @override String get lockedApply => '🔒 ÁP DỤNG';

  @override String get applyButton => 'APPLY';
  @override String get saveDraft => 'LƯU NHÁP';
  @override String get discardChanges => 'HỦY THAY ĐỔI';
  @override String get continueEditing => 'TIẾP TỤC CHỈNH SỬA';
  @override String get unsavedChanges => 'CHƯA LƯU THAY ĐỔI';
  @override String get nothingToUndo => 'KHÔNG CÓ GÌ ĐỂ HOÀN TÁC';
  @override String get nothingToRedo => 'KHÔNG CÓ GÌ ĐỂ LÀM LẠI';
  @override String get stickerUnlocked => 'ĐÃ MỞ KHÓA STICKER!';
  @override String get wallpaperSet => 'ĐÃ ĐẶT WALLPAPER!';
  @override String get wallpaperSetFailed => 'THẤT BẠI. THỬ LẠI.';

  @override String get setWallpaperTitle => 'ĐẶT WALLPAPER';
  @override String get homeScreen => 'MÀN HÌNH CHÍNH';
  @override String get lockScreen => 'MÀN HÌNH KHÓA';
  @override String get both => 'CẢ HAI';

  @override String get unlockThemeTitle => 'MỞ KHÓA THEME';
  @override String get applyThemeTitle => 'ÁP DỤNG THEME';
  @override String get unlockStickerTitle => 'MỞ KHÓA STICKER';
  @override String get unlockThemeBody => 'Xem 1 video quảng cáo để mở khóa theme này vĩnh viễn.';
  @override String get applyThemeBody => 'Xem 1 video quảng cáo để áp dụng thiết kế của bạn.';
  @override String get unlockStickerBody => 'Xem 1 video quảng cáo để mở khóa sticker này vĩnh viễn.';
  @override String get watchVideo => 'XEM VIDEO';
  @override String get noThanks => 'KHÔNG XEM';
  @override String get loadingAds => 'ĐANG TẢI QUẢNG CÁO...';
  @override String adsUnavailable(String reason) => 'Ads không khả dụng: $reason';

  @override String get premiumTitle => '✦ PREMIUM ✦';
  @override String get premiumProSubtitle => 'DIY WALLPAPER PRO';
  @override String get premiumBenefit1 => 'Không quảng cáo vĩnh viễn';
  @override String get premiumBenefit2 => 'Mở khóa tất cả theme';
  @override String get premiumBenefit3 => 'Mở khóa tất cả sticker';
  @override String get premiumBenefit4 => 'Hỗ trợ Studio phát triển';
  @override String get premiumLifetimePrice => '29.000 ₫ / trọn đời';
  @override String get buyNow => 'MUA NGAY';
  @override String get restorePurchase => 'ĐÃ MUA? KHÔI PHỤC';
  @override String get premiumAlreadyActive => 'PREMIUM ĐANG HOẠT ĐỘNG';
  @override String get premiumActivated => 'PREMIUM ĐÃ KÍCH HOẠT!';
  @override String purchaseFailed(String reason) => 'MUA THẤT BẠI: $reason';
  @override String get storeUnavailable => 'STORE KHÔNG KHẢ DỤNG';
  @override String get cannotOpenStore => 'KHÔNG THỂ MỞ STORE';
  @override String get noPurchaseFound => 'KHÔNG TÌM THẤY PURCHASE';

  @override String get settingsTitle => 'CÀI ĐẶT';
  @override String get buyPremiumLabel => 'MUA PREMIUM';
  @override String get premiumActiveLabel => 'PREMIUM ĐANG BẬT';
  @override String get premiumBannerActiveSub => 'Tất cả đã mở khóa · Không quảng cáo';
  @override String get premiumBannerBuySub => 'Mở khóa tất cả theme & sticker · 29K';
  @override String get premiumToggleLabel => 'PREMIUM';
  @override String get premiumOn => 'Đang kích hoạt';
  @override String get premiumOff => 'Chưa kích hoạt';
  @override String get feedbackLabel => 'PHẢN HỒI';
  @override String get feedbackSub => 'Gửi phản hồi cho Studio';
  @override String get shareAppLabel => 'CHIA SẺ APP';
  @override String get shareAppSub => 'Chia sẻ app với bạn bè';
  @override String get rateAppLabel => 'ĐÁNH GIÁ APP';
  @override String get rateAppSub => '5 sao để ủng hộ Studio';
  @override String get privacyPolicyLabel => 'CHÍNH SÁCH RIÊNG TƯ';
  @override String get privacyPolicySub => 'Chính sách quyền riêng tư & dữ liệu';
  @override String get languageLabel => 'NGÔN NGỮ';
  @override String get languageSub => 'Tiếng Việt / English';
  @override String get rateConfirm => 'XÁC NHẬN';
  @override String get versionLabel => 'DIY WALLPAPER';
  @override String versionSub(String code) => 'Phiên bản 1.0.0 · ${code.toUpperCase()}';

  @override String get shareTitle => 'CHIA SẺ';
  @override String get copyLink => 'SAO CHÉP LIÊN KẾT';
  @override String get linkCopied => 'ĐÃ SAO CHÉP!';

  @override String get miuiGuideTitle => 'TỐI ƯU CHO MIUI';
  @override String get miuiGuideSubtitle => 'Cấp "kim bài miễn tử" để MIUI không bao giờ tắt app khi đang đặt wallpaper.';
  @override String get miuiGuideStep1Title => 'BƯỚC 1 — TỰ KHỞI CHẠY';
  @override String get miuiGuideStep1Body => 'Bật Tự khởi chạy (Autostart) cho DIY Wallpaper để hệ thống giữ app luôn hoạt động.';
  @override String get miuiGuideStep2Title => 'BƯỚC 2 — PIN';
  @override String get miuiGuideStep2Body => 'Tắt giới hạn pin (No restrictions) để MIUI không ép tắt app.';
  @override String get miuiGuideOpenAutostart => 'MỞ CÀI ĐẶT TỰ KHỞI CHẠY';
  @override String get miuiGuideOpenBattery => 'MỞ CÀI ĐẶT PIN';
  @override String get miuiGuideDone => 'ĐÃ HIỂU';

  @override String get splashSubtitle => 'WALLPAPER STUDIO';
  @override String get splashInitializing => 'ĐANG KHỞI ĐỘNG...';

  @override String get libraryTitle => 'THƯ VIỆN';
  @override String get wallpaperTab => 'WALLPAPER';
  @override String get draftTab => 'NHÁP';
  @override String get deleted => 'ĐÃ XÓA';
  @override String get savedToGallery => 'ĐÃ LƯU VÀO THƯ VIỆN';
  @override String get saveFailed => 'LƯU THẤT BẠI';
  @override String get galleryPermissionDenied => 'CHƯA CÓ QUYỀN TRUY CẬP THƯ VIỆN. MỞ CÀI ĐẶT ĐỂ CẤP PHÉP.';
  @override String get continueMod => 'TIẾP TỤC CHỈNH SỬA';
  @override String get applyFree => 'ÁP DỤNG';
  @override String get editInGarage => 'CHỈNH SỬA';
  @override String get saveToDevice => 'LƯU VÀO THIẾT BỊ';
}
