import 'dart:math' as math;
import 'dart:ui';

import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// A small steel tumbler of tea, held from the bottom.
void drawTeaGlass(Canvas canvas, Offset hand) {
  final glass = Path()
    ..moveTo(hand.dx - 3.6, hand.dy - 9)
    ..lineTo(hand.dx + 3.6, hand.dy - 9)
    ..lineTo(hand.dx + 2.8, hand.dy + 1)
    ..lineTo(hand.dx - 2.8, hand.dy + 1)
    ..close();
  canvas.drawPath(
    glass,
    Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.15)!,
  );
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 3.3, hand.dy - 7.6, hand.dx + 3.3, hand.dy - 6),
    Paint()..color = KathaInk.khakiShade,
  );
}

void drawJeans(Canvas canvas) {
  final denim = Paint()..color = KathaInk.denim;
  canvas.drawRect(const Rect.fromLTRB(-10, -34, -1.2, -3), denim);
  canvas.drawRect(const Rect.fromLTRB(1.2, -34, 10, -3), denim);
  final shoe = Paint()..color = const Color(0xFFFFFFFF);
  canvas.drawRRect(
    RRect.fromLTRBR(-11.5, -4, 0, 0.6, const Radius.circular(2.4)),
    shoe,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(1.5, -4, 13, 0.6, const Radius.circular(2.4)),
    shoe,
  );
}

/// A phone, screen lit.
void drawPhone(Canvas canvas, Offset hand) {
  canvas.drawRRect(
    RRect.fromLTRBR(
      hand.dx - 3.6,
      hand.dy - 7,
      hand.dx + 3.6,
      hand.dy + 5,
      const Radius.circular(1.6),
    ),
    Paint()..color = KathaInk.ink,
  );
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 2.6, hand.dy - 5.6, hand.dx + 2.6, hand.dy + 3.4),
    Paint()..color = Color.lerp(KathaInk.teal, KathaInk.paper, 0.5)!,
  );
}

/// A head with a jaw rather than a ball: round on top, a little narrower and
/// longer at the chin, with ears and a shadow where it meets the neck.
void drawHead(
  Canvas canvas, {
  required double radius,
  required Color skin,
  required void Function(Canvas canvas, double radius) hair,
  bool moustache = false,
  bool bindi = false,
  bool glasses = false,
}) {
  final r = radius;
  final skinPaint = Paint()..color = skin;
  final shade = Paint()..color = Color.lerp(skin, KathaInk.ink, 0.2)!;

  for (final side in [-1.0, 1.0]) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(side * r * 0.98, r * 0.12),
        width: r * 0.44,
        height: r * 0.56,
      ),
      skinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(side * r * 1.0, r * 0.14),
        width: r * 0.18,
        height: r * 0.28,
      ),
      shade,
    );
  }

  final skull = Path()
    ..moveTo(-r, -r * 0.08)
    ..arcTo(
      Rect.fromCircle(center: Offset(0, -r * 0.08), radius: r),
      math.pi,
      math.pi,
      false,
    )
    ..cubicTo(r, r * 0.62, r * 0.62, r * 1.12, 0, r * 1.14)
    ..cubicTo(-r * 0.62, r * 1.12, -r, r * 0.62, -r, -r * 0.08)
    ..close();
  canvas.drawPath(skull, skinPaint);
  hair(canvas, r);
  if (bindi) {
    canvas.drawCircle(
      Offset(-r * 0.1, -r * 0.42),
      r * 0.1,
      Paint()..color = KathaInk.brick,
    );
  }
  if (glasses) {
    // Reading glasses low on the nose, so she can look over them.
    final frame = Paint()
      ..color = KathaInk.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08;
    final s = r / 12;
    for (final x in [-4.6 * s - 1.5 * s, 4.6 * s - 1.5 * s]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, 2.2 * s),
            width: 6.6 * s,
            height: 4 * s,
          ),
          Radius.circular(1.6 * s),
        ),
        frame,
      );
    }
    canvas.drawLine(Offset(-2.6 * s, 2 * s), Offset(-0.4 * s, 2 * s), frame);
  }

  if (moustache) {
    final s = r / 12;
    final path = Path()
      ..moveTo(-7 * s, 6.4 * s)
      ..quadraticBezierTo(-4.2 * s, 2.6 * s, -0.6 * s, 4.2 * s)
      ..quadraticBezierTo(2.4 * s, 2.6 * s, 6 * s, 6.4 * s)
      ..quadraticBezierTo(2.6 * s, 6 * s, -0.6 * s, 6.9 * s)
      ..quadraticBezierTo(-3.6 * s, 6 * s, -7 * s, 6.4 * s)
      ..close();
    canvas.drawPath(
      path.shift(Offset(-1.2 * s, 0)),
      Paint()..color = KathaInk.ink,
    );
  }
}
