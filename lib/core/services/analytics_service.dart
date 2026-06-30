import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../constants/analytics_events.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final _fa = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _fa);

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _fa.logEvent(name: name, parameters: params);
      debugPrint('[Analytics] $name ${params ?? ''}');
    } catch (e) {
      debugPrint('[Analytics] ERROR logging $name: $e');
    }
  }

  Future<void> setUserType(String type) =>
      _fa.setUserProperty(name: 'user_type', value: type);

  Future<void> setTotalUnlocks(int count) {
    final bucket = count == 0
        ? '0'
        : count <= 5
            ? '1-5'
            : '6+';
    return _fa.setUserProperty(name: 'total_unlocks', value: bucket);
  }

  // ── App Lifecycle ──────────────────────────────────────────────────────────

  Future<void> logSessionEnd({
    required int durationSec,
    required int screensVisited,
  }) =>
      _log(AnalyticsEvent.appSessionEnd, {
        AnalyticsParam.sessionDurationSec: durationSec,
        AnalyticsParam.screensVisited: screensVisited,
      });

  // ── Onboarding ─────────────────────────────────────────────────────────────

  Future<void> logOnboardingStarted({required String source}) =>
      _log(AnalyticsEvent.onboardingStarted, {AnalyticsParam.source: source});

  Future<void> logOnboardingStepCompleted({
    required int stepNumber,
    required String stepName,
  }) =>
      _log(AnalyticsEvent.onboardingStepCompleted, {
        AnalyticsParam.stepNumber: stepNumber,
        AnalyticsParam.stepName: stepName,
      });

  Future<void> logOnboardingCompleted({required int totalTimeSec}) =>
      _log(AnalyticsEvent.onboardingCompleted,
          {AnalyticsParam.totalTimeSec: totalTimeSec});

  Future<void> logOnboardingSkipped({required int stepNumber}) =>
      _log(AnalyticsEvent.onboardingSkipped,
          {AnalyticsParam.stepNumber: stepNumber});

  // ── Browsing ────────────────────────────────────────────────────────────────

  Future<void> logThemeListViewed({
    required String category,
    required String source,
  }) =>
      _log(AnalyticsEvent.themeListViewed, {
        AnalyticsParam.category: category,
        AnalyticsParam.source: source,
      });

  Future<void> logThemeCardClicked({
    required String themeId,
    required String themeName,
    required bool isPremium,
    required int positionIndex,
    required String category,
  }) =>
      _log(AnalyticsEvent.themeCardClicked, {
        AnalyticsParam.themeId: themeId,
        AnalyticsParam.themeName: themeName,
        AnalyticsParam.isPremium: isPremium,
        AnalyticsParam.positionIndex: positionIndex,
        AnalyticsParam.category: category,
      });

  Future<void> logThemePreviewOpened({
    required String themeId,
    required bool isPremium,
    required String source,
  }) =>
      _log(AnalyticsEvent.themePreviewOpened, {
        AnalyticsParam.themeId: themeId,
        AnalyticsParam.isPremium: isPremium,
        AnalyticsParam.source: source,
      });

  Future<void> logThemePreviewClosed({
    required String themeId,
    required int timeSpentSec,
    required String action,
  }) =>
      _log(AnalyticsEvent.themePreviewClosed, {
        AnalyticsParam.themeId: themeId,
        AnalyticsParam.timeSpentSec: timeSpentSec,
        AnalyticsParam.action: action,
      });

  Future<void> logStickerListViewed({required String category}) =>
      _log(AnalyticsEvent.stickerListViewed,
          {AnalyticsParam.category: category});

  Future<void> logStickerCardClicked({
    required String stickerId,
    required String stickerName,
    required bool isPremium,
    required int positionIndex,
  }) =>
      _log(AnalyticsEvent.stickerCardClicked, {
        AnalyticsParam.stickerId: stickerId,
        AnalyticsParam.stickerName: stickerName,
        AnalyticsParam.isPremium: isPremium,
        AnalyticsParam.positionIndex: positionIndex,
      });

  // ── Ads ─────────────────────────────────────────────────────────────────────

  Future<void> logAdRequested({
    required String adType,
    required String placementId,
    String? itemId,
    String? itemType,
  }) =>
      _log(AnalyticsEvent.adRequested, {
        AnalyticsParam.adType: adType,
        AnalyticsParam.placementId: placementId,
        if (itemId != null) AnalyticsParam.itemId: itemId,
        if (itemType != null) AnalyticsParam.itemType: itemType,
      });

  Future<void> logAdImpression({
    required String adType,
    required String placementId,
    String? itemId,
    String? network,
  }) =>
      _log(AnalyticsEvent.adImpression, {
        AnalyticsParam.adType: adType,
        AnalyticsParam.placementId: placementId,
        if (itemId != null) AnalyticsParam.itemId: itemId,
        if (network != null) AnalyticsParam.network: network,
      });

  Future<void> logAdWatchStarted({
    required String adType,
    required String placementId,
    String? itemId,
  }) =>
      _log(AnalyticsEvent.adWatchStarted, {
        AnalyticsParam.adType: adType,
        AnalyticsParam.placementId: placementId,
        if (itemId != null) AnalyticsParam.itemId: itemId,
      });

  Future<void> logAdWatchCompleted({
    required String adType,
    required String placementId,
    required int watchDurationSec,
    String? itemId,
  }) =>
      _log(AnalyticsEvent.adWatchCompleted, {
        AnalyticsParam.adType: adType,
        AnalyticsParam.placementId: placementId,
        AnalyticsParam.watchDurationSec: watchDurationSec,
        if (itemId != null) AnalyticsParam.itemId: itemId,
      });

  Future<void> logAdSkipped({
    required String adType,
    required String placementId,
    required int timeBeforeSkipSec,
  }) =>
      _log(AnalyticsEvent.adSkipped, {
        AnalyticsParam.adType: adType,
        AnalyticsParam.placementId: placementId,
        AnalyticsParam.timeBeforeSkipSec: timeBeforeSkipSec,
      });

  Future<void> logAdClicked({
    required String adType,
    required String placementId,
  }) =>
      _log(AnalyticsEvent.adClicked, {
        AnalyticsParam.adType: adType,
        AnalyticsParam.placementId: placementId,
      });

  Future<void> logAdFailed({
    required String adType,
    required String placementId,
    required String errorCode,
  }) =>
      _log(AnalyticsEvent.adFailed, {
        AnalyticsParam.adType: adType,
        AnalyticsParam.placementId: placementId,
        AnalyticsParam.errorCode: errorCode,
      });

  // ── IAP ─────────────────────────────────────────────────────────────────────

  Future<void> logIapPageViewed({required String source}) =>
      _log(AnalyticsEvent.iapPageViewed, {AnalyticsParam.source: source});

  Future<void> logIapProductSelected({
    required String productId,
    required double price,
    required String currency,
    required String productType,
  }) =>
      _log(AnalyticsEvent.iapProductSelected, {
        AnalyticsParam.productId: productId,
        AnalyticsParam.price: price,
        AnalyticsParam.currency: currency,
        AnalyticsParam.productType: productType,
      });

  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
    required String transactionId,
  }) =>
      _fa.logPurchase(
        currency: currency,
        value: price,
        transactionId: transactionId,
        items: [
          AnalyticsEventItem(itemId: productId, itemName: productId),
        ],
      );

  Future<void> logIapFailed({
    required String productId,
    required String errorCode,
    required String errorMessage,
  }) =>
      _log(AnalyticsEvent.iapFailed, {
        AnalyticsParam.productId: productId,
        AnalyticsParam.errorCode: errorCode,
        AnalyticsParam.errorMessage: errorMessage,
      });

  Future<void> logIapRestored({
    required String productId,
    required String transactionId,
  }) =>
      _log(AnalyticsEvent.iapRestored, {
        AnalyticsParam.productId: productId,
        AnalyticsParam.transactionId: transactionId,
      });

  Future<void> logIapCancelled({
    required String productId,
    required String step,
  }) =>
      _log(AnalyticsEvent.iapCancelled, {
        AnalyticsParam.productId: productId,
        AnalyticsParam.step: step,
      });

  // ── Unlock Flow ──────────────────────────────────────────────────────────────

  Future<void> logUnlockPromptShown({
    required String itemType,
    required String itemId,
    required String unlockOptions,
  }) =>
      _log(AnalyticsEvent.unlockPromptShown, {
        AnalyticsParam.itemType: itemType,
        AnalyticsParam.itemId: itemId,
        AnalyticsParam.unlockOptions: unlockOptions,
      });

  Future<void> logUnlockMethodSelected({
    required String itemType,
    required String itemId,
    required String method,
  }) =>
      _log(AnalyticsEvent.unlockMethodSelected, {
        AnalyticsParam.itemType: itemType,
        AnalyticsParam.itemId: itemId,
        AnalyticsParam.unlockMethod: method,
      });

  Future<void> logItemUnlocked({
    required String itemType,
    required String itemId,
    required String itemName,
    required String method,
    required bool isFirstUnlock,
  }) =>
      _log(AnalyticsEvent.itemUnlocked, {
        AnalyticsParam.itemType: itemType,
        AnalyticsParam.itemId: itemId,
        AnalyticsParam.itemName: itemName,
        AnalyticsParam.unlockMethod: method,
        AnalyticsParam.isFirstUnlock: isFirstUnlock,
      });

  Future<void> logUnlockAbandoned({
    required String itemType,
    required String itemId,
    required String methodAttempted,
    required String step,
  }) =>
      _log(AnalyticsEvent.unlockAbandoned, {
        AnalyticsParam.itemType: itemType,
        AnalyticsParam.itemId: itemId,
        AnalyticsParam.methodAttempted: methodAttempted,
        AnalyticsParam.step: step,
      });

  // ── Editor & Export ──────────────────────────────────────────────────────────

  Future<void> logEditorOpened({
    required String themeId,
    required String source,
  }) =>
      _log(AnalyticsEvent.editorOpened, {
        AnalyticsParam.themeId: themeId,
        AnalyticsParam.source: source,
      });

  Future<void> logStickerAddedToCanvas({
    required String stickerId,
    required String themeId,
    required int canvasStickerCount,
  }) =>
      _log(AnalyticsEvent.stickerAddedToCanvas, {
        AnalyticsParam.stickerId: stickerId,
        AnalyticsParam.themeId: themeId,
        AnalyticsParam.canvasStickerCount: canvasStickerCount,
      });

  Future<void> logStickerRemoved({
    required String stickerId,
    required String themeId,
  }) =>
      _log(AnalyticsEvent.stickerRemoved, {
        AnalyticsParam.stickerId: stickerId,
        AnalyticsParam.themeId: themeId,
      });

  Future<void> logWallpaperExported({
    required String themeId,
    required int stickerCount,
    required int editDurationSec,
    required String exportType,
  }) =>
      _log(AnalyticsEvent.wallpaperExported, {
        AnalyticsParam.themeId: themeId,
        AnalyticsParam.stickerCount: stickerCount,
        AnalyticsParam.editDurationSec: editDurationSec,
        AnalyticsParam.exportType: exportType,
      });

  Future<void> logWallpaperShared({
    required String themeId,
    required String sharePlatform,
  }) =>
      _log(AnalyticsEvent.wallpaperShared, {
        AnalyticsParam.themeId: themeId,
        AnalyticsParam.sharePlatform: sharePlatform,
      });

  Future<void> logWallpaperSetAs({
    required String themeId,
    required String target,
  }) =>
      _log(AnalyticsEvent.wallpaperSetAs, {
        AnalyticsParam.themeId: themeId,
        AnalyticsParam.target: target,
      });
}

final analyticsService = AnalyticsService();
