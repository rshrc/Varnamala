import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// Z, Z, z: rising from a sleeper for a few seconds at a time.
class SleepZs extends KathaActor {
  SleepZs({required super.actorId, required Vector2 at})
    : super(linkColor: KathaInk.teal, position: at, priority: 6);

  double _left = 0;
  double _clock = 0;

  @override
  Offset get glowCentre => const Offset(0, -12);
  @override
  double get glowRadius => 18;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -20);

  @override
  double perform(String anim, double seconds) {
    if (game.reducedMotion) return 0.05;
    _left = math.max(2.6, seconds);
    _clock = 0;
    return _left;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_left > 0) {
      _left -= dt;
      _clock += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_left <= 0) return;
    final stroke = Paint()
      ..color = KathaInk.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final phase = ((_clock * 0.55) - i * 0.33) % 1.0;
      if (phase < 0) continue;
      final size = 4 + i * 1.6 + phase * 2;
      final o = Offset(
        phase * 14 + math.sin(phase * 6 + i) * 2,
        -phase * 26 - i * 2,
      );
      stroke.color = KathaInk.teal.withValues(alpha: (1 - phase) * 0.9);
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - size / 2, o.dy - size / 2)
          ..lineTo(o.dx + size / 2, o.dy - size / 2)
          ..lineTo(o.dx - size / 2, o.dy + size / 2)
          ..lineTo(o.dx + size / 2, o.dy + size / 2),
        stroke,
      );
    }
  }
}

/// One mosquito, buzzing round a head. Slapped at, it gets away; `splat`
/// finally finishes it.
class Mosquito extends KathaActor {
  Mosquito({required super.actorId, required Vector2 home})
    : _home = home.clone(),
      super(linkColor: KathaInk.ink, position: home, priority: 7);

  final Vector2 _home;
  double _buzz = 0;
  double _clock = 0;
  double _squash = 0;
  bool _dead = false;

  @override
  Offset get glowCentre => Offset.zero;
  @override
  double get glowRadius => 16;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -8);

  @override
  double perform(String anim, double seconds) {
    switch (anim) {
      case 'buzz':
        _dead = false;
        _buzz = math.max(2.4, seconds);
        return game.reducedMotion ? 0.05 : _buzz;
      case 'dodge':
        // Gets away: a dart sideways and on buzzing.
        _buzz = math.max(_buzz, 2.2);
        _clock += 0.9;
        return game.reducedMotion ? 0.05 : 2.2;
      case 'splat':
        _dead = true;
        _buzz = 0;
        _squash = 0.6;
        return 0.6;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_buzz > 0) {
      _buzz -= dt;
      _clock += dt;
      position.setValues(
        _home.x + math.sin(_clock * 6.1) * 16 + math.sin(_clock * 17) * 4,
        _home.y + math.cos(_clock * 4.3) * 9 + math.sin(_clock * 23) * 3,
      );
    }
    if (_squash > 0) _squash -= dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_dead) {
      if (_squash <= 0) return;
      // A tiny star where it was.
      final star = Paint()
        ..color = KathaInk.ink.withValues(alpha: _squash / 0.6)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3;
        canvas.drawLine(
          Offset(math.cos(a) * 2, math.sin(a) * 2),
          Offset(math.cos(a) * 6, math.sin(a) * 6),
          star,
        );
      }
      return;
    }
    final flap = math.sin(_clock * 70).abs();
    final wing = fillOf(const Color(0xFFFFFFFF).withValues(alpha: 0.75));
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(-1.6, -3),
        width: 4.2,
        height: 2 + 3 * flap,
      ),
      wing,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(1.6, -3),
        width: 4.2,
        height: 2 + 3 * flap,
      ),
      wing,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 7, height: 2.6),
      fillOf(KathaInk.ink),
    );
    final leg = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 0.6;
    for (final dx in [-2.0, 0.0, 2.0]) {
      canvas.drawLine(Offset(dx, 1), Offset(dx - 1.4, 4.6), leg);
    }
    canvas.drawLine(const Offset(3.4, 0), const Offset(6.4, 1.4), leg);
    if (_buzz > 0) {
      // The whine, drawn.
      final whine = Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(-6, -2), radius: 4),
        math.pi * 0.7,
        math.pi * 0.6,
        false,
        whine,
      );
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(-6, -2), radius: 7),
        math.pi * 0.72,
        math.pi * 0.56,
        false,
        whine,
      );
    }
  }
}
