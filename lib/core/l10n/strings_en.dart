import 'app_strings.dart';

class EnStrings extends AppStrings {
  const EnStrings();

  @override String get cancel => 'CANCEL';
  @override String get settings => 'SETTINGS';
  @override String get retry => 'RETRY';
  @override String get loading => 'LOADING...';
  @override String get saving => 'SAVING...';
  @override String get deleting => 'DELETING...';
  @override String get sharing => 'SHARING...';
  @override String get systemApplying => 'SYSTEM APPLYING...';

  @override String get favorites => '❤ FAVORITES';
  @override String get noFavorites => 'NO FAVORITES YET';
  @override String get noResults => 'NOT FOUND';
  @override String get addedToFavorites => 'ADDED TO FAVORITES';
  @override String get removedFromFavorites => 'REMOVED FROM FAVORITES';

  @override String get enterGarage => 'ENTER GARAGE';
  @override String get applyLabel => 'APPLY';
  @override String get lockedGarage => '🔒 GARAGE';
  @override String get lockedApply => '🔒 APPLY';

  @override String get applyButton => 'APPLY';
  @override String get saveDraft => 'SAVE DRAFT';
  @override String get discardChanges => 'DISCARD CHANGES';
  @override String get continueEditing => 'CONTINUE EDITING';
  @override String get unsavedChanges => 'UNSAVED CHANGES';
  @override String get nothingToUndo => 'NOTHING TO UNDO';
  @override String get nothingToRedo => 'NOTHING TO REDO';
  @override String get stickerUnlocked => 'STICKER UNLOCKED!';
  @override String get wallpaperSet => 'WALLPAPER SET!';
  @override String get wallpaperSetFailed => 'SET FAILED. TRY AGAIN.';

  @override String get setWallpaperTitle => 'SET WALLPAPER';
  @override String get homeScreen => 'HOME SCREEN';
  @override String get lockScreen => 'LOCK SCREEN';
  @override String get both => 'BOTH';

  @override String get unlockThemeTitle => 'UNLOCK THEME';
  @override String get applyThemeTitle => 'APPLY THEME';
  @override String get unlockStickerTitle => 'UNLOCK STICKER';
  @override String get unlockThemeBody => 'Watch 1 ad to unlock this theme forever.';
  @override String get applyThemeBody => 'Watch 1 ad to apply your design.';
  @override String get unlockStickerBody => 'Watch 1 ad to unlock this sticker forever.';
  @override String get watchVideo => 'WATCH VIDEO';
  @override String get noThanks => 'NO THANKS';
  @override String get loadingAds => 'LOADING ADS...';
  @override String adsUnavailable(String reason) => 'Ads unavailable: $reason';

  @override String get premiumTitle => '✦ PREMIUM ✦';
  @override String get premiumProSubtitle => 'DIY WALLPAPER PRO';
  @override String get premiumBenefit1 => 'No ads forever';
  @override String get premiumBenefit2 => 'Unlock all themes';
  @override String get premiumBenefit3 => 'Unlock all stickers';
  @override String get premiumBenefit4 => 'Support Studio development';
  @override String get premiumLifetimePrice => '29.000 ₫ / lifetime';
  @override String get buyNow => 'BUY NOW';
  @override String get restorePurchase => 'ALREADY BOUGHT? RESTORE';
  @override String get premiumAlreadyActive => 'PREMIUM IS ACTIVE';
  @override String get premiumActivated => 'PREMIUM ACTIVATED!';
  @override String purchaseFailed(String reason) => 'PURCHASE FAILED: $reason';
  @override String get storeUnavailable => 'STORE UNAVAILABLE';
  @override String get cannotOpenStore => 'CANNOT OPEN STORE';
  @override String get noPurchaseFound => 'NO PREVIOUS PURCHASE FOUND';

  @override String get settingsTitle => 'SETTINGS';
  @override String get buyPremiumLabel => 'BUY PREMIUM';
  @override String get premiumActiveLabel => 'PREMIUM ACTIVE';
  @override String get premiumBannerActiveSub => 'All unlocked · No ads';
  @override String get premiumBannerBuySub => 'Unlock all themes & stickers · 29K';
  @override String get premiumToggleLabel => 'PREMIUM';
  @override String get premiumOn => 'Active';
  @override String get premiumOff => 'Not active';
  @override String get feedbackLabel => 'FEEDBACK';
  @override String get feedbackSub => 'Send feedback to Studio';
  @override String get shareAppLabel => 'SHARE APP';
  @override String get shareAppSub => 'Share with your friends';
  @override String get rateAppLabel => 'RATE APP';
  @override String get rateAppSub => '5 stars to support Studio';
  @override String get privacyPolicyLabel => 'PRIVACY POLICY';
  @override String get privacyPolicySub => 'Privacy & data policy';
  @override String get languageLabel => 'LANGUAGE';
  @override String get languageSub => 'English / Tiếng Việt';
  @override String get rateConfirm => 'CONFIRM';
  @override String get versionLabel => 'DIY WALLPAPER';
  @override String versionSub(String code) => 'Version 1.0.0 · ${code.toUpperCase()}';

  @override String get shareTitle => 'SHARE';
  @override String get copyLink => 'COPY LINK';
  @override String get linkCopied => 'LINK COPIED!';

  @override String get libraryTitle => 'LIBRARY';
  @override String get wallpaperTab => 'WALLPAPER';
  @override String get draftTab => 'DRAFT';
  @override String get deleted => 'DELETED';
  @override String get savedToGallery => 'SAVED TO GALLERY';
  @override String get saveFailed => 'SAVE FAILED';
  @override String get continueMod => 'CONTINUE MODDING';
  @override String get applyFree => 'APPLY';
  @override String get editInGarage => 'EDIT IN GARAGE';
  @override String get saveToDevice => 'SAVE TO DEVICE';
}
