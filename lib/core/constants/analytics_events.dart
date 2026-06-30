abstract final class AnalyticsEvent {
  // ── App Lifecycle ──────────────────────────────────────────────────────────
  // first_open, session_start → auto-tracked by Firebase, không cần log thêm
  static const String appSessionEnd = 'app_session_end';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingStepCompleted = 'onboarding_step_completed';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingSkipped = 'onboarding_skipped';

  // ── Browsing ────────────────────────────────────────────────────────────────
  static const String themeListViewed = 'theme_list_viewed';
  static const String themeCardClicked = 'theme_card_clicked';
  static const String themePreviewOpened = 'theme_preview_opened';
  static const String themePreviewClosed = 'theme_preview_closed';
  static const String stickerListViewed = 'sticker_list_viewed';
  static const String stickerCardClicked = 'sticker_card_clicked';

  // ── Ads ─────────────────────────────────────────────────────────────────────
  static const String adRequested = 'ad_requested';
  static const String adImpression = 'ad_impression';
  static const String adWatchStarted = 'ad_watch_started';
  static const String adWatchCompleted = 'ad_watch_completed';
  static const String adSkipped = 'ad_skipped';
  static const String adClicked = 'ad_clicked';
  static const String adFailed = 'ad_failed';

  // ── IAP ─────────────────────────────────────────────────────────────────────
  static const String iapPageViewed = 'iap_page_viewed';
  static const String iapProductSelected = 'iap_product_selected';
  static const String purchase = 'purchase'; // Firebase standard event
  static const String iapFailed = 'iap_failed';
  static const String iapRestored = 'iap_restored';
  static const String iapCancelled = 'iap_cancelled';

  // ── Unlock Flow ──────────────────────────────────────────────────────────────
  static const String unlockPromptShown = 'unlock_prompt_shown';
  static const String unlockMethodSelected = 'unlock_method_selected';
  static const String itemUnlocked = 'item_unlocked';
  static const String unlockAbandoned = 'unlock_abandoned';

  // ── Editor & Export ──────────────────────────────────────────────────────────
  static const String editorOpened = 'editor_opened';
  static const String stickerAddedToCanvas = 'sticker_added_to_canvas';
  static const String stickerRemoved = 'sticker_removed';
  static const String wallpaperExported = 'wallpaper_exported';
  static const String wallpaperShared = 'wallpaper_shared';
  static const String wallpaperSetAs = 'wallpaper_set_as';
}

abstract final class AnalyticsParam {
  // Common
  static const String sessionId = 'session_id';
  static const String source = 'source';
  static const String platform = 'platform';
  static const String appVersion = 'app_version';

  // Session
  static const String sessionDurationSec = 'session_duration_sec';
  static const String screensVisited = 'screens_visited';

  // Onboarding
  static const String stepNumber = 'step_number';
  static const String stepName = 'step_name';
  static const String totalTimeSec = 'total_time_sec';

  // Theme / Sticker
  static const String themeId = 'theme_id';
  static const String themeName = 'theme_name';
  static const String stickerId = 'sticker_id';
  static const String stickerName = 'sticker_name';
  static const String isPremium = 'is_premium';
  static const String positionIndex = 'position_index';
  static const String category = 'category';
  static const String timeSpentSec = 'time_spent_sec';
  static const String action = 'action';

  // Ads
  static const String adType = 'ad_type';
  static const String placementId = 'placement_id';
  static const String network = 'network';
  static const String watchDurationSec = 'watch_duration_sec';
  static const String timeBeforeSkipSec = 'time_before_skip_sec';
  static const String errorCode = 'error_code';

  // IAP
  static const String productId = 'product_id';
  static const String price = 'price';
  static const String currency = 'currency';
  static const String transactionId = 'transaction_id';
  static const String productType = 'product_type';
  static const String errorMessage = 'error_message';

  // Unlock
  static const String itemType = 'item_type';
  static const String itemId = 'item_id';
  static const String itemName = 'item_name';
  static const String unlockOptions = 'unlock_options';
  static const String unlockMethod = 'unlock_method';
  static const String isFirstUnlock = 'is_first_unlock';
  static const String methodAttempted = 'method_attempted';
  static const String step = 'step';

  // Editor
  static const String editDurationSec = 'edit_duration_sec';
  static const String exportType = 'export_type';
  static const String sharePlatform = 'share_platform';
  static const String target = 'target';
  static const String canvasStickerCount = 'canvas_sticker_count';
  static const String stickerCount = 'sticker_count';
}

// Giá trị cố định — tránh hardcode string rải rác trong codebase
abstract final class AnalyticsValue {
  // item_type
  static const String theme = 'theme';
  static const String sticker = 'sticker';

  // ad_type
  static const String rewarded = 'rewarded';
  static const String interstitial = 'interstitial';
  static const String banner = 'banner';

  // unlock_method
  static const String watchAd = 'watch_ad';
  static const String buyPremium = 'buy_premium';

  // placement_id
  static const String unlockTheme = 'unlock_theme';
  static const String unlockSticker = 'unlock_sticker';
  static const String betweenScreens = 'between_screens';

  // export_type
  static const String save = 'save';
  static const String share = 'share';

  // wallpaper target
  static const String homeScreen = 'home';
  static const String lockScreen = 'lock';
  static const String both = 'both';
}
