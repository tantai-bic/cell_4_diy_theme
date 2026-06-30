import 'package:flutter/material.dart';
import '../app_theme.dart';

class LoadingModal {
  static OverlayEntry? _entry;

  static void show(BuildContext context, {String message = 'PROCESSING...'}) {
    // Đóng hết dialog / bottom sheet đang mở (PopupRoute) trước khi show
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.popUntil((route) => route is! PopupRoute);

    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (_) => _LoadingOverlay(message: message),
    );
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  static bool get isShowing => _entry != null;
}

class _LoadingOverlay extends StatefulWidget {
  final String message;
  const _LoadingOverlay({required this.message});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
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
    return GestureDetector(
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
                  widget.message,
                  style: const TextStyle(
                    color: AppColors.neonCyan,
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

