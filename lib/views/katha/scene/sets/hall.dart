import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// `bg.hall`: the ward office hall on a hearing day. Government green walls,
/// a ceiling fan that does not turn, files stacked to the ceiling on a steel
/// cupboard, rows of chairs, and on a dais the officer behind a table with a
/// green cloth. A podium stands in front of the dais for whoever speaks.
class HallBackdrop extends PositionComponent {
  HallBackdrop() : super(priority: -10);

  static const ground = 232.0;

  /// Where the speaker stands, at the podium.
  static const podiumX = 248.0;

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    _paint(Canvas(recorder));
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    final wall = Color.lerp(KathaInk.paper, KathaInk.leaf, 0.3)!;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, 232),
      fillOf(wall),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 150, kathaWorldWidth, 232),
      fillOf(Color.lerp(wall, KathaInk.ink, 0.1)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 232, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.25)!),
    );
    // The fan, still.
    canvas.drawLine(
      const Offset(140, 0),
      const Offset(140, 20),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 2,
    );
    canvas.drawCircle(const Offset(140, 22), 5, fillOf(KathaInk.shutter));
    canvas.drawRect(
      const Rect.fromLTRB(104, 20, 176, 24),
      fillOf(KathaInk.shutter),
    );
    // A cobweb from the fan to the corner.
    canvas.drawLine(
      const Offset(176, 22),
      const Offset(200, 6),
      Paint()
        ..color = KathaInk.paper.withValues(alpha: 0.5)
        ..strokeWidth = 0.6,
    );
    // The steel cupboard and its files.
    canvas.drawRect(
      const Rect.fromLTRB(16, 70, 76, 200),
      fillOf(KathaInk.shutter),
    );
    canvas.drawLine(
      const Offset(46, 70),
      const Offset(46, 200),
      Paint()..color = KathaInk.ink.withValues(alpha: 0.3),
    );
    for (var i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(18 + (i % 2) * 6.0, 66 - i * 6.0, 56, 6),
        fillOf(i.isEven ? const Color(0xFFD9C79A) : const Color(0xFFC9B07A)),
      );
    }
    // A painting of hills, a wall clock.
    canvas.drawRect(
      const Rect.fromLTRB(100, 60, 170, 104),
      fillOf(KathaInk.marigoldShade),
    );
    canvas.drawRect(
      const Rect.fromLTRB(104, 64, 166, 100),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.3)!),
    );
    canvas.drawPath(
      Path()
        ..moveTo(104, 100)
        ..lineTo(130, 74)
        ..lineTo(150, 92)
        ..lineTo(166, 80)
        ..lineTo(166, 100)
        ..close(),
      fillOf(KathaInk.leaf),
    );
    canvas.drawCircle(const Offset(212, 50), 12, fillOf(KathaInk.paper));
    canvas.drawCircle(
      const Offset(212, 50),
      12,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      const Offset(212, 50),
      const Offset(212, 42),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      const Offset(212, 50),
      const Offset(218, 52),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1.4,
    );
    // Rows of chairs, backs to us, on the left.
    for (var row = 0; row < 2; row++) {
      for (var i = 0; i < 5; i++) {
        final x = 10.0 + i * 34 + row * 14;
        final y = 196.0 + row * 14;
        canvas.drawRRect(
          RRect.fromLTRBR(x, y - 20, x + 22, y, const Radius.circular(3)),
          fillOf(KathaInk.brickShade),
        );
      }
    }
    // The dais, the table with its green cloth, files, and the officer.
    canvas.drawRect(
      const Rect.fromLTRB(276, 190, 400, 232),
      fillOf(Color.lerp(KathaInk.marigoldShade, KathaInk.ink, 0.3)!),
    );
    final skin = Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.4)!;
    canvas.drawPath(
      Path()
        ..moveTo(312, 160)
        ..quadraticBezierTo(314, 136, 338, 134)
        ..quadraticBezierTo(362, 136, 364, 160)
        ..close(),
      fillOf(KathaInk.paper),
    );
    canvas.drawOval(const Rect.fromLTRB(326, 104, 350, 132), fillOf(skin));
    canvas.drawPath(
      Path()
        ..moveTo(326, 114)
        ..cubicTo(326, 100, 350, 100, 350, 114)
        ..lineTo(347, 109)
        ..cubicTo(342, 105, 334, 105, 329, 109)
        ..close(),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.5)!),
    );
    final frame = Paint()
      ..color = KathaInk.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(const Rect.fromLTRB(329, 115, 337, 121), frame);
    canvas.drawRect(const Rect.fromLTRB(339, 115, 347, 121), frame);
    canvas.drawRect(
      const Rect.fromLTRB(290, 158, 400, 196),
      fillOf(const Color(0xFF2F6B4A)),
    );
    canvas.drawRect(
      const Rect.fromLTRB(290, 156, 400, 160),
      fillOf(Color.lerp(const Color(0xFF2F6B4A), KathaInk.paper, 0.3)!),
    );
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(296, 148 - i * 5.0, 34, 5),
        fillOf(i.isEven ? const Color(0xFFD9C79A) : const Color(0xFFC9B07A)),
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(364, 146, 372, 156),
      fillOf(KathaInk.teal.withValues(alpha: 0.7)),
    );
  }
}

/// The podium in front of the dais: wooden, in front of whoever is speaking.
class Podium extends PositionComponent {
  Podium() : super(priority: 6);

  @override
  void render(Canvas canvas) {
    const x = HallBackdrop.podiumX;
    final wood = Color.lerp(KathaInk.marigoldShade, KathaInk.ink, 0.25)!;
    canvas.drawPath(
      Path()
        ..moveTo(x - 24, 178)
        ..lineTo(x + 24, 178)
        ..lineTo(x + 20, 232)
        ..lineTo(x - 20, 232)
        ..close(),
      fillOf(wood),
    );
    canvas.drawRect(
      const Rect.fromLTRB(x - 28, 172, x + 28, 180),
      fillOf(Color.lerp(wood, KathaInk.paper, 0.2)!),
    );
    canvas.drawLine(
      const Offset(x + 6, 172),
      const Offset(x + 14, 150),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1.6,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(x + 15, 148), width: 6, height: 9),
      fillOf(KathaInk.ink),
    );
  }
}
