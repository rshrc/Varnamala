import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/idle_bit.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// The auto-rickshaw, in two layers so the driver can sit *inside* it: the
/// canopy and cabin behind him, the body and wheels in front.
///
/// Authored with the driver's seat at x = 260; [dx] shifts the whole vehicle.
class AutoRickshawBack extends PositionComponent {
  AutoRickshawBack({required double dx})
    : super(position: Vector2(dx, 0), priority: 0);

  @override
  void render(Canvas canvas) {
    final canopy = Path()
      ..moveTo(218, 200)
      ..lineTo(225, 146)
      ..quadraticBezierTo(229, 128, 246, 127)
      ..lineTo(332, 127)
      ..quadraticBezierTo(348, 129, 348, 146)
      ..lineTo(348, 200)
      ..close();
    canvas.drawPath(canopy, Paint()..color = KathaInk.ink);
    final interior = Paint()..color = KathaInk.interior;
    canvas.drawRRect(
      RRect.fromLTRBR(244, 139, 292, 202, const Radius.circular(5)),
      interior,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(298, 139, 341, 200, const Radius.circular(5)),
      interior,
    );
    final windshield = Path()
      ..moveTo(222, 198)
      ..lineTo(227, 150)
      ..quadraticBezierTo(230, 140, 240, 139)
      ..lineTo(240, 198)
      ..close();
    canvas.drawPath(windshield, Paint()..color = KathaInk.windshield);
  }
}

class AutoRickshawFront extends PositionComponent {
  AutoRickshawFront({required double dx})
    : super(position: Vector2(dx, 0), priority: 2);

  @override
  void render(Canvas canvas) {
    final ink = Paint()..color = KathaInk.ink;
    final paper = Paint()..color = KathaInk.paper;

    // Handlebar, in front of the driver's hands.
    canvas.drawLine(
      const Offset(231, 182),
      const Offset(244, 190),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    final body = Path()
      ..moveTo(214, 237)
      ..lineTo(208, 214)
      ..quadraticBezierTo(208, 201, 221, 200)
      ..lineTo(348, 200)
      ..lineTo(350, 237)
      ..close();
    canvas.drawPath(body, Paint()..color = KathaInk.marigold);
    canvas.drawRect(
      const Rect.fromLTRB(211, 226, 350, 231),
      Paint()..color = KathaInk.marigoldShade,
    );

    // Wheels, each with a mudguard over the top.
    for (final (x, r) in [(224.0, 10.5), (314.0, 11.5)]) {
      canvas.drawCircle(Offset(x, 243), r, ink);
      canvas.drawCircle(Offset(x, 243), r * 0.32, paper);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x, 243), radius: r + 3),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = KathaInk.marigoldShade
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke,
      );
    }

    // A heart sticker on the body, and a marigold garland along the nose.
    canvas.drawPath(
      Path()
        ..moveTo(332, 219)
        ..cubicTo(326, 213, 329, 208, 332, 212)
        ..cubicTo(335, 208, 338, 213, 332, 219)
        ..close(),
      Paint()..color = KathaInk.brick,
    );
    for (var i = 0; i < 7; i++) {
      final u = i / 6;
      canvas.drawCircle(
        Offset(210 + u * 14, 203 + math.sin(u * math.pi) * 3.4),
        1.7,
        Paint()..color = i.isEven ? KathaInk.brick : KathaInk.paper,
      );
    }
    canvas.drawCircle(const Offset(212, 210), 4.6, paper);
    canvas.drawCircle(
      const Offset(212, 210),
      4.6,
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );
  }
}

/// `prop.auto_meter`: the fare meter on its stalk beside the windscreen.
/// Its window shows dashes until Raju admits it is broken, and a cross from
/// then on - "broken" needs no words.
class AutoMeter extends KathaActor {
  AutoMeter({required super.actorId, required super.position})
    : super(linkColor: KathaInk.marigold, priority: 3);

  bool broken = false;

  @override
  Offset get glowCentre => const Offset(14, 9);

  @override
  double get glowRadius => 26;

  @override
  Vector2 get bubbleAnchor => Vector2(14, -2);

  @override
  double perform(String anim, double seconds) {
    switch (anim) {
      case 'tap_glow':
        glow();
        return 0.9;
      case 'show_broken':
        broken = true;
        glow();
        return 0.9;
    }
    return 0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final ink = Paint()..color = KathaInk.ink;
    canvas.drawLine(
      const Offset(15, 18),
      const Offset(19, 44),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 2.4,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, 28, 18, const Radius.circular(3)),
      ink,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(4, 4, 24, 14, const Radius.circular(2)),
      Paint()..color = KathaInk.paper,
    );
    final mark = Paint()
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    if (broken) {
      mark.color = KathaInk.brick;
      canvas.drawLine(const Offset(10.5, 5.8), const Offset(17.5, 12.2), mark);
      canvas.drawLine(const Offset(17.5, 5.8), const Offset(10.5, 12.2), mark);
    } else {
      mark.color = KathaInk.teal;
      canvas.drawLine(const Offset(8, 9), const Offset(12, 9), mark);
      canvas.drawLine(const Offset(16, 9), const Offset(20, 9), mark);
    }
  }
}

/// The lemon-and-chillies charm every auto hangs up front, swinging a little
/// as if the engine were idling.
class AutoCharm extends IdleBit {
  AutoCharm({required double dx})
    : super(
        seconds: 1.5,
        chance: 0.7,
        position: Vector2(208.5 + dx, 219),
        priority: 3,
      );

  static final _lemon = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.45)!;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(math.sin(t * math.pi * 4) * 0.4 * (1 - t));
    canvas.drawLine(
      Offset.zero,
      const Offset(0, 5),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 0.8,
    );
    canvas.drawCircle(const Offset(0, 7.6), 2.9, Paint()..color = _lemon);
    final chilli = Paint()
      ..color = KathaInk.leaf
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (final x in [-2.4, 0.0, 2.4]) {
      canvas.drawLine(Offset(x * 0.5, 10.4), Offset(x, 15.5), chilli);
    }
    canvas.restore();
  }
}
