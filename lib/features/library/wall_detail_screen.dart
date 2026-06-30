import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
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
    final library = ref.watch(libraryProvider).valueOrNull;
    if (library == null) return const SizedBox.shrink();

    final wall = library.wallpapers.firstWhere(
      (w) => (w.key as int?) == wallKey,
      orElse: () => library.wallpapers.first,
    );

    // Tìm theme từ themeId đã lưu, fallback tìm theo title
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
      ),
      body: Column(
        children: [
          Expanded(
            child: wall.imagePath.startsWith('/')
                ? Image.file(File(wall.imagePath),
                    fit: BoxFit.cover, width: double.infinity)
                : Image.asset(wall.imagePath,
                    fit: BoxFit.cover, width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CyberButton(
                  label: 'APPLY (FREE)',
                  fullWidth: true,
                  onTap: () => SetWallpaperModal.show(context,
                      imagePath: wall.imagePath,
                      onSuccess: () => context.pop()),
                ),
                const SizedBox(height: 10),
                CyberButton(
                  label: 'EDIT IN GARAGE',
                  variant: CyberButtonVariant.secondary,
                  fullWidth: true,
                  onTap: () => context.pushNamed(
                    'garage',
                    pathParameters: {'themeId': theme.id.toString()},
                    extra: GarageArgs(
                      fromLibrary: true,
                      initialStickers: stickerLayers,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CyberButton(
                  label: 'SAVE TO DEVICE',
                  variant: CyberButtonVariant.ghost,
                  fullWidth: true,
                  onTap: () => _saveToDevice(context, wall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToDevice(BuildContext context, LibraryWallpaper wall) async {
    LoadingModal.show(context, message: 'SAVING...');
    try {
      if (wall.imagePath.startsWith('/')) {
        // File path → lưu thẳng vào gallery
        await Gal.putImage(wall.imagePath, album: 'DIY Wallpaper');
      } else {
        // Asset path → đọc bytes rồi lưu
        final bytes = await DefaultAssetBundle.of(context).load(wall.imagePath);
        await Gal.putImageBytes(bytes.buffer.asUint8List(),
            name: 'diy_wallpaper_${DateTime.now().millisecondsSinceEpoch}.png',
            album: 'DIY Wallpaper');
      }
      LoadingModal.hide();
      if (context.mounted) CyberToast.show(context, 'SAVED TO GALLERY');
    } catch (e) {
      LoadingModal.hide();
      if (context.mounted) CyberToast.show(context, 'SAVE FAILED');
    }
  }
}
