import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/services/wallpaper_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../core/theme/widgets/loading_modal.dart';

class SetWallpaperModal extends ConsumerWidget {
  const SetWallpaperModal({super.key});

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

    if (target == null) return;

    // Bật foreground service trước — MIUI sẽ không kill app khi system picker mở
    await WallpaperService.startShield();

    LoadingModal.show(ctx, messageBuilder: (s) => s.systemApplying);
    final ok = await WallpaperService.setWallpaper(imagePath, target);
    LoadingModal.hide();

    // Tắt shield sau khi set xong
    await WallpaperService.stopShield();

    if (ok) {
      HapticFeedback.heavyImpact();
      CyberToast.show(ctx, '✓', haptic: false);
      onSuccess?.call();
    } else {
      CyberToast.show(ctx, '✗', variant: ToastVariant.pink);
    }
  }

  /// Preferred: caller passes [s] so strings are localized correctly.
  static Future<void> showLocalized(
    BuildContext ctx,
    AppStrings s, {
    required String imagePath,
    VoidCallback? onSuccess,
  }) async {
    final target = await showDialog<WallpaperTarget>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const SetWallpaperModal(),
    );

    if (target == null) return;

    // Bật foreground service trước — MIUI sẽ không kill app khi system picker mở
    await WallpaperService.startShield();

    LoadingModal.show(ctx, messageBuilder: (s) => s.systemApplying);
    final ok = await WallpaperService.setWallpaper(imagePath, target);
    LoadingModal.hide();

    // Tắt shield sau khi set xong
    await WallpaperService.stopShield();

    if (ok) {
      HapticFeedback.heavyImpact();
      CyberToast.show(ctx, s.wallpaperSet, haptic: false);
      onSuccess?.call();
    } else {
      CyberToast.show(ctx, s.wallpaperSetFailed, variant: ToastVariant.pink);
    }
  }

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
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
              Text(
                s.setWallpaperTitle,
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CyberButton(
                label: s.homeScreen,
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(WallpaperTarget.home),
              ),
              const SizedBox(height: 12),
              CyberButton(
                label: s.lockScreen,
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(WallpaperTarget.lock),
              ),
              const SizedBox(height: 12),
              CyberButton(
                label: s.both,
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(WallpaperTarget.both),
              ),
              const SizedBox(height: 16),
              CyberButton(
                label: s.cancel,
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
