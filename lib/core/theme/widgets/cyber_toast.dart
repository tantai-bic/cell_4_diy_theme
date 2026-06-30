import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';

enum ToastVariant { normal, pink, flash }

class CyberToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    ToastVariant variant = ToastVariant.normal,
    Duration duration = const Duration(milliseconds: 2500),
    bool haptic = true,
  }) {
    _current?.remove();
    _current = null;

    if (haptic) {
      HapticFeedback.lightImpact();
    }

    final Color glowColor = switch (variant) {
      ToastVariant.pink || ToastVariant.flash => AppColors.neonPink,
      ToastVariant.normal => AppColors.neonCyan,
    };

    final OverlayEntry entry = OverlayEntry(
      builder: (_) => _CyberToastWidget(
        message: message,
        glowColor: glowColor,
        variant: variant,
      ),
    );

    _current = entry;
    Overlay.of(context).insert(entry);

    Future.delayed(duration, () {
      if (_current == entry) {
        entry.remove();
        _current = null;
      }
    });
  }
}

class _CyberToastWidget extends StatefulWidget {
  final String message;
  final Color glowColor;
  final ToastVariant variant;

  const _CyberToastWidget({
    required this.message,
    required this.glowColor,
    required this.variant,
  });

  @override
  State<_CyberToastWidget> createState() => _CyberToastWidgetState();
}

class _CyberToastWidgetState extends State<_CyberToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _opacity,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: widget.glowColor.withOpacity(0.6)),
              boxShadow: AppTheme.neonGlow(widget.glowColor, blur: 10),
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                color: widget.glowColor,
                fontFamily: 'Orbitron',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
