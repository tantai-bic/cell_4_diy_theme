abstract final class AppConfig {
  // Truyền qua: flutter run --dart-define=REWARDED_AD_UNIT_ID=ca-app-pub-xxx/yyy
  static const String rewardedAdUnitId = String.fromEnvironment(
    'REWARDED_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917', // Google test fallback
  );
  static const String nativeAdUnitId = String.fromEnvironment(
    'NATIVE_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/2247696110',
  );
  static const String bannerAdUnitId = String.fromEnvironment(
    'BANNER_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  // AppLovin: flutter run --dart-define=APPLOVIN_SDK_KEY=<key>
  static const String appLovinSdkKey = String.fromEnvironment('APPLOVIN_SDK_KEY');

  // Test device IDs (comma-separated) — dùng để xem ads thật mà không count impressions/clicks.
  // flutter run --dart-define=TEST_DEVICE_IDS=AABBCCDD,11223344
  // Để trống (mặc định) → không đăng ký test device, dùng Google test ad placeholders.
  static const String _testDeviceIdsRaw = String.fromEnvironment('TEST_DEVICE_IDS');
  static List<String> get testDeviceIds =>
      _testDeviceIdsRaw.isEmpty ? [] : _testDeviceIdsRaw.split(',');
}
