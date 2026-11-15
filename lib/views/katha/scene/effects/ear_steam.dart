import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// Cartoon steam, from the ears of someone who just ate a green chilli.
class EarSteam extends PositionComponent {
  EarSteam({required Vector2 at, this.seconds = 2.2})
    : super(position: at, priority: 9);

  final double seconds;
  double _clock = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_clock > seconds) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    for (final side in [-1.0, 1.0]) {
      for (var i = 0; i < 3; i++) {
        final phase = ((_clock * 2.2) - i * 0.3) % 1.0;
        if (phase < 0) continue;
        canvas.drawCircle(
          Offset(side * (16 + phase * 10), -phase * 16 + i),
          2 + phase * 3.4,
          fillOf(
            Color.lerp(
              KathaInk.paper,
              KathaInk.ink,
              0.25,
            )!.withValues(alpha: 0.9 * (1 - phase)),
          ),
        );
      }
    }
  }
}
