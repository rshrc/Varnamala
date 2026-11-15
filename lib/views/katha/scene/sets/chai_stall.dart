import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/idle_bit.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// `bg.chai_stall`: Chai Anna's stall, close up. A tarpaulin roof, biscuit
/// jars, a bunch of bananas, strips of chips, a radio, and a bench out front.
class ChaiStallBackdrop extends PositionComponent {
  ChaiStallBackdrop() : super(priority: -10);

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    _paint(Canvas(recorder));
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    // Evening street behind, soft.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.marigold, 0.2)!,
    );
    final far = Paint()..color = KathaInk.skyline;
    for (final (x, w, h) in [
      (0.0, 60.0, 120.0),
      (300.0, 50.0, 140.0),
      (350.0, 50.0, 100.0),
    ]) {
      canvas.drawRect(Rect.fromLTWH(x, 236 - h - 60, w, h), far);
    }

    // The stall's back wall and shelves.
    canvas.drawRect(
      const Rect.fromLTRB(110, 40, 310, 176),
      Paint()..color = Color.lerp(KathaInk.teal, KathaInk.paper, 0.6)!,
    );
    final shelf = Paint()..color = KathaInk.brickShade;
    canvas.drawRect(const Rect.fromLTRB(110, 92, 310, 96), shelf);
    canvas.drawRect(const Rect.fromLTRB(110, 130, 310, 134), shelf);
    // Biscuit jars with red lids.
    for (var i = 0; i < 5; i++) {
      final x = 122 + i * 30.0;
      canvas.drawRRect(
        RRect.fromLTRBR(x, 70, x + 20, 92, const Radius.circular(4)),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6),
      );
      canvas.drawRect(
        Rect.fromLTRB(x + 2, 66, x + 18, 71),
        Paint()..color = KathaInk.brick,
      );
      for (var b = 0; b < 3; b++) {
        canvas.drawCircle(
          Offset(x + 6 + b * 4.0, 86 - b * 4.0),
          3.6,
          Paint()..color = i.isEven ? KathaInk.marigold : KathaInk.khakiShade,
        );
      }
    }
    // A little radio on the lower shelf, aerial up.
    canvas.drawRRect(
      RRect.fromLTRBR(260, 112, 296, 130, const Radius.circular(3)),
      Paint()..color = KathaInk.brick,
    );
    canvas.drawCircle(
      const Offset(270, 121),
      5,
      Paint()..color = KathaInk.ink.withValues(alpha: 0.6),
    );
    canvas.drawLine(
      const Offset(290, 112),
      const Offset(300, 96),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1,
    );
    // Tea glasses upside down, drying.
    for (var i = 0; i < 6; i++) {
      canvas.drawRect(
        Rect.fromLTWH(124 + i * 10.0, 120, 6, 10),
        Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.15)!,
      );
    }

    // Bananas hanging from the roof, chips in strips beside them.
    final banana = Paint()..color = KathaInk.marigold;
    canvas.drawLine(
      const Offset(132, 40),
      const Offset(132, 50),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1,
    );
    for (var i = 0; i < 5; i++) {
      canvas.save();
      canvas.translate(132, 54);
      canvas.rotate(-0.6 + i * 0.3);
      canvas.drawOval(const Rect.fromLTRB(-2.6, 0, 2.6, 16), banana);
      canvas.restore();
    }
    for (var row = 0; row < 4; row++) {
      for (final (x, color) in [
        (286.0, KathaInk.brick),
        (298.0, KathaInk.marigold),
      ]) {
        canvas.drawRect(
          Rect.fromLTWH(x, 44 + row * 11.0, 9, 10),
          Paint()..color = color,
        );
      }
    }

    // Tarpaulin roof, scalloped.
    final tarp = Paint()..color = KathaInk.teal;
    canvas.drawRect(const Rect.fromLTRB(96, 22, 324, 40), tarp);
    for (var x = 96.0; x < 324; x += 19) {
      canvas.drawCircle(Offset(x + 9.5, 40), 9.5, tarp);
    }
    final pole = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 3;
    canvas.drawLine(const Offset(104, 40), const Offset(104, 240), pole);
    canvas.drawLine(const Offset(316, 40), const Offset(316, 240), pole);

    // The ground, and a bench for the regulars.
    canvas.drawRect(
      const Rect.fromLTRB(0, 236, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = KathaInk.footpath,
    );
    canvas.drawRect(
      const Rect.fromLTRB(330, 214, 398, 220),
      Paint()..color = KathaInk.brickShade,
    );
    canvas.drawRect(
      const Rect.fromLTRB(336, 220, 340, 238),
      Paint()..color = KathaInk.brickShade,
    );
    canvas.drawRect(
      const Rect.fromLTRB(388, 220, 392, 238),
      Paint()..color = KathaInk.brickShade,
    );
  }
}

/// The counter, in front of Chai Anna: a stove with the big kettle on it and
/// a row of glasses waiting to be filled.
class ChaiCounterFront extends PositionComponent {
  ChaiCounterFront() : super(priority: 3);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(140, 176, 300, 240),
      Paint()..color = KathaInk.brick,
    );
    canvas.drawRect(
      const Rect.fromLTRB(136, 170, 304, 178),
      Paint()..color = KathaInk.paper,
    );
    final plank = Paint()
      ..color = KathaInk.brickShade
      ..strokeWidth = 1;
    for (var x = 160.0; x < 300; x += 20) {
      canvas.drawLine(Offset(x, 178), Offset(x, 240), plank);
    }
    // Stove and kettle.
    canvas.drawRect(
      const Rect.fromLTRB(150, 164, 186, 170),
      Paint()..color = KathaInk.ink,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(154, 140, 182, 164, const Radius.circular(6)),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!,
    );
    canvas.drawLine(
      const Offset(182, 148),
      const Offset(192, 140),
      Paint()
        ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!
        ..strokeWidth = 2.4,
    );
    // Glasses in a row.
    for (var i = 0; i < 4; i++) {
      final x = 240 + i * 12.0;
      canvas.drawPath(
        Path()
          ..moveTo(x, 158)
          ..lineTo(x + 8, 158)
          ..lineTo(x + 7, 170)
          ..lineTo(x + 1, 170)
          ..close(),
        Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.15)!,
      );
    }
  }
}

/// Steam off the chai kettle, in the occasional puff.
class KettleSteam extends IdleBit {
  KettleSteam({Vector2? at})
    : super(seconds: 1.8, chance: 0.75, position: at ?? Vector2(42, 163));

  @override
  void render(Canvas canvas) {
    if (t <= 0) return;
    for (var i = 0; i < 3; i++) {
      final phase = ((t * 1.5) - i * 0.22).clamp(0.0, 1.0);
      if (phase <= 0 || phase >= 1) continue;
      canvas.drawCircle(
        Offset(math.sin(phase * 5 + i) * 2.4 + i * 1.2, -20 * phase),
        2 + 3.4 * phase,
        Paint()
          ..color = const Color(0xFFFFFFFF)
              .withValues(alpha: 0.75 * (1 - phase)),
      );
    }
  }
}
