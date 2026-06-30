import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/app_config.dart';
import 'core/l10n/locale_provider.dart';
import 'core/models/theme_item.dart';
import 'core/services/ad_service.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  // Preserve native splash cho đến khi LoadingScreen gọi remove()
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  final previousOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return previousOnError?.call(error, stack) ?? true;
  };

  // Full screen / immersive
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(LibraryWallpaperAdapter());
  Hive.registerAdapter(LibraryDraftAdapter());

  // Load ads on/off flag trước khi khởi tạo SDK
  await adService.loadAdsEnabledFlag();

  await adService.initialize(AppConfig.appLovinSdkKey);

  final testDeviceIds = AppConfig.testDeviceIds;
  if (testDeviceIds.isNotEmpty) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: testDeviceIds),
    );
  }

  runApp(const ProviderScope(child: DiyWallpaperApp()));
}

class DiyWallpaperApp extends ConsumerWidget {
  const DiyWallpaperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'DIY Themes',
      theme: AppTheme.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
