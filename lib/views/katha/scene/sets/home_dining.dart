import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// The landlady's dining room at night: a steel almirah, the family
/// photograph (her son, in his graduation cap), a wall calendar, a television
/// under a lace cover - and through the window, in the rain, the neta's
/// hoarding promising round-the-clock power, the only thing on the street
/// that is lit.
class HomeDiningBackdrop extends PositionComponent {
  HomeDiningBackdrop() : super(priority: -10);

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    _paint(Canvas(recorder));
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    final wall = Color.lerp(KathaInk.paper, KathaInk.leaf, 0.22)!;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, 204),
      fillOf(wall),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 196, kathaWorldWidth, 204),
      fillOf(Color.lerp(wall, KathaInk.ink, 0.18)!),
    );
    // Red-oxide floor and a reed mat.
    canvas.drawRect(
      const Rect.fromLTRB(0, 204, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(KathaInk.brick, KathaInk.ink, 0.18)!),
    );
    final mat = Rect.fromLTRB(70, 214, 250, 252);
    canvas.drawRect(
      mat,
      fillOf(Color.lerp(KathaInk.marigold, KathaInk.paper, 0.35)!),
    );
    final weave = Paint()
      ..color = KathaInk.marigoldShade.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (var y = mat.top + 4; y < mat.bottom; y += 5) {
      canvas.drawLine(Offset(mat.left, y), Offset(mat.right, y), weave);
    }
    canvas.drawRect(
      Rect.fromLTRB(mat.left, mat.top, mat.left + 5, mat.bottom),
      fillOf(KathaInk.brick),
    );
    canvas.drawRect(
      Rect.fromLTRB(mat.right - 5, mat.top, mat.right, mat.bottom),
      fillOf(KathaInk.brick),
    );

    // Window, right: rain, and the hoarding lit up across the road.
    const win = Rect.fromLTRB(292, 40, 384, 128);
    canvas.drawRect(win, fillOf(const Color(0xFF1C2A44)));
    hoarding(canvas, const Rect.fromLTRB(304, 56, 372, 100));
    final rain = Paint()
      ..color = const Color(0xFFBFD3E6).withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 0; i < 26; i++) {
      final x = win.left + (i * 37 % 92);
      final y = win.top + (i * 53 % 80);
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 9), rain);
    }
    final grille = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 1.4;
    for (var x = win.left + 10; x < win.right; x += 11) {
      canvas.drawLine(Offset(x, win.top), Offset(x, win.bottom), grille);
    }
    canvas.drawRect(
      win,
      Paint()
        ..color = KathaInk.brickShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // The family photograph, garlanded: her son in his graduation cap.
    const frame = Rect.fromLTRB(150, 34, 196, 88);
    canvas.drawRect(frame, fillOf(KathaInk.marigoldShade));
    canvas.drawRect(
      frame.deflate(4),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.25)!),
    );
    final c = frame.center.translate(0, 6);
    canvas.drawCircle(c.translate(0, 14), 13, fillOf(KathaInk.ink));
    canvas.drawCircle(c, 9, fillOf(KathaInk.skinWarm));
    canvas.drawRect(
      Rect.fromCenter(center: c.translate(0, -9), width: 22, height: 3),
      fillOf(KathaInk.ink),
    );
    canvas.drawRect(
      Rect.fromCenter(center: c.translate(0, -11), width: 10, height: 4),
      fillOf(KathaInk.ink),
    );
    canvas.drawLine(
      c.translate(10, -10),
      c.translate(12, -2),
      Paint()
        ..color = KathaInk.marigold
        ..strokeWidth = 1.2,
    );
    canvas.drawArc(
      Rect.fromCenter(center: c.translate(0, 2), width: 7, height: 4),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final garland = fillOf(KathaInk.marigold);
    for (var i = 0; i <= 10; i++) {
      final t = i / 10;
      canvas.drawCircle(
        Offset(
          frame.left + frame.width * t,
          frame.bottom - 2 + math.sin(t * math.pi) * 8,
        ),
        2.4,
        i.isEven ? garland : fillOf(KathaInk.paper),
      );
    }

    // Wall calendar, a month with every day ticked.
    canvas.drawRect(
      const Rect.fromLTRB(214, 44, 252, 96),
      fillOf(KathaInk.paper),
    );
    canvas.drawRect(
      const Rect.fromLTRB(214, 44, 252, 60),
      fillOf(KathaInk.brick),
    );
    final tick = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        final o = Offset(219 + col * 7.0, 66 + row * 7.0);
        canvas.drawLine(o, o.translate(3, 3), tick);
      }
    }

    // Steel almirah, left, with a lock and a calendar-girl sticker.
    canvas.drawRRect(
      RRect.fromLTRBR(14, 70, 70, 204, const Radius.circular(3)),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.28)!),
    );
    canvas.drawLine(
      const Offset(42, 74),
      const Offset(42, 200),
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );
    canvas.drawRect(
      const Rect.fromLTRB(46, 126, 52, 134),
      fillOf(KathaInk.marigoldShade),
    );
    canvas.drawRect(
      const Rect.fromLTRB(20, 84, 36, 104),
      fillOf(KathaInk.leaf),
    );
    canvas.drawCircle(const Offset(28, 92), 4, fillOf(KathaInk.skinWarm));

    // The television, under its lace, on a little stand.
    canvas.drawRect(
      const Rect.fromLTRB(262, 168, 314, 204),
      fillOf(KathaInk.brickShade),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(266, 134, 310, 168, const Radius.circular(4)),
      fillOf(KathaInk.ink),
    );
    canvas.drawRect(
      const Rect.fromLTRB(270, 138, 306, 162),
      fillOf(const Color(0xFF26333B)),
    );
    final lace = Path()..moveTo(264, 134);
    for (var x = 264.0; x <= 312; x += 6) {
      lace.lineTo(x + 3, 142);
      lace.lineTo(x + 6, 134);
    }
    canvas.drawPath(lace..close(), fillOf(KathaInk.paper));
  }

  /// The neta, lit by two spotlights: a lightning bolt and 24x7.
  static void hoarding(Canvas canvas, Rect r) {
    canvas.drawRect(r, fillOf(const Color(0xFFFFF2C4)));
    canvas.drawPath(
      Path()
        ..moveTo(r.left + 40, r.top + 6)
        ..lineTo(r.left + 32, r.top + 22)
        ..lineTo(r.left + 40, r.top + 22)
        ..lineTo(r.left + 34, r.top + 38)
        ..lineTo(r.left + 48, r.top + 17)
        ..lineTo(r.left + 40, r.top + 17)
        ..lineTo(r.left + 46, r.top + 6)
        ..close(),
      fillOf(KathaInk.marigoldShade),
    );
    final face = Offset(r.left + 16, r.top + 20);
    canvas.drawCircle(face.translate(0, 14), 11, fillOf(KathaInk.paper));
    canvas.drawCircle(face, 9, fillOf(KathaInk.skinDeep));
    canvas.drawRect(
      Rect.fromCenter(center: face.translate(0, -1), width: 14, height: 4),
      fillOf(KathaInk.ink),
    );
    canvas.drawRect(
      Rect.fromCenter(center: face.translate(0, 4), width: 9, height: 2),
      fillOf(KathaInk.ink),
    );
    final digits = TextPainterLite.digits('24x7', 9, KathaInk.brick);
    digits.paint(canvas, Offset(r.left + 50, r.bottom - 14));
    // Spotlights from below.
    for (final x in [r.left + 10, r.right - 10]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, r.bottom + 10)
          ..lineTo(x - 14, r.top)
          ..lineTo(x + 14, r.top)
          ..close(),
        fillOf(const Color(0xFFFFF2C4).withValues(alpha: 0.16)),
      );
    }
    canvas.drawRect(
      r,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }
}

/// The neta's hoarding through the dining-room window, drawn again above the
/// power cut: when every light on the street goes, it is the one still on.
class HoardingLight extends PositionComponent {
  HoardingLight() : super(priority: 10);

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.clipRect(const Rect.fromLTRB(292, 40, 384, 128));
    HomeDiningBackdrop.hoarding(canvas, const Rect.fromLTRB(304, 56, 372, 100));
    final grille = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 1.4;
    for (var x = 302.0; x < 384; x += 11) {
      canvas.drawLine(Offset(x, 40), Offset(x, 128), grille);
    }
    canvas.restore();
  }
}

/// A steel plate on the floor - rice, sambar, a papad - a tumbler of water,
/// and the crossed legs of whoever sits to eat it.
class FloorMeal extends PositionComponent {
  FloorMeal({
    required double x,
    Color? trousers,
    this.skin = KathaInk.skinWarm,
    this.withPlate = true,
  }) : trousers = trousers ?? KathaInk.denim,
       super(position: Vector2(x, 0), priority: 4);

  /// Whoever is sitting: their trousers, and their feet.
  final Color trousers;
  final Color skin;

  /// Whether there is a meal in front: not when just sitting on the steps.
  final bool withPlate;

  @override
  void render(Canvas canvas) {
    // Crossed legs.
    final denim = fillOf(trousers);
    canvas.drawRRect(
      RRect.fromLTRBR(-30, 214, 30, 232, const Radius.circular(9)),
      denim,
    );
    canvas.drawOval(const Rect.fromLTRB(-34, 222, -14, 234), fillOf(skin));
    canvas.drawOval(const Rect.fromLTRB(14, 222, 34, 234), fillOf(skin));
    if (!withPlate) return;
    // The plate, in front.
    final plate = Rect.fromCenter(
      center: const Offset(0, 240),
      width: 64,
      height: 16,
    );
    canvas.drawOval(
      plate,
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.22)!),
    );
    canvas.drawOval(
      plate.deflate(3),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.1)!),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-8, 237), width: 24, height: 9),
      fillOf(KathaInk.paper),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, 239), width: 16, height: 7),
      fillOf(KathaInk.marigoldShade),
    );
    canvas.drawCircle(
      const Offset(-20, 241),
      6,
      fillOf(Color.lerp(KathaInk.marigold, KathaInk.paper, 0.5)!),
    );
    // Tumbler.
    canvas.drawRect(
      const Rect.fromLTRB(40, 230, 48, 244),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!),
    );
  }
}
