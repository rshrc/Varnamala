import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// Chalk on the road: a crease at each end, so it is a pitch and not a lane.
class ChalkPitch extends PositionComponent {
  ChalkPitch() : super(priority: -4);

  @override
  void render(Canvas canvas) {
    final chalk = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(236, 210), const Offset(292, 210), chalk);
    canvas.drawLine(const Offset(240, 210), const Offset(232, 226), chalk);
    canvas.drawLine(const Offset(80, 210), const Offset(132, 210), chalk);
    canvas.drawLine(
      const Offset(250, 226),
      const Offset(246, 236),
      chalk..color = chalk.color.withValues(alpha: 0.4),
    );
  }
}

/// `bg.cricket_lane`: the lane behind the houses where Sunday cricket
/// happens. Bright house fronts, a balcony with plants, a bicycle against a
/// wall, cables overhead, a mango tree hanging over the end.
class CricketLaneBackdrop extends PositionComponent {
  CricketLaneBackdrop() : super(priority: -10);

  late final Picture _picture = recordPicture(_paint);

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = KathaInk.paper,
    );
    final houses = [
      (0.0, 92.0, 70.0, Color.lerp(KathaInk.paper, KathaInk.teal, 0.4)!),
      (92.0, 108.0, 54.0, Color.lerp(KathaInk.paper, KathaInk.marigold, 0.55)!),
      (200.0, 116.0, 76.0, Color.lerp(KathaInk.paper, KathaInk.brick, 0.35)!),
      (316.0, 84.0, 60.0, Color.lerp(KathaInk.paper, KathaInk.leaf, 0.4)!),
    ];
    for (final (x, w, top, color) in houses) {
      canvas.drawRect(
        Rect.fromLTRB(x, top, x + w, 198),
        Paint()..color = color,
      );
      canvas.drawRect(
        Rect.fromLTRB(x - 2, top - 4, x + w + 2, top + 2),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8),
      );
      // A window with a grille on each, and a door.
      canvas.drawRect(
        Rect.fromLTWH(x + 12, top + 20, 24, 22),
        Paint()..color = KathaInk.interior,
      );
      for (var gx = x + 16; gx < x + 36; gx += 5) {
        canvas.drawLine(
          Offset(gx, top + 20),
          Offset(gx, top + 42),
          Paint()
            ..color = KathaInk.ink
            ..strokeWidth = 0.9,
        );
      }
      canvas.drawRect(
        Rect.fromLTWH(x + w - 34, 150, 22, 48),
        Paint()..color = KathaInk.brickShade,
      );
    }
    // Balcony with potted plants.
    canvas.drawRect(
      const Rect.fromLTRB(150, 100, 196, 104),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    for (final x in [154.0, 168.0, 182.0]) {
      canvas.drawRect(
        Rect.fromLTWH(x, 92, 8, 8),
        Paint()..color = KathaInk.brick,
      );
      canvas.drawCircle(Offset(x + 4, 89), 5, Paint()..color = KathaInk.leaf);
    }
    // Water tank on a roof, cables across.
    canvas.drawRRect(
      RRect.fromLTRBR(222, 52, 244, 76, const Radius.circular(3)),
      Paint()..color = KathaInk.ink.withValues(alpha: 0.7),
    );
    final cable = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.3)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(0, 40)
        ..quadraticBezierTo(200, 70, 400, 34),
      cable,
    );
    // A mango tree leaning over the far end.
    final leaf = Paint()..color = KathaInk.leaf;
    for (final (x, y, r) in [
      (372.0, 30.0, 30.0),
      (400.0, 52.0, 26.0),
      (346.0, 14.0, 20.0),
    ]) {
      canvas.drawCircle(Offset(x, y), r, leaf);
    }
    for (final (x, y) in [(360.0, 40.0), (384.0, 58.0), (392.0, 30.0)]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 6, height: 8),
        Paint()..color = KathaInk.marigold,
      );
    }
    // A bicycle against the last wall.
    final frame = Paint()
      ..color = KathaInk.teal
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(334, 190), 8, frame..color = KathaInk.ink);
    canvas.drawCircle(const Offset(364, 190), 8, frame);
    canvas.drawPath(
      Path()
        ..moveTo(334, 190)
        ..lineTo(346, 176)
        ..lineTo(364, 190)
        ..moveTo(346, 176)
        ..lineTo(360, 176),
      Paint()
        ..color = KathaInk.teal
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
    // The lane: packed earth, a chalked crease.
    canvas.drawRect(
      const Rect.fromLTRB(0, 198, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.khakiShade, 0.45)!,
    );
    canvas.drawLine(
      const Offset(226, 222),
      const Offset(298, 222),
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8)
        ..strokeWidth = 1.4,
    );
  }
}

/// The cricket ball. Unseen until it leaves the bowler's hand; then it pitches
/// once on the road, its shadow racing to meet it, crashes into the stumps
/// and rolls away into the gutter.
class CricketBall extends KathaActor {
  CricketBall({required super.actorId})
    : super(
        linkColor: KathaInk.brick,
        position: Vector2(102, 134),
        priority: 6,
      );

  static const _ground = 216.0;
  bool _shown = false;

  @override
  Offset get glowCentre => Offset.zero;

  @override
  double get glowRadius => 12;

  @override
  Vector2 get bubbleAnchor => Vector2(0, -8);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'bowled') return 0;
    _shown = true;
    for (final effect in children.whereType<Effect>().toList()) {
      effect.removeFromParent();
    }
    position.setValues(102, 134);
    if (game.reducedMotion) {
      position.setValues(296, 212);
      return 0.05;
    }
    add(
      SequenceEffect([
        // Down onto a length: gravity, so it speeds up.
        MoveToEffect(
          Vector2(206, _ground - 2),
          EffectController(duration: 0.34, curve: Curves.easeIn),
        ),
        // Off the road and into the stumps.
        MoveToEffect(
          Vector2(262, 196),
          EffectController(duration: 0.18, curve: Curves.easeOut),
        ),
        // Deflected, a hop, into the gutter.
        MoveToEffect(
          Vector2(282, 200),
          EffectController(duration: 0.16, curve: Curves.easeOut),
        ),
        MoveToEffect(
          Vector2(298, _ground - 3),
          EffectController(duration: 0.22, curve: Curves.easeIn),
        ),
      ]),
    );
    return 1.0;
  }

  @override
  void render(Canvas canvas) {
    if (!_shown) return;
    super.render(canvas);
    // The shadow, flat on the road, sharper as the ball comes down to it.
    final height = (_ground - position.y).clamp(0.0, 90.0);
    final near = 1 - height / 90;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, height + 1),
        width: 6 + 3 * near,
        height: 2 + near,
      ),
      Paint()..color = KathaInk.ink.withValues(alpha: 0.12 + 0.2 * near),
    );
    canvas.drawCircle(Offset.zero, 4.2, Paint()..color = KathaInk.brick);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 2.6),
      -0.4,
      math.pi * 0.8,
      false,
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }
}

/// Three stumps on a brick, bails on top. Bowled: they scatter.
class Wicket extends KathaActor {
  Wicket({required super.actorId})
    : super(
        linkColor: KathaInk.marigold,
        position: Vector2(266, 216),
        priority: 1,
      );

  double _fallen = 0;
  bool _falling = false;

  @override
  Offset get glowCentre => const Offset(0, -16);

  @override
  double get glowRadius => 22;

  @override
  Vector2 get bubbleAnchor => Vector2(0, -36);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'fall') return 0;
    glow();
    if (game.reducedMotion) {
      _fallen = 1;
      return 0.05;
    }
    _falling = true;
    return 0.6;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_falling) {
      _fallen = math.min(1, _fallen + dt * 3.5);
      if (_fallen >= 1) _falling = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      const Rect.fromLTRB(-10, -4, 10, 0),
      Paint()..color = KathaInk.brick,
    );
    final wood = Paint()
      ..color = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.3)!;
    final f = Curves.easeOut.transform(_fallen);
    for (final (i, x) in [(-1, -5.0), (0, 0.0), (1, 5.0)].map((e) => e)) {
      canvas.save();
      canvas.translate(x, -4);
      canvas.rotate(i * 0.9 * f + (i == 0 ? 0.4 * f : 0));
      canvas.drawRect(const Rect.fromLTRB(-1.2, -26, 1.2, 0), wood);
      canvas.restore();
    }
    // The bails fly off.
    final bail = Paint()..color = KathaInk.brickShade;
    canvas.drawRect(
      Rect.fromLTRB(-6 - 14 * f, -31 - 16 * f, 0 - 14 * f, -29 - 16 * f),
      bail,
    );
    canvas.drawRect(
      Rect.fromLTRB(0 + 12 * f, -31 - 20 * f, 6 + 12 * f, -29 - 20 * f),
      bail,
    );
  }
}
