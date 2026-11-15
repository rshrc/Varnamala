import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// Rain, falling across the whole picture. Starts at full strength, or -
/// for `prop.rain_coming` - clear, until cues darken the sky and start it.
class RainOverlay extends KathaActor {
  RainOverlay({required super.actorId, bool falling = true})
    : _rain = falling ? 1 : 0,
      _dark = falling ? 1 : 0,
      super(linkColor: KathaInk.teal, position: Vector2.zero(), priority: 80);

  double _rain;
  double _dark;
  // Targets start where the rain starts. Set here rather than on mount: a
  // cue on a scene's first beat can arrive before the overlay is mounted.
  late double _rainTarget = _rain;
  late double _darkTarget = _dark;

  late final Picture _streaks = recordPicture((canvas) {
    final random = math.Random(11);
    final streak = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 170; i++) {
      final x = random.nextDouble() * (kathaWorldWidth + 60) - 30;
      final y = random.nextDouble() * kathaWorldHeight;
      final len = 6 + random.nextDouble() * 8;
      canvas.drawLine(Offset(x, y), Offset(x - len * 0.35, y + len), streak);
    }
  });

  @override
  Offset get glowCentre => const Offset(200, 130);

  @override
  double get glowRadius => 0;

  @override
  Vector2 get bubbleAnchor => Vector2(200, 40);

  @override
  double perform(String anim, double seconds) {
    switch (anim) {
      case 'darken':
        _darkTarget = 1;
        if (game.reducedMotion) _dark = 1;
        return seconds + 0.1;
      case 'start':
        _rainTarget = 1;
        _darkTarget = 1;
        if (game.reducedMotion) _rain = _dark = 1;
        return seconds + 0.1;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _rain = _approach(_rain, _rainTarget, dt);
    _dark = _approach(_dark, _darkTarget, dt);
  }

  static double _approach(double value, double target, double dt) =>
      value < target ? math.min(target, value + dt) : value;

  @override
  void render(Canvas canvas) {
    if (_dark > 0) {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
        Paint()
          ..color = Color.lerp(
            KathaInk.ink,
            KathaInk.teal,
            0.4,
          )!.withValues(alpha: 0.28 * _dark),
      );
    }
    if (_rain > 0) {
      canvas.saveLayer(
        const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
        Paint()..color = Color.fromRGBO(0, 0, 0, _rain),
      );
      canvas.drawPicture(_streaks);
      canvas.restore();
    }
  }
}

/// Floodwater over the road: a still sheet with ripples, that can rise.
class FloodWater extends KathaActor {
  FloodWater({required super.actorId, double level = 30, this.rises = false})
    : _level = rises ? 0 : level,
      _target = level,
      super(linkColor: KathaInk.teal, position: Vector2.zero(), priority: 70);

  double _level;
  final double _target;
  final bool rises;
  bool _rising = false;

  @override
  Offset get glowCentre => const Offset(200, 240);

  @override
  double get glowRadius => 0;

  @override
  Vector2 get bubbleAnchor => Vector2(200, 200);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'rise') return 0;
    if (game.reducedMotion) {
      _level = 48;
      return 0.05;
    }
    _rising = true;
    return seconds + 0.1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_rising) {
      _level = math.min(48, _level + dt * 22);
      if (_level >= 48) _rising = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final level = rises ? _level : _target;
    if (level <= 0) return;
    final top = kathaWorldHeight - level;
    canvas.drawRect(
      Rect.fromLTRB(0, top, kathaWorldWidth, kathaWorldHeight),
      Paint()
        ..color = Color.lerp(
          KathaInk.teal,
          KathaInk.khakiShade,
          0.35,
        )!.withValues(alpha: 0.82),
    );
    final ripple = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 9; i++) {
      final x = 20 + i * 44.0;
      final y = top + 6 + (i % 3) * 8.0;
      canvas.drawLine(Offset(x, y), Offset(x + 16, y), ripple);
    }
  }
}
