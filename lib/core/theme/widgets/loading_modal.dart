import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_provider.dart';
import '../app_theme.dart';

class LoadingModal {
  static OverlayEntry? _entry;

  /// [messageBuilder] được ưu tiên — reactive theo locale.
  /// [message] là static fallback (backward compat).
  static void show(
    BuildContext context, {
    String? message,
    String Function(AppStrings)? messageBuilder,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.popUntil((route) => route is! PopupRoute);

    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (_) => _LoadingOverlay(
        message: message,
        messageBuilder: messageBuilder,
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  static bool get isShowing => _entry != null;
}

class _LoadingOverlay extends ConsumerStatefulWidget {
  final String? message;
  final String Function(AppStrings)? messageBuilder;

  const _LoadingOverlay({this.message, this.messageBuilder});

  @override
  ConsumerState<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends ConsumerState<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final msg = widget.messageBuilder != null
        ? widget.messageBuilder!(s)
        : (widget.message ?? s.systemApplying);

    // Material(transparency) prevents inheriting DefaultTextStyle underline from Overlay
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: AppColors.bgAmoled.withOpacity(0.92),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.neonGlow(
                        AppColors.neonCyan,
                        blur: 20 * _pulse.value,
                      ),
                    ),
                    child: CircularProgressIndicator(
                      color: AppColors.neonCyan.withOpacity(_pulse.value),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  msg,
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    letterSpacing: 2,
                    decoration: TextDecoration.none,
                    decorationColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
