import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DEV: Google test IDs — swap to real AppLovin IDs when shipping
const String _kRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

const String _kAdsEnabledKey = 'ads_enabled';

enum RewardPurpose { apply, unlock }

typedef RewardCallback = void Function(RewardPurpose purpose);
typedef FailCallback = void Function(String reason);

class AdService {
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  bool _loading = false;

  // Cờ toàn cục bật/tắt ads — persist qua SharedPreferences
  bool _adsEnabled = true;
  bool get adsEnabled => _adsEnabled;

  /// Gọi một lần khi app khởi động để load giá trị đã lưu.
  Future<void> loadAdsEnabledFlag() async {
    final prefs = await SharedPreferences.getInstance();
    _adsEnabled = prefs.getBool(_kAdsEnabledKey) ?? true;
    debugPrint('[AdService] adsEnabled=$_adsEnabled');
  }

  /// Toggle và lưu xuống disk ngay lập tức.
  Future<void> setAdsEnabled(bool value) async {
    _adsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAdsEnabledKey, value);
    debugPrint('[AdService] adsEnabled set to $value');
    if (!value) {
      // Hủy ad đang giữ để giải phóng bộ nhớ
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _loading = false;
    } else if (_initialized) {
      preloadRewarded();
    }
  }

  Future<void> initialize(String sdkKey) async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    debugPrint('[AdService] Google Mobile Ads initialized');
    if (_adsEnabled) preloadRewarded();
  }

  void preloadRewarded() {
    if (!_initialized || !_adsEnabled || _rewardedAd != null || _loading) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: _kRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loading = false;
          debugPrint('[AdService] Rewarded loaded');
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          debugPrint('[AdService] Rewarded load failed: ${error.message}');
          Future.delayed(const Duration(seconds: 5), preloadRewarded);
        },
      ),
    );
  }

  bool get isRewardedReady => _adsEnabled && _rewardedAd != null;

  Future<void> showRewarded({
    required RewardPurpose purpose,
    required RewardCallback onRewarded,
    required FailCallback onFail,
    Duration waitTimeout = const Duration(seconds: 10),
  }) async {
    // Ads tắt → grant reward ngay không cần xem quảng cáo
    if (!_adsEnabled) {
      onRewarded(purpose);
      return;
    }

    if (!_initialized) {
      onFail('sdk_not_initialized');
      return;
    }

    // Nếu ad chưa sẵn sàng, đảm bảo đang load và đợi tối đa [waitTimeout]
    if (_rewardedAd == null) {
      preloadRewarded();
      final deadline = DateTime.now().add(waitTimeout);
      while (_rewardedAd == null && DateTime.now().isBefore(deadline)) {
        await Future.delayed(const Duration(milliseconds: 250));
      }
      if (_rewardedAd == null) {
        onFail('not_loaded');
        return;
      }
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        preloadRewarded();
        onFail('user_closed');
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        a.dispose();
        preloadRewarded();
        onFail('display_failed: ${error.message}');
      },
    );
    ad.show(onUserEarnedReward: (_, reward) {
      debugPrint('[AdService] Reward earned: ${reward.amount} ${reward.type}');
      onRewarded(purpose);
    });
  }

  static const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
}

final adService = AdService();
