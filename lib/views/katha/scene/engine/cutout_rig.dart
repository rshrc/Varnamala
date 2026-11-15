import 'dart:async' as async;
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/moves.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// A cut-out character: legs, a torso carrying the head and both arms, and a
/// face. Every character is built from these same parts, so the move library
/// in `moves.dart` works on all of them.
class CutoutRig extends KathaActor {
  CutoutRig({
    required super.actorId,
    required super.linkColor,
    required super.position,
    required this.torso,
    required this.head,
    required this.face,
    required this.leftArm,
    required this.rightArm,
    required this.gestureArm,
    required this.headRadius,
    this.legs,
    super.priority,
  });

  final RigPart? legs;
  final RigPart torso;
  final RigPart head;
  final Face face;
  final Limb leftArm;
  final Limb rightArm;

  /// The arm that waves and holds up a price: the one toward the other person.
  final Limb gestureArm;
  final double headRadius;

  late final Vector2 restPosition;
  async.Timer? _blinkTimer;

  /// Seconds left of a tea stream between the two hands, for `pour`.
  double pouring = 0;
  final _random = math.Random();

  @override
  Offset get glowCentre => Offset(head.position.x, head.position.y + 34);

  @override
  double get glowRadius => 64;

  @override
  Vector2 get bubbleAnchor => head.position + Vector2(0, -headRadius - 3);

  @override
  Future<void> onLoad() async {
    restPosition = position.clone();
    if (legs != null) add(legs!);
    head.add(face);
    torso.addAll([head, leftArm, rightArm]);
    add(torso);
  }

  @override
  void onMount() {
    super.onMount();
    _scheduleBlink();
  }

  @override
  void onRemove() {
    _blinkTimer?.cancel();
    super.onRemove();
  }

  /// Idle life: a blink every four to seven seconds, each one a single frame
  /// pair rather than a running loop. None under reduced motion.
  void _scheduleBlink() {
    _blinkTimer?.cancel();
    if (game.reducedMotion || game.closed) return;
    final wait = 4000 + _random.nextInt(3000);
    _blinkTimer = async.Timer(Duration(milliseconds: wait), () {
      if (!isMounted) return;
      face.blink();
      _scheduleBlink();
    });
  }

  /// Every part back to rest, ready for the next move.
  void settle() {
    for (final effect in children.whereType<Effect>().toList()) {
      effect.removeFromParent();
    }
    position.setFrom(restPosition);
    torso.settle();
    head.settle();
    leftArm.settle();
    rightArm.settle();
  }

  @override
  double perform(String anim, double seconds) =>
      performMove(this, anim, seconds, reducedMotion: game.reducedMotion);

  @override
  void update(double dt) {
    super.update(dt);
    if (pouring > 0) pouring -= dt;
  }

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    if (pouring <= 0.3) return;
    // The tea stream, from the raised hand down to the low one, drawn in the
    // rig's own coordinates over everything else.
    canvas.save();
    // A rig is only ever moved, never turned or scaled.
    canvas.translate(position.x, position.y);
    final from = _handOf(gestureArm);
    final to = _handOf(gestureArm == leftArm ? rightArm : leftArm);
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = KathaInk.khakiShade
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  /// Where [arm]'s hand is, in this rig's coordinates.
  Offset _handOf(Limb arm) {
    final shoulder = torso.position + arm.position;
    final a = arm.angle;
    final elbow = shoulder + Vector2(-math.sin(a), math.cos(a)) * arm.upper;
    final b = a + arm.bend;
    final hand = elbow + Vector2(-math.sin(b), math.cos(b)) * arm.fore;
    return Offset(hand.x, hand.y);
  }
}
