import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/analytics_events.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../core/theme/widgets/loading_modal.dart';

enum RewardContext { unlockTheme, applyS4, unlockItem }

class RewardModal extends ConsumerWidget {
  final RewardContext rewardContext;
  final VoidCallback onRewarded;
  final VoidCallback? onDecline;
  final String? itemId;
  final String? itemName;

  final bool isFirstUnlock;

  const RewardModal({
    super.key,
    required this.rewardContext,
    required this.onRewarded,
    this.onDecline,
    this.itemId,
    this.itemName,
    this.isFirstUnlock = false,
  });

  String _title(s) => switch (rewardContext) {
        RewardContext.unlockTheme => s.unlockThemeTitle,
        RewardContext.applyS4 => s.applyThemeTitle,
        RewardContext.unlockItem => s.unlockStickerTitle,
      };

  String _body(s) => switch (rewardContext) {
        RewardContext.unlockTheme => s.unlockThemeBody,
        RewardContext.applyS4 => s.applyThemeBody,
        RewardContext.unlockItem => s.unlockStickerBody,
      };

  String get _analyticsItemType => switch (rewardContext) {
        RewardContext.unlockTheme => AnalyticsValue.theme,
        RewardContext.applyS4 => AnalyticsValue.theme,
        RewardContext.unlockItem => AnalyticsValue.sticker,
      };

  String get _analyticsPlacement => switch (rewardContext) {
        RewardContext.unlockTheme => AnalyticsValue.unlockTheme,
        RewardContext.applyS4 => AnalyticsValue.unlockTheme,
        RewardContext.unlockItem => AnalyticsValue.unlockSticker,
      };

  static Future<void> show(
    BuildContext ctx, {
    required RewardContext rewardContext,
    required VoidCallback onRewarded,
    VoidCallback? onDecline,
    String? itemId,
    String? itemName,
    bool isFirstUnlock = false,
  }) {
    analyticsService.logUnlockPromptShown(
      itemType: switch (rewardContext) {
        RewardContext.unlockTheme || RewardContext.applyS4 => AnalyticsValue.theme,
        RewardContext.unlockItem => AnalyticsValue.sticker,
      },
      itemId: itemId ?? '',
      unlockOptions: AnalyticsValue.watchAd,
    );
    return showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => RewardModal(
        rewardContext: rewardContext,
        onRewarded: onRewarded,
        onDecline: onDecline,
        itemId: itemId,
        itemName: itemName,
        isFirstUnlock: isFirstUnlock,
      ),
    );
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
                _title(s),
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _body(s),
                style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani', fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CyberButton(
                label: s.watchVideo,
                fullWidth: true,
                onTap: () {
                  final messenger = ScaffoldMessenger.of(ctx);
                  Navigator.of(ctx).pop();

                  analyticsService.logUnlockMethodSelected(
                    itemType: _analyticsItemType,
                    itemId: itemId ?? '',
                    method: AnalyticsValue.watchAd,
                  );
                  analyticsService.logAdWatchStarted(
                    adType: AnalyticsValue.rewarded,
                    placementId: _analyticsPlacement,
                    itemId: itemId,
                  );

                  final adStartTime = DateTime.now();
                  LoadingModal.show(ctx, messageBuilder: (s) => s.loadingAds);
                  adService.showRewarded(
                    purpose: RewardPurpose.apply,
                    onRewarded: (_) {
                      final durationSec = DateTime.now().difference(adStartTime).inSeconds;
                      LoadingModal.hide();
                      analyticsService.logAdWatchCompleted(
                        adType: AnalyticsValue.rewarded,
                        placementId: _analyticsPlacement,
                        watchDurationSec: durationSec,
                        itemId: itemId,
                      );
                      analyticsService.logItemUnlocked(
                        itemType: _analyticsItemType,
                        itemId: itemId ?? '',
                        itemName: itemName ?? '',
                        method: AnalyticsValue.watchAd,
                        isFirstUnlock: isFirstUnlock,
                      );
                      onRewarded();
                    },
                    onFail: (reason) {
                      LoadingModal.hide();
                      if (reason != 'user_closed') {
                        analyticsService.logAdFailed(
                          adType: AnalyticsValue.rewarded,
                          placementId: _analyticsPlacement,
                          errorCode: reason,
                        );
                        messenger.showSnackBar(
                          SnackBar(content: Text(s.adsUnavailable(reason))),
                        );
                      } else {
                        analyticsService.logUnlockAbandoned(
                          itemType: _analyticsItemType,
                          itemId: itemId ?? '',
                          methodAttempted: AnalyticsValue.watchAd,
                          step: 'ad_closed',
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              CyberButton(
                label: s.noThanks,
                variant: CyberButtonVariant.ghost,
                fullWidth: true,
                onTap: () {
                  analyticsService.logUnlockAbandoned(
                    itemType: _analyticsItemType,
                    itemId: itemId ?? '',
                    methodAttempted: AnalyticsValue.watchAd,
                    step: 'declined',
                  );
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
