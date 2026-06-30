import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/theme_item.dart' show LibraryWallpaper;
import '../../core/l10n/locale_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/network_guard.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../core/theme/widgets/loading_modal.dart';
import '../../providers/library_provider.dart';
import '../../providers/network_provider.dart';
import '../../router/app_router.dart';
import '../garage/sticker_layer.dart';

class ShareScreen extends ConsumerStatefulWidget {
  final ShareArgs args;
  const ShareScreen({super.key, required this.args});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  bool _saved = false;

  /// Thống nhất cả 2 flow (normal + MIUI restart):
  /// Luôn lấy sticker data từ ShareArgs (đã có sẵn cho cả 2 case)
  /// và navigate về Garage với đầy đủ thông tin.
  Future<void> _goBackToGarage(BuildContext ctx) async {
    await _saveWallpaper();
    if (!mounted) return;

    // Deserialize stickers từ ShareArgs — valid cho cả normal flow và MIUI flow
    final stickers = widget.args.stickerLayersJson
        .map((j) => StickerLayer.fromJson(jsonDecode(j) as Map<String, dynamic>))
        .toList();

    // MIUI flow: Share là route root → prefs chưa được dọn ở loading_screen
    if (!ctx.canPop()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_garage_theme_id');
      await prefs.remove('pending_garage_stickers');
    }

    if (!mounted) return;
    // Cả 2 flow dùng goNamed để Garage nhận GarageArgs với stickers đầy đủ
    ctx.goNamed(
      'garage',
      pathParameters: {'themeId': widget.args.themeId.toString()},
      extra: GarageArgs(initialStickers: stickers),
    );
  }

  Future<void> _saveWallpaper() async {
    if (_saved) return;
    if (widget.args.imagePath.isEmpty ||
        widget.args.backContext != WallpaperSetContext.garage) return;

    _saved = true;

    // Copy snapshot từ cache → documents dir để không bị OS dọn dẹp
    String persistedPath = widget.args.imagePath;
    if (widget.args.imagePath.startsWith('/')) {
      try {
        final src = File(widget.args.imagePath);
        if (src.existsSync()) {
          final docsDir = await getApplicationDocumentsDirectory();
          final dest = File(
              '${docsDir.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.png');
          await src.copy(dest.path);
          persistedPath = dest.path;
        }
      } catch (_) {}
    }

    // Đảm bảo Hive box đã mở (provider build() là async)
    await ref.read(libraryProvider.future);

    final now = DateTime.now();
    final wallpaper = LibraryWallpaper(
      id: now.millisecondsSinceEpoch,
      title: widget.args.themeTitle.isNotEmpty ? widget.args.themeTitle : 'WALLPAPER',
      imagePath: persistedPath,
      isUnlocked: true,
      savedAt: now,
      snapshotPath: persistedPath,
      stickerLayersJson: widget.args.stickerLayersJson,
      themeId: widget.args.themeId,
    );
    ref.read(libraryProvider.notifier).saveWallpaper(wallpaper);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _goBackToGarage(context); // hardware back → về Garage với stickers
      },
      child: Scaffold(
        backgroundColor: AppColors.bgAmoled,
        appBar: AppBar(
          backgroundColor: AppColors.bgCyber,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan),
            onPressed: () => _goBackToGarage(context),
          ),
          title: Text(ref.watch(stringsProvider).shareTitle,
              style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontFamily: 'Orbitron',
                  fontSize: 14)),
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined, color: AppColors.neonCyan),
              onPressed: () async {
                await _saveWallpaper(); // hoàn thành trước khi navigate
                if (mounted) context.goNamed('home');
              },
              tooltip: 'Home',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: widget.args.imagePath.isNotEmpty
                  ? widget.args.imagePath.startsWith('/')
                      ? Image.file(File(widget.args.imagePath),
                          fit: BoxFit.contain)
                      : Image.asset(widget.args.imagePath, fit: BoxFit.contain)
                  : Container(color: AppColors.bgCyber),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _SocialBtn(
                          label: 'FACEBOOK',
                          icon: Icons.facebook,
                          onTap: () => _share(context, 'Facebook')),
                      const SizedBox(width: 10),
                      _SocialBtn(
                          label: 'INSTAGRAM',
                          icon: Icons.camera_alt_outlined,
                          onTap: () => _share(context, 'Instagram')),
                      const SizedBox(width: 10),
                      _SocialBtn(
                          label: 'TIKTOK',
                          icon: Icons.music_note,
                          onTap: () => _share(context, 'TikTok')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(
                          text:
                              'https://play.google.com/store/apps/details?id=com.studio.diy_wallpaper'));
                      CyberToast.show(context, ref.read(stringsProvider).linkCopied);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderCyber),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.link, color: AppColors.textMuted, size: 16),
                          const SizedBox(width: 8),
                          Text(ref.watch(stringsProvider).copyLink,
                              style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontFamily: 'Orbitron',
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, String platform) async {
    final ok = await checkNetwork(context, ref);
    if (!ok) return;

    LoadingModal.show(context, messageBuilder: (s) => s.sharing);
    await Future.delayed(const Duration(milliseconds: 500));
    LoadingModal.hide();

    await SharePlus.instance.share(
      ShareParams(
        text: 'Check out my wallpaper from DIY Wallpaper! https://play.google.com/store/apps/details?id=com.studio.diy_wallpaper',
        subject: 'DIY Wallpaper',
      ),
    );
    analyticsService.logWallpaperShared(
      themeId: widget.args.themeId.toString(),
      sharePlatform: platform.toLowerCase(),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialBtn(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.borderCyber),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.neonCyan, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontFamily: 'Orbitron',
                      fontSize: 8)),
            ],
          ),
        ),
      ),
    );
  }
}
