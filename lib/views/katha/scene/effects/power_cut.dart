import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// The lights go: a flicker, then dark. `cut` and `restore`.
class PowerCut extends KathaActor {
  PowerCut({required super.actorId, this.dark = 0.6})
    : super(
        linkColor: KathaInk.marigold,
        position: Vector2.zero(),
        priority: 8,
      );

  final double dark;
  double _level = 0;
  double _target = 0;
  double _clock = 0;
  bool _flickering = false;

  @override
  Offset get glowCentre => const Offset(200, 40);
  @override
  double get glowRadius => 40;
  @override
  Vector2 get bubbleAnchor => Vector2(200, 40);

  @override
  double perform(String anim, double seconds) {
    if (anim == 'cut') {
      _target = dark;
      _flickering = !game.reducedMotion;
      _clock = 0;
      if (game.reducedMotion) _level = dark;
      return 0.9;
    }
    if (anim == 'restore') {
      _target = 0;
      if (game.reducedMotion) _level = 0;
      return 0.6;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_flickering && _clock < 0.5) {
      // On, off, on, off: the bulb gives up.
      _level = (_clock * 8).floor().isEven ? dark : dark * 0.25;
      return;
    }
    _flickering = false;
    _level += (_target - _level) * math.min(1, dt * 8);
  }

  @override
  void render(Canvas canvas) {
    if (_level <= 0.01) return;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      fillOf(const Color(0xFF0B1A2E).withValues(alpha: _level)),
    );
  }
}

/// A candle on a steel saucer. Unlit until `light`; then it flickers, and
/// its glow cuts through the power cut drawn beneath it.
class Candle extends KathaActor {
  Candle({required super.actorId, required Vector2 at, this.lit = false})
    : super(linkColor: KathaInk.marigold, position: at, priority: 9);

  bool lit;
  double _clock = 0;

  @override
  Offset get glowCentre => const Offset(0, -16);
  @override
  double get glowRadius => 20;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -26);

  @override
  double perform(String anim, double seconds) {
    if (anim == 'light') lit = true;
    if (anim == 'out') lit = false;
    return 3;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (lit) game.wake(0.2);
  }

  @override
  void render(Canvas canvas) {
    if (lit) {
      final flicker =
          1 + math.sin(_clock * 13) * 0.05 + math.sin(_clock * 31) * 0.03;
      final r = 110 * flicker;
      canvas.drawCircle(
        const Offset(0, -16),
        r,
        Paint()
          ..shader = Gradient.radial(
            const Offset(0, -16),
            r,
            [
              const Color(0xFFFFD27A).withValues(alpha: 0.42),
              const Color(0xFFFFB347).withValues(alpha: 0.12),
              const Color(0xFFFFB347).withValues(alpha: 0),
            ],
            [0, 0.5, 1],
          ),
      );
    }
    super.render(canvas);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: 18, height: 5),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.25)!),
    );
    canvas.drawRect(const Rect.fromLTRB(-3, -14, 3, 0), fillOf(KathaInk.paper));
    canvas.drawLine(
      const Offset(0, -14),
      const Offset(0, -16.5),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 0.8,
    );
    if (!lit) return;
    final sway = math.sin(_clock * 9) * 0.8;
    final flame = Path()
      ..moveTo(0, -16)
      ..quadraticBezierTo(-3.4, -20, sway, -27)
      ..quadraticBezierTo(3.4, -20, 0, -16);
    canvas.drawPath(flame, fillOf(const Color(0xFFFFB347)));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(sway * 0.4, -19.5), width: 2.6, height: 4),
      fillOf(const Color(0xFFFFF4C8)),
    );
  }
}
