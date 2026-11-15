import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/animation.dart';
import 'package:words625/views/katha/scene/katha_panel_game.dart';

/// Anything in a panel that a cue can act on: a character or a prop.
abstract class KathaActor extends PositionComponent
    with HasGameReference<KathaPanelGame> {
  KathaActor({
    required this.actorId,
    required this.linkColor,
    super.position,
    super.priority,
  });

  /// The id the scene file uses for it: `dev`, `raju`, `meter`.
  final String actorId;

  /// The colour that ties a word to this object: its underline in the text,
  /// and its glow in the picture.
  final Color linkColor;

  /// Centre and radius of the glow, in local coordinates.
  Offset get glowCentre;
  double get glowRadius;

  /// Where a speech bubble's tail points, in local coordinates.
  Vector2 get bubbleAnchor;

  double _glow = 0;
  static const _glowSeconds = 0.9;

  /// Lights the object up for a moment - the word that names it was spoken or
  /// tapped.
  void glow() {
    _glow = 1;
    game.wake(_glowSeconds);
  }

  /// Plays [anim] and returns how long, in seconds, the scene stays in motion.
  double perform(String anim, double seconds);

  @override
  void update(double dt) {
    super.update(dt);
    if (_glow > 0) _glow = math.max(0, _glow - dt / _glowSeconds);
  }

  @override
  void render(Canvas canvas) {
    if (_glow <= 0) return;
    final strength = Curves.easeOutQuad.transform(_glow);
    canvas.drawCircle(
      glowCentre,
      glowRadius,
      Paint()
        ..shader = Gradient.radial(glowCentre, glowRadius, [
          linkColor.withValues(alpha: 0.42 * strength),
          linkColor.withValues(alpha: 0),
        ]),
    );
  }
}
