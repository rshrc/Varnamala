import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// Amma's steel tiffin, held out in her hand. Shut until `open`; then the lid
/// comes off, steam rises, and the smell goes looking for the landlady.
class AmmaTiffin extends KathaActor {
  AmmaTiffin({required super.actorId, required this.holder})
    : super(linkColor: KathaInk.brick, position: Vector2.zero(), priority: 6);

  final CutoutRig holder;
  double _open = -1;
  double _clock = 0;

  Vector2 get _hand {
    final arm = holder.gestureArm;
    return arm.absolutePositionOf(
      Vector2(0, arm.upper) + (Vector2(0, arm.fore)..rotate(arm.bend)),
    );
  }

  @override
  Offset get glowCentre => _hand.toOffset().translate(0, -8);
  @override
  double get glowRadius => 22;
  @override
  Vector2 get bubbleAnchor => _hand - Vector2(0, 24);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'open') return 0;
    _open = game.reducedMotion ? 1 : 0;
    return math.max(3.5, seconds);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_open >= 0 && _open < 1) _open = math.min(1, _open + dt / 0.5);
  }

  @override
  void render(Canvas canvas) {
    final at = _hand.toOffset();
    final steel = Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!;
    final dark = Color.lerp(steel, KathaInk.ink, 0.2)!;
    // Two tiers and the carrying frame, hanging under the hand.
    for (var i = 0; i < 2; i++) {
      final top = at.dy + 6 + i * 9.0;
      canvas.drawRRect(
        RRect.fromLTRBR(
          at.dx - 10,
          top,
          at.dx + 10,
          top + 8,
          const Radius.circular(2),
        ),
        fillOf(steel),
      );
      canvas.drawRect(
        Rect.fromLTRB(at.dx - 10, top + 6, at.dx + 10, top + 8),
        fillOf(dark),
      );
    }
    canvas.drawLine(
      at.translate(-11, 2),
      at.translate(-11, 22),
      Paint()
        ..color = dark
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      at.translate(11, 2),
      at.translate(11, 22),
      Paint()
        ..color = dark
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      at.translate(-11, 2),
      at.translate(11, 2),
      Paint()
        ..color = dark
        ..strokeWidth = 1.4,
    );
    if (_open < 0) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          at.dx - 10,
          at.dy + 2,
          at.dx + 10,
          at.dy + 6,
          const Radius.circular(2),
        ),
        fillOf(steel),
      );
      return;
    }
    // The lid, lifted off and tipped back.
    canvas.save();
    canvas.translate(at.dx + 10, at.dy + 4);
    canvas.rotate(-0.9 * _open);
    canvas.drawRRect(
      RRect.fromLTRBR(
        -20,
        -4 - 6 * _open,
        0,
        0 - 6 * _open,
        const Radius.circular(2),
      ),
      fillOf(steel),
    );
    canvas.restore();
    // The curry: a rich red-brown, glistening.
    canvas.drawOval(
      Rect.fromLTRB(at.dx - 9, at.dy + 4, at.dx + 9, at.dy + 9),
      fillOf(Color.lerp(KathaInk.brick, KathaInk.marigold, 0.25)!),
    );
    canvas.drawCircle(
      at.translate(-3, 6),
      1.2,
      fillOf(KathaInk.paper.withValues(alpha: 0.7)),
    );
    // Steam, and the smell: three wavy ribbons drifting off to the right.
    for (var i = 0; i < 3; i++) {
      final path = Path()..moveTo(at.dx - 4 + i * 4.0, at.dy + 2);
      for (var k = 1; k <= 12; k++) {
        final y = at.dy + 2 - k * 4.0 * _open;
        final x =
            at.dx -
            4 +
            i * 4.0 +
            k * 3.2 * _open +
            math.sin(_clock * 4 + k * 0.8 + i) * 2.4;
        path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = KathaInk.paper.withValues(alpha: 0.75 * _open)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
