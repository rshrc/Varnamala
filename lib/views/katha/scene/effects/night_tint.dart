import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// Evening falling over everything, people included, so a night scene does
/// not have daylit characters standing in it.
class NightTint extends PositionComponent {
  NightTint() : super(priority: 90);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      Paint()
        ..color = Color.lerp(
          KathaInk.ink,
          KathaInk.teal,
          0.35,
        )!.withValues(alpha: 0.22),
    );
  }
}
