import 'package:flutter/material.dart';

class ChamferClipper extends CustomClipper<Path> {
  final double cut;

  const ChamferClipper({this.cut = 12.0});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, cut)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(cut, size.height)
      ..lineTo(0, size.height - cut)
      ..lineTo(0, cut)
      ..close();
  }

  @override
  bool shouldReclip(ChamferClipper old) => old.cut != cut;
}

class ChamferWidget extends StatelessWidget {
  final Widget child;
  final double cut;
  final Color? color;
  final List<BoxShadow>? shadows;

  const ChamferWidget({
    super.key,
    required this.child,
    this.cut = 12.0,
    this.color,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    Widget clipped = ClipPath(
      clipper: ChamferClipper(cut: cut),
      child: child,
    );

    if (color != null || shadows != null) {
      return Container(
        decoration: BoxDecoration(
          color: color,
          boxShadow: shadows,
        ),
        child: ClipPath(
          clipper: ChamferClipper(cut: cut),
          child: child,
        ),
      );
    }

    return clipped;
  }
}
