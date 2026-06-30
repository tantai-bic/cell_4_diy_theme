import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/wallpaper_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../core/theme/widgets/loading_modal.dart';

class SetWallpaperModal extends StatelessWidget {
  const SetWallpaperModal({super.key});

  /// Hiển thị dialog chọn target, sau đó dùng [ctx] của CALLER để show
  /// LoadingModal + Toast + gọi [onSuccess] — tránh dùng dialog context đã bị pop.
  static Future<void> show(
    BuildContext ctx, {
    required String imagePath,
    VoidCallback? onSuccess,
  }) async {
    final target = await showDialog<WallpaperTarget>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const SetWallpaperModal(),
    );

    if (target == null) return; // user cancelled

    // ctx là caller context (gallery/garage) — valid sau khi dialog đã đóng
    LoadingModal.show(ctx, message: 'SYSTEM APPLYING...');
    final ok = await WallpaperService.setWallpaper(imagePath, target);
    LoadingModal.hide();

    if (ok) {
      HapticFeedback.heavyImpact();
      CyberToast.show(ctx, 'WALLPAPER SET!', haptic: false);
      onSuccess?.call();
    } else {
      CyberToast.show(ctx, 'SET FAILED. TRY AGAIN.', variant: ToastVariant.pink);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SET WALLPAPER',
                style: TextStyle(
                  color: AppColors.neonCyan,
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CyberButton(
                label: 'HOME SCREEN',
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(WallpaperTarget.home),
              ),
              const SizedBox(height: 12),
              CyberButton(
                label: 'LOCK SCREEN',
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(WallpaperTarget.lock),
              ),
              const SizedBox(height: 12),
              CyberButton(
                label: 'BOTH',
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(WallpaperTarget.both),
              ),
              const SizedBox(height: 16),
              CyberButton(
                label: 'CANCEL',
                variant: CyberButtonVariant.ghost,
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
