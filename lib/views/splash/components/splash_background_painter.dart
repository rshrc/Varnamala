import 'package:flutter/material.dart';

class SplashBackgroundPainter extends CustomPainter {
  const SplashBackgroundPainter({
    required this.warm,
    required this.mid,
    required this.accent,
  });

  /// Passed in rather than read from the theme, because a painter has no
  /// [BuildContext] - which is what kept this screen on the old fixed colours.
  final Color warm;
  final Color mid;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // First Curve - Top Right (Warm Gold)
    paint.color = warm.withValues(alpha: 0.15);
    final path1 = Path();
    path1.moveTo(size.width, 0);
    path1.lineTo(size.width, size.height * 0.35);
    path1.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      0,
      size.height * 0.25,
    );
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint);

    // Second Curve - Middle/Bottom Layer (Coral/Orange)
    paint.color = mid.withValues(alpha: 0.15);
    final path2 = Path();
    path2.moveTo(size.width, size.height);
    path2.lineTo(size.width, size.height * 0.6);
    path2.cubicTo(
      size.width * 0.7,
      size.height * 0.5, // Control point 1
      size.width * 0.3,
      size.height * 0.8, // Control point 2
      0,
      size.height * 0.55,
    );
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);

    // Third Curve - Bottom Left Accent (Red/Coral)
    paint.color = accent.withValues(alpha: 0.1);
    final path3 = Path();
    path3.moveTo(0, size.height);
    path3.lineTo(0, size.height * 0.75);
    path3.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.85,
      size.width * 0.6,
      size.height,
    );
    path3.close();
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(SplashBackgroundPainter old) =>
      old.warm != warm || old.mid != mid || old.accent != accent;
}
