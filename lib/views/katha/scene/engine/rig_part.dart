import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// A cut-out piece of a character - torso, head, arm - drawn in code.
///
/// Remembers where it rests, so a move interrupted by the next one can snap
/// back instead of leaving an arm stuck halfway up.
class RigPart extends PositionComponent {
  RigPart({
    required this.draw,
    super.position,
    this.restAngle = 0,
    super.priority,
  }) : super(angle: restAngle) {
    restPosition = position.clone();
  }

  final void Function(Canvas canvas, RigPart part) draw;
  final double restAngle;
  late final Vector2 restPosition;

  /// Cancels any move in progress and returns to rest.
  void settle() {
    for (final effect in children.whereType<Effect>().toList()) {
      effect.removeFromParent();
    }
    position.setFrom(restPosition);
    angle = restAngle;
  }

  @override
  void render(Canvas canvas) => draw(canvas, this);
}
