import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/theme_item.dart';
import 'core/services/ad_service.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // DEV: Google Mobile Ads (key unused) — swap to AppLovin when shipping
  await adService.initialize('');

  runApp(const ProviderScope(child: DiyWallpaperApp()));
}

class DiyWallpaperApp extends StatelessWidget {
  const DiyWallpaperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DIY Wallpaper',
      theme: AppTheme.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
