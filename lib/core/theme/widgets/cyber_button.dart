import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'chamfer_clipper.dart';

enum CyberButtonVariant { primary, secondary, danger, ghost }

class CyberButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final CyberButtonVariant variant;
  final double cut;
  final bool fullWidth;
  final Widget? icon;

  const CyberButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = CyberButtonVariant.primary,
    this.cut = 8.0,
    this.fullWidth = false,
    this.icon,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool _pressed = false;

  Color get _bgColor => switch (widget.variant) {
        CyberButtonVariant.primary => AppColors.neonCyan,
        CyberButtonVariant.secondary => AppColors.bgCard,
        CyberButtonVariant.danger => AppColors.neonPink,
        CyberButtonVariant.ghost => Colors.transparent,
      };

  Color get _textColor => switch (widget.variant) {
        CyberButtonVariant.primary => AppColors.bgAmoled,
        CyberButtonVariant.secondary => AppColors.neonCyan,
        CyberButtonVariant.danger => Colors.white,
        CyberButtonVariant.ghost => AppColors.neonCyan,
      };

  List<BoxShadow>? get _shadows => widget.onTap == null
      ? null
      : switch (widget.variant) {
          CyberButtonVariant.primary => AppTheme.cyanGlow,
          CyberButtonVariant.danger => AppTheme.pinkGlow,
          _ => null,
        };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 80),
        opacity: _pressed ? 0.7 : 1.0,
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(boxShadow: _shadows),
          child: ClipPath(
            clipper: ChamferClipper(cut: widget.cut),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: _bgColor,
              child: Row(
                mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: _textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
