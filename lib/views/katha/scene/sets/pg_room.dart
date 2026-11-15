import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// The bed, behind whoever is on it: headboard, frame, mattress, pillow.
/// [left] is the headboard's x; the bed runs 190 to the right of it.
class BedBack extends PositionComponent {
  BedBack({required double left})
    : super(position: Vector2(left, 0), priority: -1);

  static const span = 190.0;
  static const mattressTop = 182.0;

  /// The bed sits this much lower than its drawing: knee height.
  static const drop = 12.0;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(0, drop);
    final wood = fillOf(Color.lerp(KathaInk.brickShade, KathaInk.ink, 0.2)!);
    // Headboard, with a carved scallop.
    canvas.drawRRect(
      RRect.fromLTRBR(-4, 136, 14, 222, const Radius.circular(3)),
      wood,
    );
    canvas.drawCircle(const Offset(5, 136), 9, wood);
    // Foot rail and legs.
    canvas.drawRect(const Rect.fromLTRB(span - 8, 168, span + 2, 222), wood);
    canvas.drawRect(const Rect.fromLTRB(10, 204, span - 6, 212), wood);
    // Mattress, a thin cotton one with a stripe.
    canvas.drawRRect(
      RRect.fromLTRBR(10, mattressTop, span - 4, 206, const Radius.circular(4)),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.12)!),
    );
    final stripe = fillOf(KathaInk.teal.withValues(alpha: 0.25));
    for (var x = 18.0; x < span - 10; x += 14) {
      canvas.drawRect(Rect.fromLTRB(x, mattressTop + 3, x + 4, 205), stripe);
    }
    // Pillow, a bit flat.
    canvas.drawRRect(
      RRect.fromLTRBR(16, 170, 58, 188, const Radius.circular(8)),
      fillOf(KathaInk.paper),
    );
    canvas.drawLine(
      const Offset(22, 179),
      const Offset(52, 180),
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.12)
        ..strokeWidth = 1,
    );
    canvas.restore();
  }
}

/// A checked quilt over whoever is lying in the bed, the lump of a body
/// under it. Drawn in front of the sleeper.
class Blanket extends PositionComponent {
  Blanket({required double left})
    : super(position: Vector2(left, 0), priority: 4);

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(0, BedBack.drop);
    final quilt = Path()
      ..moveTo(58, 206)
      ..lineTo(58, 166)
      ..quadraticBezierTo(72, 150, 108, 156)
      ..quadraticBezierTo(150, 162, 176, 162)
      ..quadraticBezierTo(190, 170, 188, 206)
      ..close();
    canvas.drawPath(quilt, fillOf(KathaInk.marigold));
    canvas.save();
    canvas.clipPath(quilt);
    final check = fillOf(KathaInk.marigoldShade.withValues(alpha: 0.5));
    for (var x = 50.0; x < 190; x += 12) {
      canvas.drawRect(Rect.fromLTRB(x, 150, x + 4, 210), check);
    }
    for (var y = 160.0; y < 210; y += 12) {
      canvas.drawRect(Rect.fromLTRB(40, y, 200, y + 4), check);
    }
    canvas.restore();
    // The folded edge at the chest, clear of his chin.
    canvas.drawRRect(
      RRect.fromLTRBR(56, 162, 68, 207, const Radius.circular(4)),
      fillOf(KathaInk.paper),
    );
    canvas.restore();
  }
}

/// The front of the bed, for someone sitting on its edge: mattress side and
/// a fold of quilt, hiding their legs.
class BedFront extends PositionComponent {
  BedFront({required double left, this.legsAt})
    : super(position: Vector2(left, 0), priority: 4);

  /// Where, in world x, the sitter's legs hang over the edge.
  final double? legsAt;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(0, BedBack.drop);
    canvas.drawRRect(
      RRect.fromLTRBR(
        10,
        BedBack.mattressTop + 6,
        BedBack.span - 4,
        214,
        const Radius.circular(4),
      ),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.12)!),
    );
    canvas.drawPath(
      Path()
        ..moveTo(110, 188)
        ..quadraticBezierTo(150, 182, 184, 190)
        ..lineTo(184, 214)
        ..lineTo(118, 214)
        ..close(),
      fillOf(KathaInk.marigold),
    );
    canvas.drawRect(
      const Rect.fromLTRB(10, 210, BedBack.span - 6, 216),
      fillOf(Color.lerp(KathaInk.brickShade, KathaInk.ink, 0.2)!),
    );
    canvas.restore();
    final legs = legsAt;
    if (legs == null) return;
    // Knees at the mattress edge, shins down to the floor, bare feet.
    final x = legs - position.x;
    final denim = fillOf(KathaInk.denim);
    for (final dx in [-9.0, 5.0]) {
      canvas.drawOval(Rect.fromLTRB(x + dx - 8, 192, x + dx + 8, 206), denim);
      canvas.drawRRect(
        RRect.fromLTRBR(
          x + dx - 6,
          199,
          x + dx + 6,
          229,
          const Radius.circular(4),
        ),
        denim,
      );
      canvas.drawOval(
        Rect.fromLTRB(x + dx - 7, 226, x + dx + 9, 233),
        fillOf(KathaInk.skinWarm),
      );
    }
  }
}

/// Night through the room's window: dark sky, the moon, two stars.
class NightWindow extends PositionComponent {
  NightWindow() : super(priority: -9);

  @override
  void render(Canvas canvas) {
    const win = Rect.fromLTRB(21.5, 55.5, 90.5, 122.5);
    canvas.drawRect(win, fillOf(const Color(0xFF1C2A44)));
    canvas.drawCircle(const Offset(66, 76), 9, fillOf(const Color(0xFFFFF2C4)));
    canvas.drawCircle(const Offset(70, 73), 8, fillOf(const Color(0xFF1C2A44)));
    for (final o in const [Offset(34, 68), Offset(48, 96), Offset(80, 104)]) {
      canvas.drawCircle(o, 1, fillOf(const Color(0xFFFFF2C4)));
    }
    final grille = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 1.4;
    for (var x = 28.0; x < 92; x += 9) {
      canvas.drawLine(Offset(x, 54), Offset(x, 124), grille);
    }
  }
}

/// `bg.pg_room`: the room. Red-oxide floor, a steel almirah, a calendar with
/// a god on it, a bare bulb, a bucket and mug, a damp patch the landlady will
/// call "character", and a window with a grille.
class PgRoomBackdrop extends PositionComponent {
  PgRoomBackdrop() : super(priority: -10);

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    _paint(Canvas(recorder));
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    final wall = Color.lerp(KathaInk.paper, KathaInk.marigold, 0.18)!;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, 200),
      Paint()..color = wall,
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 0, kathaWorldWidth, 8),
      Paint()..color = KathaInk.paper,
    );
    // Red-oxide floor, polished in squares.
    final floor = Color.lerp(KathaInk.brick, KathaInk.ink, 0.15)!;
    canvas.drawRect(
      const Rect.fromLTRB(0, 200, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = floor,
    );
    final seam = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var x = 0.0; x < kathaWorldWidth; x += 40) {
      canvas.drawLine(Offset(x, 200), Offset(x - 20, kathaWorldHeight), seam);
    }
    canvas.drawLine(
      const Offset(0, 228),
      const Offset(kathaWorldWidth, 228),
      seam,
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 196, kathaWorldWidth, 202),
      Paint()..color = Color.lerp(wall, KathaInk.ink, 0.15)!,
    );

    // The damp patch, and a crack running from it.
    canvas.drawOval(
      const Rect.fromLTRB(250, 22, 312, 60),
      Paint()..color = KathaInk.ink.withValues(alpha: 0.06),
    );
    canvas.drawPath(
      Path()
        ..moveTo(296, 56)
        ..lineTo(300, 70)
        ..lineTo(296, 82)
        ..lineTo(302, 96),
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.3)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );

    // Window with a grille, sky beyond, a curtain on a string.
    canvas.drawRect(
      const Rect.fromLTRB(20, 54, 92, 124),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.teal, 0.3)!,
    );
    final grille = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 1.4;
    for (var x = 28.0; x < 92; x += 9) {
      canvas.drawLine(Offset(x, 54), Offset(x, 124), grille);
    }
    canvas.drawRect(
      const Rect.fromLTRB(20, 54, 92, 124),
      Paint()
        ..color = KathaInk.brickShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      const Offset(14, 50),
      const Offset(98, 50),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1,
    );
    canvas.drawPath(
      Path()
        ..moveTo(14, 50)
        ..lineTo(40, 50)
        ..quadraticBezierTo(36, 90, 42, 128)
        ..lineTo(14, 128)
        ..close(),
      Paint()..color = KathaInk.leaf,
    );

    // Calendar with a god on it: a halo, a garland, the month below.
    canvas.drawRect(
      const Rect.fromLTRB(176, 58, 208, 104),
      Paint()..color = KathaInk.paper,
    );
    canvas.drawCircle(
      const Offset(192, 72),
      10,
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.6),
    );
    canvas.drawCircle(const Offset(192, 72), 5, Paint()..color = KathaInk.teal);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 5; c++) {
        canvas.drawRect(
          Rect.fromLTWH(179 + c * 5.6, 88 + r * 4.6, 3, 2.4),
          Paint()..color = KathaInk.ink.withValues(alpha: 0.4),
        );
      }
    }
    canvas.drawLine(
      const Offset(192, 58),
      const Offset(192, 50),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 0.8,
    );

    // Switchboard with a plug hanging out of it.
    canvas.drawRect(
      const Rect.fromLTRB(140, 112, 164, 128),
      Paint()..color = KathaInk.paper,
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(143 + i * 7.0, 115, 4, 5),
        Paint()..color = KathaInk.ink.withValues(alpha: 0.6),
      );
    }

    // Steel almirah, one door not quite shut.
    final steel = Color.lerp(KathaInk.paper, KathaInk.ink, 0.32)!;
    canvas.drawRect(
      const Rect.fromLTRB(326, 86, 386, 200),
      Paint()..color = steel,
    );
    canvas.drawLine(
      const Offset(356, 86),
      const Offset(356, 200),
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.4)
        ..strokeWidth = 1.2,
    );
    canvas.drawRect(
      const Rect.fromLTRB(358, 132, 361, 148),
      Paint()..color = KathaInk.ink,
    );
    canvas.drawRect(
      const Rect.fromLTRB(351, 132, 354, 148),
      Paint()..color = KathaInk.ink,
    );
    canvas.drawPath(
      Path()
        ..moveTo(356, 88)
        ..lineTo(362, 90)
        ..lineTo(362, 198)
        ..lineTo(356, 200)
        ..close(),
      Paint()..color = Color.lerp(steel, KathaInk.ink, 0.2)!,
    );

    // Bucket and mug, ready for the morning water.
    canvas.drawPath(
      Path()
        ..moveTo(292, 206)
        ..lineTo(318, 206)
        ..lineTo(314, 230)
        ..lineTo(296, 230)
        ..close(),
      Paint()..color = KathaInk.teal,
    );
    canvas.drawArc(
      const Rect.fromLTRB(294, 196, 316, 214),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRect(
      const Rect.fromLTRB(320, 220, 330, 230),
      Paint()..color = KathaInk.marigold,
    );

    // A bare bulb on its flex.
    canvas.drawLine(
      const Offset(120, 8),
      const Offset(120, 34),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 0.8,
    );
    canvas.drawCircle(
      const Offset(120, 38),
      4,
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.85),
    );
  }
}

/// The ceiling fan. Asked to spin, it wobbles round slowly, ticking, and
/// then gives up.
class CeilingFan extends KathaActor {
  CeilingFan({required super.actorId})
    : super(linkColor: KathaInk.teal, position: Vector2(214, 8), priority: 2);

  double _spinLeft = 0;
  double _spinFor = 0;
  double _angle = 0.4;
  double _clock = 0;

  @override
  Offset get glowCentre => const Offset(0, 24);

  @override
  double get glowRadius => 40;

  @override
  Vector2 get bubbleAnchor => Vector2(0, 40);

  @override
  double perform(String anim, double seconds) {
    switch (anim) {
      case 'tap_glow':
        glow();
        return 0.9;
      case 'spin':
        if (game.reducedMotion) {
          _angle += 1;
          return 0.05;
        }
        _spinFor = math.max(3.2, seconds);
        _spinLeft = _spinFor;
        return _spinFor + 0.1;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_spinLeft <= 0) return;
    _spinLeft -= dt;
    _clock += dt;
    // Spins up a little, then winds down to a stop.
    final progress = 1 - _spinLeft / _spinFor;
    final speed = math.sin(progress * math.pi) * 3.2;
    _angle += speed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final wobble = _spinLeft > 0 ? math.sin(_clock * 9) * 0.06 : 0.0;
    canvas.save();
    canvas.rotate(wobble);
    canvas.drawRect(
      const Rect.fromLTRB(-1.4, 0, 1.4, 16),
      Paint()..color = KathaInk.ink,
    );
    final blade = Paint()
      ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.42)!;
    // Three blades seen from slightly below: a squashed circle of travel.
    for (var i = 0; i < 3; i++) {
      final a = _angle + i * 2 * math.pi / 3;
      final tip = Offset(math.cos(a) * 46, 22 + math.sin(a) * 6);
      final side = Offset(-math.sin(a) * 4, math.cos(a) * 1.2);
      canvas.drawPath(
        Path()
          ..moveTo(0, 22)
          ..lineTo(tip.dx + side.dx, tip.dy + side.dy)
          ..lineTo(tip.dx - side.dx, tip.dy - side.dy)
          ..close(),
        blade,
      );
    }
    canvas.drawOval(
      const Rect.fromLTRB(-9, 15, 9, 27),
      Paint()..color = KathaInk.teal,
    );
    canvas.restore();
  }
}
