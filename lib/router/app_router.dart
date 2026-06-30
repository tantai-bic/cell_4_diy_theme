import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/loading/loading_screen.dart';
import '../features/home/home_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/garage/garage_screen.dart';
import '../features/garage/sticker_layer.dart';
import '../features/preview/preview_screen.dart';
import '../features/library/library_screen.dart';
import '../features/library/wall_detail_screen.dart';
import '../features/library/draft_detail_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/share/share_screen.dart';
import '../core/models/theme_item.dart';

enum WallpaperSetContext { garage, gallery, library }

class GarageArgs {
  final bool fromLibrary;
  final List<StickerLayer> initialStickers;

  const GarageArgs({
    this.fromLibrary = false,
    this.initialStickers = const [],
  });
}

final appRouter = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      name: 'loading',
      builder: (_, __) => const LoadingScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/gallery/:themeId',
      name: 'gallery',
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['themeId'] ?? '1') ?? 1;
        return GalleryScreen(initialThemeId: id);
      },
    ),
    GoRoute(
      path: '/garage/:themeId',
      name: 'garage',
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['themeId'] ?? '1') ?? 1;
        final args = state.extra as GarageArgs? ?? const GarageArgs();
        return GarageScreen(themeId: id, args: args);
      },
    ),
    GoRoute(
      path: '/preview',
      name: 'preview',
      builder: (_, state) {
        final extra = state.extra as PreviewArgs?;
        return PreviewScreen(args: extra ?? const PreviewArgs());
      },
    ),
    GoRoute(
      path: '/library',
      name: 'library',
      builder: (_, __) => const LibraryScreen(),
    ),
    GoRoute(
      path: '/library/wall/:key',
      name: 'wall-detail',
      builder: (_, state) {
        final key = int.tryParse(state.pathParameters['key'] ?? '0') ?? 0;
        return WallDetailScreen(wallKey: key);
      },
    ),
    GoRoute(
      path: '/library/draft/:key',
      name: 'draft-detail',
      builder: (_, state) {
        final key = int.tryParse(state.pathParameters['key'] ?? '0') ?? 0;
        return DraftDetailScreen(draftKey: key);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/share',
      name: 'share',
      builder: (_, state) {
        final args = state.extra as ShareArgs?;
        return ShareScreen(args: args ?? const ShareArgs());
      },
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    backgroundColor: const Color(0xFF050508),
    body: Center(
      child: Text('Route not found: ${state.error}',
          style: const TextStyle(color: Colors.white)),
    ),
  ),
);

class PreviewArgs {
  final String backgroundImg;
  final List<StickerLayer> stickerLayers;

  const PreviewArgs({this.backgroundImg = '', this.stickerLayers = const []});
}

class ShareArgs {
  final String imagePath;
  final WallpaperSetContext backContext;
  final String themeTitle;
  final List<String> stickerLayersJson;
  final int themeId;

  const ShareArgs({
    this.imagePath = '',
    this.backContext = WallpaperSetContext.garage,
    this.themeTitle = '',
    this.stickerLayersJson = const [],
    this.themeId = 1,
  });
}
