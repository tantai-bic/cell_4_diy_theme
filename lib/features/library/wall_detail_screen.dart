import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/models/app_data.dart';
import '../../core/models/theme_item.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../core/theme/widgets/loading_modal.dart';
import '../../providers/library_provider.dart';
import '../../router/app_router.dart';
import '../garage/set_wallpaper_modal.dart';

class WallDetailScreen extends ConsumerWidget {
  final int wallKey;
  const WallDetailScreen({super.key, required this.wallKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final library = ref.watch(libraryProvider).valueOrNull;
    if (library == null) return const SizedBox.shrink();

    final wall = library.wallpapers.firstWhere(
      (w) => (w.key as int?) == wallKey,
      orElse: () => library.wallpapers.first,
    );

    final theme = wall.themeId != null
        ? kThemes.firstWhere((t) => t.id == wall.themeId,
            orElse: () => kThemes.firstWhere(
                (t) => t.title == wall.title,
                orElse: () => kThemes.first))
        : kThemes.firstWhere(
            (t) => t.title == wall.title,
            orElse: () => kThemes.first);

    final stickerLayers = wall.stickerLayers;

    return Scaffold(
      backgroundColor: AppColors.bgAmoled,
      appBar: AppBar(
        backgroundColor: AppColors.bgCyber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan),
          onPressed: () => context.pop(),
        ),
        title: Text(wall.title,
            style: const TextStyle(
                color: AppColors.neonCyan,
                fontFamily: 'Orbitron',
                fontSize: 13)),
        // Save to device moved here as icon action
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined, color: AppColors.neonCyan),
            tooltip: s.saveToDevice,
            onPressed: () => _saveToDevice(context, wall, s),
          ),
        ],
      ),
      // 2 buttons căn giữa bottom bar
      bottomNavigationBar: SafeArea(
        child: Container(
          color: AppColors.bgCyber,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: CyberButton(
                  label: s.applyFree,
                  onTap: () => SetWallpaperModal.showLocalized(context, s,
                      imagePath: wall.imagePath,
                      onSuccess: () => context.pop()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CyberButton(
                  label: s.editInGarage,
                  variant: CyberButtonVariant.secondary,
                  onTap: () => context.pushNamed(
                    'garage',
                    pathParameters: {'themeId': theme.id.toString()},
                    extra: GarageArgs(
                      fromLibrary: true,
                      initialStickers: stickerLayers,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: wall.imagePath.startsWith('/')
          ? Image.file(File(wall.imagePath),
              fit: BoxFit.cover, width: double.infinity, height: double.infinity)
          : Image.asset(wall.imagePath,
              fit: BoxFit.cover, width: double.infinity, height: double.infinity),
    );
  }

  Future<void> _saveToDevice(BuildContext context, LibraryWallpaper wall, s) async {
    LoadingModal.show(context, messageBuilder: (s) => s.saving);
    try {
      if (wall.imagePath.startsWith('/')) {
        await Gal.putImage(wall.imagePath, album: 'DIY Wallpaper');
      } else {
        final bytes = await DefaultAssetBundle.of(context).load(wall.imagePath);
        await Gal.putImageBytes(bytes.buffer.asUint8List(),
            name: 'diy_wallpaper_${DateTime.now().millisecondsSinceEpoch}.png',
            album: 'DIY Wallpaper');
      }
      LoadingModal.hide();
      if (context.mounted) CyberToast.show(context, s.savedToGallery);
    } catch (e) {
      LoadingModal.hide();
      if (context.mounted) CyberToast.show(context, s.saveFailed);
    }
  }
}
