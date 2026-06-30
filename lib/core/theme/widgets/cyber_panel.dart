import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'chamfer_clipper.dart';

class CyberPanel extends StatelessWidget {
  final Widget child;
  final double cut;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool glowing;

  const CyberPanel({
    super.key,
    required this.child,
    this.cut = 10.0,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: glowing ? AppTheme.neonGlow(borderColor ?? AppColors.neonCyan, blur: 8) : null,
      ),
      child: ClipPath(
        clipper: ChamferClipper(cut: cut),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.bgCard,
            border: Border.all(color: borderColor ?? AppColors.borderCyber, width: 1),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
