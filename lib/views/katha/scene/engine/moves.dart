import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/views/katha/scene/effects/ear_steam.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// The shared move library: small named moves written once and used by every
/// character, so a story file says `raju.shrug` and never touches code.
///
/// Each move settles only the parts it uses, so two cues close together - a
/// nod and then a raised hand - overlap instead of cancelling each other.
///
/// The scene file's `ms` is a floor, not a cap: a wave squeezed into 450ms
/// reads as a twitch, so a move takes at least as long as it needs to be seen.
///
/// Returns how long, in seconds, the scene is in motion, which is how long
/// the engine stays awake for it.
double performMove(
  CutoutRig rig,
  String anim,
  double seconds, {
  required bool reducedMotion,
}) {
  final move = _moves[anim];
  if (move == null) {
    logger.w('Katha: no move called "$anim" yet');
    return 0;
  }
  return move(rig, seconds, reducedMotion);
}

typedef _Move = double Function(CutoutRig rig, double seconds, bool reduced);

const Map<String, _Move> _moves = {
  'wave': _wave,
  'nod': _nod,
  'hold_up_fingers': _holdUpFingers,
  'shrug': _shrug,
  'eyes_wide': _eyesWide,
  'laugh': _laugh,
  'sigh_nod': _sighNod,
  'sheepish': _sheepish,
  'hold_up_ten': _holdUpTen,
  'look_over_glasses': _lookOverGlasses,
  'bag_drop': _bagDrop,
  'head_shake': _headShake,
  'smug': _smug,
  'smile': _smile,
  'think': _think,
  'facepalm': _facepalm,
  'approach': _approach,
  'pour': _pour,
  'bowl': _bowl,
  'swing': _swing,
  'eat': _eat,
  'spicy': _spicy,
  'slap': _slap,
  'cheer': _cheer,
  'toss': _toss,
  'sleep': _sleep,
  'wake': _wake,
  'serve': _serve,
  'belly': _belly,
  'yawn': _yawn,
  'clap': _clap,
  'namaste': _namaste,
  'point': _point,
  'type': _type,
  'fume': _fume,
  'giggle': _giggle,
};

/// Names of every move the library knows, for validating scene files.
Iterable<String> get kathaMoveNames => _moves.keys;

EffectController _ease(
  double duration, {
  bool alternate = false,
  int? repeat,
  double delay = 0,
  double atMax = 0,
  Curve curve = Curves.easeInOut,
}) => EffectController(
  duration: duration,
  curve: curve,
  alternate: alternate,
  repeatCount: repeat,
  startDelay: delay,
  atMaxDuration: atMax,
);

void _settleBody(CutoutRig rig) {
  for (final effect in rig.children.whereType<Effect>().toList()) {
    effect.removeFromParent();
  }
  rig.position.setFrom(rig.restPosition);
}

/// Arm up, two shakes, back down.
double _wave(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.gestureArm..settle();
  rig.face.show(FaceExpression.happy, 1.4);
  if (reduced) return 0.05;
  const up = 0.22, shake = 0.14, down = 0.3;
  arm.add(
    SequenceEffect([
      RotateEffect.to(arm.lifted(2.5), _ease(up, curve: Curves.easeOut)),
      RotateEffect.by(
        -arm.outward * 0.45,
        _ease(shake, alternate: true, repeat: 2),
      ),
      RotateEffect.to(arm.restAngle, _ease(down, delay: 0.08)),
    ]),
  );
  return up + shake * 4 + 0.08 + down + 0.05;
}

double _nod(CutoutRig rig, double seconds, bool reduced) {
  final head = rig.head..settle();
  if (reduced) return 0.05;
  head.add(
    MoveByEffect(Vector2(0, 2.6), _ease(0.13, alternate: true, repeat: 2)),
  );
  return 0.13 * 4 + 0.05;
}

/// A hand held up with the fingers spread: a price, a count. The hand stays
/// up long enough to be read, then comes down.
double _holdUpFingers(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.gestureArm..settle();
  final hold = math.max(1.4, seconds);
  arm
    ..fingersShown = true
    ..bend = arm.outward * 0.15;
  if (reduced) {
    arm.angle = arm.lifted(2.2);
    async.Timer(Duration(milliseconds: (hold * 1000).round()), () {
      arm
        ..angle = arm.restAngle
        ..bend = arm.restBend
        ..fingersShown = false;
      if (rig.isMounted) rig.game.wake(0.05);
    });
    return 0.05;
  }
  const up = 0.25, down = 0.3;
  arm.add(
    SequenceEffect(
      [
        RotateEffect.to(arm.lifted(2.2), _ease(up, curve: Curves.easeOut)),
        RotateEffect.to(arm.restAngle, _ease(down, delay: hold)),
      ],
      onComplete: () => arm
        ..fingersShown = false
        ..bend = arm.restBend,
    ),
  );
  return up + hold + down + 0.05;
}

/// Shoulders up, elbows out, head cocked: "what can I do?"
double _shrug(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.shrug, 1.7);
  rig.leftArm.settle();
  rig.rightArm.settle();
  rig.torso.settle();
  rig.head.settle();
  if (reduced) return 0.05;
  const lift = 0.22, hold = 0.45;
  for (final arm in [rig.leftArm, rig.rightArm]) {
    arm.add(
      RotateEffect.by(
        arm.outward * 0.55,
        _ease(lift, alternate: true, atMax: hold, curve: Curves.easeOut),
      ),
    );
  }
  rig.torso.add(
    MoveByEffect(Vector2(0, -2.5), _ease(lift, alternate: true, atMax: hold)),
  );
  rig.head.add(
    RotateEffect.by(
      -0.12 * rig.face.facing,
      _ease(lift, alternate: true, atMax: hold),
    ),
  );
  return lift * 2 + hold + 0.05;
}

/// Eyes wide, a small jump, a hand up in surprise.
double _eyesWide(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.shock, math.max(1.6, seconds));
  _settleBody(rig);
  final arm = rig.gestureArm..settle();
  if (reduced) return 0.05;
  rig.add(
    MoveByEffect(
      Vector2(0, -5),
      _ease(0.12, alternate: true, curve: Curves.easeOut),
    ),
  );
  arm.add(
    RotateEffect.by(
      arm.outward * 0.6,
      _ease(0.15, alternate: true, atMax: 0.6),
    ),
  );
  return 0.15 * 2 + 0.6 + 0.05;
}

double _laugh(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.laugh, math.max(1.6, seconds));
  rig.head.settle();
  rig.torso.settle();
  if (reduced) return 0.05;
  rig.head.add(
    RotateEffect.by(
      -0.09 * rig.face.facing,
      _ease(0.11, alternate: true, repeat: 3),
    ),
  );
  rig.torso.add(
    MoveByEffect(Vector2(0, 1.6), _ease(0.11, alternate: true, repeat: 3)),
  );
  return 0.11 * 6 + 0.05;
}

/// Shoulders drop, then a slow nod: giving in.
double _sighNod(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.sigh, math.max(1.8, seconds));
  rig.head.settle();
  rig.torso.settle();
  if (reduced) return 0.05;
  rig.torso.add(
    MoveByEffect(Vector2(0, 2.2), _ease(0.4, alternate: true, atMax: 0.3)),
  );
  rig.head.add(
    MoveByEffect(Vector2(0, 2.8), _ease(0.28, alternate: true, delay: 0.35)),
  );
  return 0.4 * 2 + 0.3 + 0.05;
}

/// Head tilted, a small embarrassed smile: "a little..."
double _sheepish(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.happy, math.max(1.6, seconds));
  rig.head.settle();
  if (reduced) return 0.05;
  rig.head.add(
    RotateEffect.by(
      0.16 * rig.face.facing,
      _ease(0.25, alternate: true, atMax: 0.8),
    ),
  );
  return 0.25 * 2 + 0.8 + 0.05;
}

/// Both hands up, every finger spread: ten.
double _holdUpTen(CutoutRig rig, double seconds, bool reduced) {
  final hold = math.max(1.6, seconds);
  rig.face.show(FaceExpression.stern, hold + 0.6);
  final arms = [rig.leftArm..settle(), rig.rightArm..settle()];
  for (final arm in arms) {
    arm
      ..fingersShown = true
      ..bend = arm.outward * 0.15;
  }
  void lower() {
    for (final arm in arms) {
      arm
        ..angle = arm.restAngle
        ..bend = arm.restBend
        ..fingersShown = false;
    }
    if (rig.isMounted) rig.game.wake(0.05);
  }

  if (reduced) {
    for (final arm in arms) {
      arm.angle = arm.lifted(2.3);
    }
    async.Timer(Duration(milliseconds: (hold * 1000).round()), lower);
    return 0.05;
  }
  const up = 0.25, down = 0.3;
  for (final arm in arms) {
    arm.add(
      SequenceEffect(
        [
          RotateEffect.to(arm.lifted(2.3), _ease(up, curve: Curves.easeOut)),
          RotateEffect.to(arm.restAngle, _ease(down, delay: hold)),
        ],
        onComplete: () => arm
          ..fingersShown = false
          ..bend = arm.restBend,
      ),
    );
  }
  return up + hold + down + 0.05;
}

/// Chin down, eyes up over the reading glasses: sizing someone up.
double _lookOverGlasses(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.stern, math.max(1.8, seconds));
  rig.head.settle();
  if (reduced) return 0.05;
  rig.head.add(
    MoveByEffect(Vector2(0, 2.4), _ease(0.3, alternate: true, atMax: 1.0)),
  );
  return 0.3 * 2 + 1.0 + 0.05;
}

/// The bag slips from the hand and thuds onto the ground, and stays there.
double _bagDrop(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.shock, 2.4);
  final arm = rig.leftArm;
  final bag = arm.held;
  if (bag == null) return 0.05;
  arm.held = null;
  // Where the hand is, in the rig's coordinates, give or take the elbow.
  final hand = arm.position + Vector2(0, arm.upper + arm.fore);
  final dropped = RigPart(
    position: hand,
    priority: 5,
    draw: (canvas, _) => bag(canvas, Offset.zero),
  );
  rig.add(dropped);
  // The bag hangs about 25 below the hand; land it on the ground (y = 0).
  final ground = Vector2(hand.x - 4, -26);
  if (reduced) {
    dropped.position = ground;
    return 0.05;
  }
  dropped.add(MoveToEffect(ground, _ease(0.26, curve: Curves.easeIn)));
  dropped.add(RotateEffect.by(0.18, _ease(0.26, curve: Curves.easeIn)));
  // The landing jolts Dev too.
  _settleBody(rig);
  rig.add(
    MoveByEffect(Vector2(0, -3), _ease(0.1, alternate: true, delay: 0.26)),
  );
  return 0.26 + 0.2 + 0.1;
}

/// No, no, no: the head swings side to side.
double _headShake(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.shock, 1.2);
  rig.head.settle();
  if (reduced) return 0.05;
  rig.head.add(
    MoveByEffect(Vector2(2.6, 0), _ease(0.09, alternate: true, repeat: 3)),
  );
  rig.head.add(RotateEffect.by(0.12, _ease(0.09, alternate: true, repeat: 3)));
  return 0.09 * 6 + 0.05;
}

/// The look of someone who has got exactly the answer she wanted.
double _smug(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.smug, math.max(1.8, seconds));
  rig.head.settle();
  if (reduced) return 0.05;
  rig.head.add(
    RotateEffect.by(
      0.1 * rig.face.facing,
      _ease(0.25, alternate: true, atMax: 0.9),
    ),
  );
  return 0.25 * 2 + 0.9 + 0.05;
}

/// A slow smile. Pleasant, or ominous, depending on who wears it.
double _smile(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.happy, math.max(2.0, seconds));
  return 0.05;
}

/// Hand to the chin, eyes on the ceiling: trying to remember.
double _think(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.gestureArm..settle();
  final hold = math.max(1.8, seconds);
  rig.face.show(FaceExpression.shrug, hold + 0.4);
  // Elbow tucked in, forearm folded up: the hand comes to rest at the chin.
  final chin = arm.lifted(-1.1);
  final fold = -arm.outward * 2.27;
  void rest() {
    arm
      ..angle = arm.restAngle
      ..bend = arm.restBend;
    if (rig.isMounted) rig.game.wake(0.05);
  }

  arm.bend = fold;
  if (reduced) {
    arm.angle = chin;
    async.Timer(Duration(milliseconds: (hold * 1000).round()), rest);
    return 0.05;
  }
  arm.add(
    SequenceEffect([
      RotateEffect.to(chin, _ease(0.3, curve: Curves.easeOut)),
      RotateEffect.to(arm.restAngle, _ease(0.3, delay: hold)),
    ], onComplete: () => arm.bend = arm.restBend),
  );
  rig.head.settle();
  rig.head.add(
    RotateEffect.by(
      -0.14 * rig.face.facing,
      _ease(0.3, alternate: true, atMax: hold),
    ),
  );
  return 0.3 + hold + 0.3 + 0.05;
}

/// A hand slapped to the forehead.
double _facepalm(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.gestureArm..settle();
  final hold = math.max(1.6, seconds);
  rig.face.show(FaceExpression.sigh, hold + 0.4);
  if (reduced) return 0.05;
  rig.head.settle();
  rig.head.add(
    MoveByEffect(Vector2(0, 2.4), _ease(0.12, alternate: true, atMax: hold)),
  );
  // Upper arm raised, forearm folded back so the palm lands on the forehead.
  arm.bend = arm.outward * 1.48;
  arm.add(
    SequenceEffect([
      RotateEffect.to(arm.lifted(2.7), _ease(0.18, curve: Curves.easeIn)),
      RotateEffect.to(arm.restAngle, _ease(0.35, delay: hold)),
    ], onComplete: () => arm.bend = arm.restBend),
  );
  return 0.18 + hold + 0.35 + 0.05;
}

/// Steps closer to whoever she is looking at, and stays there.
double _approach(CutoutRig rig, double seconds, bool reduced) {
  final step = Vector2(rig.face.facing * 34, 0);
  rig.face.show(FaceExpression.stern, 3);
  _settleBody(rig);
  rig.restPosition.add(step);
  if (reduced) {
    rig.position.setFrom(rig.restPosition);
    return 0.05;
  }
  final walk = math.max(0.9, seconds);
  rig.add(MoveByEffect(step, _ease(walk, curve: Curves.easeInOut)));
  // A little bob for each step.
  rig.add(
    MoveByEffect(Vector2(0, -1.6), _ease(walk / 6, alternate: true, repeat: 3)),
  );
  return walk + 0.05;
}

/// Pulling tea: the pot held high, the glass held low, a long stream between.
double _pour(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.happy, 2.2);
  final up = rig.gestureArm..settle();
  final low = (rig.gestureArm == rig.leftArm ? rig.rightArm : rig.leftArm)
    ..settle();
  final hold = math.max(1.4, seconds);
  if (reduced) return 0.05;
  up.add(
    SequenceEffect([
      RotateEffect.to(up.lifted(2.4), _ease(0.3, curve: Curves.easeOut)),
      RotateEffect.to(up.restAngle, _ease(0.3, delay: hold)),
    ]),
  );
  low.add(
    SequenceEffect([
      RotateEffect.to(low.lifted(0.6), _ease(0.3, curve: Curves.easeOut)),
      RotateEffect.to(low.restAngle, _ease(0.3, delay: hold)),
    ]),
  );
  rig.pouring = hold + 0.6;
  rig.game.wake(hold + 0.6);
  return 0.3 + hold + 0.3 + 0.05;
}

/// The run-up and the delivery: a few skipping steps toward the batsman,
/// the arm windmilling over, the ball gone at the top.
double _bowl(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.gestureArm..settle();
  _settleBody(rig);
  rig.face.show(FaceExpression.stern, 1.6);
  final ball = arm.held;
  if (reduced) {
    arm.held = null;
    return 0.05;
  }
  const run = 0.55, whirl = 0.45;
  final toward = rig.face.facing;
  rig.add(
    MoveByEffect(Vector2(toward * 26, 0), _ease(run, curve: Curves.easeIn)),
  );
  rig.add(
    MoveByEffect(
      Vector2(0, -5),
      _ease(run / 6, alternate: true, repeat: 3, curve: Curves.easeOut),
    ),
  );
  arm.add(
    SequenceEffect([
      RotateEffect.to(arm.lifted(-0.5), _ease(run, curve: Curves.easeIn)),
      RotateEffect.by(
        arm.outward * 2 * math.pi,
        _ease(whirl, curve: Curves.easeIn),
      ),
      RotateEffect.to(arm.lifted(-0.9), _ease(0.2)),
      RotateEffect.to(arm.restAngle, _ease(0.4, delay: 0.6)),
    ]),
  );
  // The ball leaves the hand at the top of the swing.
  async.Timer(
    Duration(milliseconds: ((run + whirl * 0.62) * 1000).round()),
    () => arm.held = null,
  );
  async.Timer(const Duration(seconds: 4), () {
    arm.held = ball;
    if (rig.isMounted) rig.game.wake(0.05);
  });
  // Walks back to his mark.
  async.Timer(const Duration(milliseconds: 2600), () {
    if (!rig.isMounted || rig.game.closed) return;
    rig.add(
      MoveToEffect(rig.restPosition, _ease(0.8, curve: Curves.easeInOut)),
    );
    rig.game.wake(0.9);
  });
  return run + whirl + 0.6;
}

/// A batsman's swing, both hands: back-lift, a wild heave through the line,
/// a follow-through over the shoulder, back into the stance.
double _swing(CutoutRig rig, double seconds, bool reduced) {
  final arms = [rig.leftArm..settle(), rig.rightArm..settle()];
  if (reduced) return 0.05;
  const lift = 0.2, heave = 0.12, hold = 0.35, back = 0.4;
  // Toward the bowler is the direction the face looks.
  final toward = rig.face.facing;
  for (final arm in arms) {
    arm.add(
      SequenceEffect([
        RotateEffect.to(
          arm.angle + toward * 2.1,
          _ease(lift, curve: Curves.easeOut),
        ),
        RotateEffect.to(
          arm.angle - toward * 1.4,
          _ease(heave, curve: Curves.easeIn),
        ),
        RotateEffect.to(arm.restAngle, _ease(back, delay: hold)),
      ]),
    );
  }
  rig.add(
    SequenceEffect([
      RotateEffect.to(-toward * 0.06, _ease(lift)),
      RotateEffect.to(toward * 0.08, _ease(heave)),
      RotateEffect.to(0, _ease(back, delay: hold)),
    ]),
  );
  return lift + heave + hold + back + 0.05;
}

/// Something to eat: the free hand to the mouth, three bites, chewing.
double _eat(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.leftArm.held == null ? rig.leftArm : rig.rightArm;
  arm.settle();
  final bites = math.max(2, (seconds / 0.9).round());
  rig.face.show(FaceExpression.happy, bites * 0.9 + 0.6);
  rig.face.talk(bites * 0.9);
  if (reduced) return 0.05;
  final mouth = arm.lifted(-1.25);
  final fold = -arm.outward * 2.4;
  arm.bend = fold;
  arm.add(
    SequenceEffect([
      for (var i = 0; i < bites; i++) ...[
        RotateEffect.to(mouth, _ease(0.22, curve: Curves.easeOut)),
        RotateEffect.to(arm.lifted(-0.7), _ease(0.3, delay: 0.25)),
      ],
      RotateEffect.to(arm.restAngle, _ease(0.25)),
    ], onComplete: () => arm.bend = arm.restBend),
  );
  return bites * 0.77 + 0.3;
}

/// Too much chilli: the face burns, a hand fans the open mouth, a hop,
/// steam out of both ears.
double _spicy(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.leftArm.held == null ? rig.leftArm : rig.rightArm;
  arm.settle();
  final hold = math.max(2.4, seconds);
  rig.face.show(FaceExpression.spicy, hold);
  if (reduced) return 0.05;
  rig.add(EarSteam(at: rig.head.position.clone(), seconds: hold));
  arm.bend = -arm.outward * 2.4;
  arm.add(
    SequenceEffect([
      RotateEffect.to(arm.lifted(-1.3), _ease(0.15)),
      RotateEffect.by(
        arm.outward * 0.35,
        _ease(0.09, alternate: true, repeat: (hold / 0.18).floor()),
      ),
      RotateEffect.to(arm.restAngle, _ease(0.25)),
    ], onComplete: () => arm.bend = arm.restBend),
  );
  rig.add(
    MoveByEffect(Vector2(0, -6), _ease(0.12, alternate: true, repeat: 2)),
  );
  return hold + 0.3;
}

/// Both hands up and clapped together above the head: at a mosquito.
double _slap(CutoutRig rig, double seconds, bool reduced) {
  final arms = [rig.leftArm..settle(), rig.rightArm..settle()];
  rig.face.show(FaceExpression.stern, 0.5);
  if (reduced) return 0.05;
  for (final arm in arms) {
    arm.add(
      SequenceEffect([
        RotateEffect.to(arm.lifted(2.2), _ease(0.14, curve: Curves.easeOut)),
        RotateEffect.to(arm.lifted(2.9), _ease(0.06, curve: Curves.easeIn)),
        RotateEffect.to(arm.restAngle, _ease(0.3, delay: 0.25)),
      ]),
    );
  }
  async.Timer(const Duration(milliseconds: 700), () {
    if (rig.isMounted) rig.face.show(FaceExpression.sigh, 1.2);
  });
  return 0.14 + 0.06 + 0.25 + 0.3 + 0.05;
}

/// Arms up, a jump, another: OUT!
double _cheer(CutoutRig rig, double seconds, bool reduced) {
  final arms = [rig.leftArm..settle(), rig.rightArm..settle()];
  _settleBody(rig);
  rig.face.show(FaceExpression.laugh, 1.8);
  if (reduced) return 0.05;
  for (final arm in arms) {
    arm.add(
      SequenceEffect([
        RotateEffect.to(arm.lifted(2.8), _ease(0.15)),
        RotateEffect.by(
          arm.outward * 0.25,
          _ease(0.12, alternate: true, repeat: 3),
        ),
        RotateEffect.to(arm.restAngle, _ease(0.3)),
      ]),
    );
  }
  rig.add(
    MoveByEffect(
      Vector2(0, -12),
      _ease(0.18, alternate: true, repeat: 2, curve: Curves.easeOut),
    ),
  );
  return 0.15 + 0.72 + 0.3 + 0.05;
}

/// Turning over in bed, again: a roll one way and back, a heavy sigh.
double _toss(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.sigh, 1.6);
  if (reduced) return 0.05;
  final rest = rig.angle;
  rig.add(
    SequenceEffect([
      RotateEffect.to(rest + 0.08, _ease(0.25)),
      RotateEffect.to(rest - 0.05, _ease(0.3)),
      RotateEffect.to(rest, _ease(0.25)),
    ]),
  );
  return 0.85;
}

/// Eyes close and stay closed.
double _sleep(CutoutRig rig, double seconds, bool reduced) {
  rig.face.settle(FaceExpression.asleep);
  return 0.1;
}

/// Eyes open with a start.
double _wake(CutoutRig rig, double seconds, bool reduced) {
  rig.face.settle(FaceExpression.neutral);
  rig.face.show(FaceExpression.shock, 0.9);
  if (reduced) return 0.05;
  rig.add(MoveByEffect(Vector2(0, -4), _ease(0.1, alternate: true)));
  return 0.3;
}

/// One more ladle on the plate, whether you want it or not.
double _serve(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.rightArm..settle();
  rig.face.show(FaceExpression.happy, 1.4);
  if (reduced) return 0.05;
  arm.add(
    SequenceEffect([
      RotateEffect.to(arm.angle - 0.9, _ease(0.25, curve: Curves.easeOut)),
      RotateEffect.to(
        arm.angle + 0.35,
        _ease(0.2, delay: 0.1, curve: Curves.easeIn),
      ),
      RotateEffect.to(arm.restAngle, _ease(0.3, delay: 0.2)),
    ]),
  );
  rig.add(
    MoveByEffect(
      Vector2(-rig.face.facing * -4, 3),
      _ease(0.25, alternate: true, atMax: 0.3),
    ),
  );
  return 1.1;
}

/// A hand on the stomach: it growled.
double _belly(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.leftArm.held == null ? rig.leftArm : rig.rightArm;
  arm.settle();
  final hold = math.max(1.4, seconds);
  rig.face.show(FaceExpression.sigh, hold);
  if (reduced) return 0.05;
  arm.bend = -arm.outward * 1.3;
  arm.add(
    SequenceEffect([
      RotateEffect.to(arm.lifted(-0.35), _ease(0.2)),
      RotateEffect.to(arm.restAngle, _ease(0.25, delay: hold)),
    ], onComplete: () => arm.bend = arm.restBend),
  );
  rig.add(
    MoveByEffect(Vector2(0, 1.5), _ease(0.06, alternate: true, repeat: 3)),
  );
  return hold + 0.5;
}

/// A long yawn and a stretch, arms up.
double _yawn(CutoutRig rig, double seconds, bool reduced) {
  final arms = [rig.leftArm..settle(), rig.rightArm..settle()];
  rig.face.show(FaceExpression.laugh, 1.4);
  rig.face.talk(1.2);
  if (reduced) return 0.05;
  for (final arm in arms) {
    arm.add(
      SequenceEffect([
        RotateEffect.to(arm.lifted(2.6), _ease(0.45)),
        RotateEffect.to(arm.restAngle, _ease(0.45, delay: 0.6)),
      ]),
    );
  }
  return 1.6;
}

/// The angle that swings [arm] [amount] radians toward where [rig] faces.
double _forward(CutoutRig rig, Limb arm, double amount) =>
    arm.restAngle - rig.face.facing * amount;

/// Both hands out in front, meeting and parting: applause.
double _clap(CutoutRig rig, double seconds, bool reduced) {
  final arms = [rig.leftArm..settle(), rig.rightArm..settle()];
  rig.face.show(FaceExpression.happy, math.max(1.8, seconds));
  if (reduced) return 0.05;
  final claps = math.max(4, (seconds / 0.2).round());
  for (final (i, arm) in arms.indexed) {
    arm.bend = -rig.face.facing * 0.9;
    final apart = (i == 0 ? 1 : -1) * 0.14;
    arm.add(
      SequenceEffect([
        RotateEffect.to(_forward(rig, arm, 0.95), _ease(0.18)),
        RotateEffect.by(apart, _ease(0.1, alternate: true, repeat: claps)),
        RotateEffect.to(arm.restAngle, _ease(0.25)),
      ], onComplete: () => arm.bend = arm.restBend),
    );
  }
  return 0.18 + 0.2 * claps + 0.3;
}

/// A slow bow over folded hands, and the smile that comes with it.
double _namaste(CutoutRig rig, double seconds, bool reduced) {
  rig.face.show(FaceExpression.happy, math.max(1.6, seconds));
  rig.head.settle();
  rig.torso.settle();
  if (reduced) return 0.05;
  rig.torso.add(
    MoveByEffect(Vector2(0, 2.4), _ease(0.35, alternate: true, atMax: 0.25)),
  );
  rig.head.add(
    MoveByEffect(Vector2(0, 4.6), _ease(0.35, alternate: true, atMax: 0.25)),
  );
  return 0.35 * 2 + 0.25 + 0.05;
}

/// An arm straight out at something: the screen, the culprit.
double _point(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.gestureArm..settle();
  final hold = math.max(1.0, seconds);
  rig.face.show(FaceExpression.stern, hold);
  arm.bend = 0;
  if (reduced) {
    arm.angle = _forward(rig, arm, 1.55);
    async.Timer(Duration(milliseconds: (hold * 1000).round()), () {
      arm
        ..angle = arm.restAngle
        ..bend = arm.restBend;
      if (rig.isMounted) rig.game.wake(0.05);
    });
    return 0.05;
  }
  arm.add(
    SequenceEffect([
      RotateEffect.to(
        _forward(rig, arm, 1.55),
        _ease(0.2, curve: Curves.easeOut),
      ),
      RotateEffect.by(0.06, _ease(0.12, alternate: true, repeat: 2)),
      RotateEffect.to(arm.restAngle, _ease(0.3, delay: hold - 0.5)),
    ], onComplete: () => arm.bend = arm.restBend),
  );
  return 0.2 + 0.48 + hold - 0.2;
}

/// Both hands on the keyboard, fingers going: fixing it live.
double _type(CutoutRig rig, double seconds, bool reduced) {
  final arms = [rig.leftArm..settle(), rig.rightArm..settle()];
  final hold = math.max(1.6, seconds);
  rig.face.show(FaceExpression.stern, hold);
  if (reduced) return 0.05;
  final taps = (hold / 0.16).round();
  for (final (i, arm) in arms.indexed) {
    arm.bend = -rig.face.facing * 1.1;
    arm.add(
      SequenceEffect([
        RotateEffect.to(_forward(rig, arm, 0.55), _ease(0.18)),
        RotateEffect.by(
          0.07,
          _ease(0.08, alternate: true, repeat: taps, delay: i * 0.04),
        ),
        RotateEffect.to(arm.restAngle, _ease(0.25)),
      ], onComplete: () => arm.bend = arm.restBend),
    );
  }
  rig.head.settle();
  rig.head.add(
    MoveByEffect(
      Vector2(rig.face.facing * 2, 2),
      _ease(0.2, alternate: true, atMax: hold),
    ),
  );
  return 0.18 + 0.16 * taps + 0.3;
}

/// Jaw set, a shake of fury, steam from both ears.
double _fume(CutoutRig rig, double seconds, bool reduced) {
  final hold = math.max(2.0, seconds);
  rig.face.show(FaceExpression.stern, hold);
  if (reduced) return 0.05;
  rig.add(EarSteam(at: rig.head.position.clone(), seconds: hold));
  _settleBody(rig);
  rig.add(
    MoveByEffect(Vector2(1.4, 0), _ease(0.05, alternate: true, repeat: 6)),
  );
  return hold + 0.1;
}

/// Trying very hard not to laugh: a hand to the mouth, shoulders shaking.
double _giggle(CutoutRig rig, double seconds, bool reduced) {
  final arm = rig.gestureArm..settle();
  final hold = math.max(1.6, seconds);
  rig.face.show(FaceExpression.laugh, hold);
  if (reduced) return 0.05;
  arm.bend = arm.outward * 2.3;
  arm.add(
    SequenceEffect([
      RotateEffect.to(arm.lifted(1.4), _ease(0.2)),
      RotateEffect.to(arm.restAngle, _ease(0.25, delay: hold)),
    ], onComplete: () => arm.bend = arm.restBend),
  );
  rig.torso.settle();
  rig.torso.add(
    MoveByEffect(
      Vector2(0, 1.2),
      _ease(0.07, alternate: true, repeat: (hold / 0.14).round()),
    ),
  );
  return hold + 0.5;
}
