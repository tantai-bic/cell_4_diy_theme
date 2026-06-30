import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/network_provider.dart';
import '../theme/app_theme.dart';
import '../theme/widgets/cyber_button.dart';

Future<bool> checkNetwork(BuildContext context, WidgetRef ref, {
  Future<void> Function()? onRetry,
  String taskLabel = '',
}) async {
  final net = ref.read(networkProvider).valueOrNull;
  if (net?.isOnline ?? true) return true;

  if (onRetry != null) {
    ref.read(networkProvider.notifier).setInterruptedTask(onRetry, taskLabel);
  }

  await showNoInternetModal(context, ref);
  return false;
}

Future<void> showNoInternetModal(BuildContext context, WidgetRef ref) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _NoInternetModal(ref: ref),
  );
}

class _NoInternetModal extends ConsumerWidget {
  final WidgetRef ref;
  const _NoInternetModal({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final net = widgetRef.watch(networkProvider).valueOrNull;

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
              const Icon(Icons.wifi_off, color: AppColors.neonPink, size: 48),
              const SizedBox(height: 16),
              const Text(
                'NO SIGNAL',
                style: TextStyle(
                  color: AppColors.neonPink,
                  fontFamily: 'Orbitron',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kiểm tra kết nối mạng và thử lại.',
                style: TextStyle(color: AppColors.textMuted, fontFamily: 'Rajdhani'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      label: 'SETTINGS',
                      variant: CyberButtonVariant.ghost,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CyberButton(
                      label: 'RETRY',
                      onTap: () async {
                        final isOnline = widgetRef.read(networkProvider).valueOrNull?.isOnline ?? false;
                        if (isOnline) {
                          if (context.mounted) Navigator.of(context).pop();
                          await widgetRef.read(networkProvider.notifier).retryInterruptedTask();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
