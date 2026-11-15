import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// The alarm clock on the floor. Rings: it shakes, and shows the time.
class AlarmClock extends KathaActor {
  AlarmClock({required super.actorId})
    : super(
        linkColor: KathaInk.brick,
        position: Vector2(262, 212),
        priority: 2,
      );

  double _ringLeft = 0;
  double _clock = 0;

  @override
  Offset get glowCentre => Offset.zero;

  @override
  double get glowRadius => 20;

  @override
  Vector2 get bubbleAnchor => Vector2(0, -16);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'ring') return 0;
    glow();
    if (game.reducedMotion) return 0.9;
    _ringLeft = math.max(1.4, seconds);
    return _ringLeft + 0.1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_ringLeft > 0) {
      _ringLeft -= dt;
      _clock += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final shake = _ringLeft > 0 ? math.sin(_clock * 60) * 0.18 : 0.0;
    canvas.save();
    canvas.rotate(shake);
    final body = Paint()..color = KathaInk.brick;
    canvas.drawCircle(const Offset(-6, -10), 4, body);
    canvas.drawCircle(const Offset(6, -10), 4, body);
    canvas.drawCircle(Offset.zero, 9, body);
    canvas.drawCircle(Offset.zero, 7, Paint()..color = const Color(0xFFFFFFFF));
    final hand = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    // Five past seven.
    canvas.drawLine(Offset.zero, const Offset(-2.6, 3.8), hand);
    canvas.drawLine(Offset.zero, const Offset(2.4, -4.6), hand);
    canvas.drawRect(
      const Rect.fromLTRB(-6, 8, -3, 11),
      Paint()..color = KathaInk.ink,
    );
    canvas.drawRect(
      const Rect.fromLTRB(3, 8, 6, 11),
      Paint()..color = KathaInk.ink,
    );
    canvas.restore();
  }
}
