import 'package:flutter/material.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../core/theme/widgets/loading_modal.dart';

enum RewardContext { unlockTheme, applyS4, unlockItem }

class RewardModal extends StatelessWidget {
  final RewardContext context;
  final VoidCallback onRewarded;
  final VoidCallback? onDecline;

  const RewardModal({
    super.key,
    required this.context,
    required this.onRewarded,
    this.onDecline,
  });

  String get _title => switch (context) {
        RewardContext.unlockTheme => 'MỞ KHÓA THEME',
        RewardContext.applyS4 => 'ÁP DỤNG THEME',
        RewardContext.unlockItem => 'MỞ KHÓA STICKER',
      };

  String get _body => switch (context) {
        RewardContext.unlockTheme => 'Xem 1 video quảng cáo để mở khóa theme này vĩnh viễn.',
        RewardContext.applyS4 => 'Xem 1 video quảng cáo để áp dụng thiết kế của bạn.',
        RewardContext.unlockItem => 'Xem 1 video quảng cáo để mở khóa sticker này vĩnh viễn.',
      };

  static Future<void> show(
    BuildContext ctx, {
    required RewardContext rewardContext,
    required VoidCallback onRewarded,
    VoidCallback? onDecline,
  }) {
    return showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => RewardModal(
        context: rewardContext,
        onRewarded: onRewarded,
        onDecline: onDecline,
      ),
    );
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
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cyanGlow,
                ),
                child: const Icon(Icons.play_circle_outline, color: AppColors.neonCyan, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                _title,
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _body,
                style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CyberButton(
                label: 'XEM VIDEO',
                fullWidth: true,
                onTap: () {
                  // Lấy messenger TRƯỚC khi pop (ctx vẫn còn valid)
                  final messenger = ScaffoldMessenger.of(ctx);
                  Navigator.of(ctx).pop();
                  LoadingModal.show(ctx, message: 'LOADING ADS...');
                  adService.showRewarded(
                    purpose: RewardPurpose.apply,
                    onRewarded: (_) {
                      LoadingModal.hide();
                      onRewarded();
                    },
                    onFail: (reason) {
                      LoadingModal.hide();
                      if (reason != 'user_closed') {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Ads không khả dụng: $reason')),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              CyberButton(
                label: 'KHÔNG XEM',
                variant: CyberButtonVariant.ghost,
                fullWidth: true,
                onTap: () {
                  Navigator.of(ctx).pop();
                  onDecline?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
