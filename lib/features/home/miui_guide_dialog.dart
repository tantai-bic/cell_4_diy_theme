import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/services/miui_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';

const _kGuideShownKey = 'miui_guide_shown';

/// Kiểm tra và hiển thị MIUI guide một lần duy nhất.
/// Gọi từ HomeScreen.initState() sau khi frame đầu render xong.
Future<void> showMiuiGuideIfNeeded(BuildContext context) async {
  final isDevice = await MiuiService.isMiui();
  if (!isDevice) return;

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_kGuideShownKey) == true) return;
  await prefs.setBool(_kGuideShownKey, true);

  if (!context.mounted) return;
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _MiuiGuideDialog(),
  );
}

class _MiuiGuideDialog extends ConsumerWidget {
  const _MiuiGuideDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Dialog(
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                s.miuiGuideTitle,
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontFamily: 'Orbitron',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                s.miuiGuideSubtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Rajdhani',
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.borderCyber, height: 1),
            const SizedBox(height: 16),

            // Step 1
            _StepCard(
              number: '1',
              title: s.miuiGuideStep1Title,
              body: s.miuiGuideStep1Body,
              buttonLabel: s.miuiGuideOpenAutostart,
              onTap: MiuiService.openAutostartSettings,
            ),
            const SizedBox(height: 12),

            // Step 2
            _StepCard(
              number: '2',
              title: s.miuiGuideStep2Title,
              body: s.miuiGuideStep2Body,
              buttonLabel: s.miuiGuideOpenBattery,
              onTap: MiuiService.openBatterySettings,
            ),
            const SizedBox(height: 20),

            // Done button
            CyberButton(
              label: s.miuiGuideDone,
              fullWidth: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final String buttonLabel;
  final Future<void> Function() onTap;

  const _StepCard({
    required this.number,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderCyber),
        color: AppColors.bgAmoled,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                color: AppColors.neonCyan,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.bgAmoled,
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontFamily: 'Rajdhani',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          CyberButton(
            label: buttonLabel,
            variant: CyberButtonVariant.secondary,
            fullWidth: true,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
