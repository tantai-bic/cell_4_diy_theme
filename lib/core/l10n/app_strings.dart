import 'strings_en.dart';
import 'strings_vi.dart';

abstract class AppStrings {
  const AppStrings();

  factory AppStrings.of(String langCode) =>
      langCode == 'vi' ? const ViStrings() : const EnStrings();

  // ── Common ───────────────────────────────────────────────────────────────
  String get cancel;
  String get settings;
  String get retry;
  String get loading;
  String get saving;
  String get deleting;
  String get sharing;
  String get systemApplying;

  // ── Home ─────────────────────────────────────────────────────────────────
  String get favorites;
  String get noFavorites;
  String get noResults;
  String get addedToFavorites;
  String get removedFromFavorites;

  // ── Gallery ───────────────────────────────────────────────────────────────
  String get enterGarage;
  String get applyLabel;
  String get lockedGarage;
  String get lockedApply;

  // ── Garage ────────────────────────────────────────────────────────────────
  String get applyButton;
  String get saveDraft;
  String get discardChanges;
  String get continueEditing;
  String get unsavedChanges;
  String get nothingToUndo;
  String get nothingToRedo;
  String get stickerUnlocked;
  String get wallpaperSet;
  String get wallpaperSetFailed;

  // ── Set Wallpaper Modal ───────────────────────────────────────────────────
  String get setWallpaperTitle;
  String get homeScreen;
  String get lockScreen;
  String get both;

  // ── Reward Modal ──────────────────────────────────────────────────────────
  String get unlockThemeTitle;
  String get applyThemeTitle;
  String get unlockStickerTitle;
  String get unlockThemeBody;
  String get applyThemeBody;
  String get unlockStickerBody;
  String get watchVideo;
  String get noThanks;
  String get loadingAds;
  String adsUnavailable(String reason);

  // ── Premium Modal ─────────────────────────────────────────────────────────
  String get premiumTitle;
  String get premiumProSubtitle;
  String get premiumBenefit1;
  String get premiumBenefit2;
  String get premiumBenefit3;
  String get premiumBenefit4;
  String get premiumLifetimePrice;
  String get buyNow;
  String get restorePurchase;
  String get premiumAlreadyActive;
  String get premiumActivated;
  String purchaseFailed(String reason);
  String get storeUnavailable;
  String get cannotOpenStore;
  String get noPurchaseFound;

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settingsTitle;
  String get buyPremiumLabel;
  String get premiumActiveLabel;
  String get premiumBannerActiveSub;
  String get premiumBannerBuySub;
  String get premiumToggleLabel;
  String get premiumOn;
  String get premiumOff;
  String get feedbackLabel;
  String get feedbackSub;
  String get shareAppLabel;
  String get shareAppSub;
  String get rateAppLabel;
  String get rateAppSub;
  String get privacyPolicyLabel;
  String get privacyPolicySub;
  String get languageLabel;
  String get languageSub;
  String get rateConfirm;
  String get versionLabel;
  String versionSub(String code);

  // ── Share ─────────────────────────────────────────────────────────────────
  String get shareTitle;
  String get copyLink;
  String get linkCopied;

  // ── MIUI Guide ────────────────────────────────────────────────────────────
  String get miuiGuideTitle;
  String get miuiGuideSubtitle;
  String get miuiGuideStep1Title;
  String get miuiGuideStep1Body;
  String get miuiGuideStep2Title;
  String get miuiGuideStep2Body;
  String get miuiGuideOpenAutostart;
  String get miuiGuideOpenBattery;
  String get miuiGuideDone;

  // ── Splash ────────────────────────────────────────────────────────────────
  String get splashSubtitle;
  String get splashInitializing;

  // ── Library ───────────────────────────────────────────────────────────────
  String get libraryTitle;
  String get wallpaperTab;
  String get draftTab;
  String get deleted;
  String get savedToGallery;
  String get saveFailed;
  String get galleryPermissionDenied;
  String get continueMod;
  String get applyFree;
  String get editInGarage;
  String get saveToDevice;
}
