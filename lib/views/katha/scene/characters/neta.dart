import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// The neta, in the flesh at last: the same round face as the poster, the
/// same moustache, white kurta and a khadi jacket, a garland of marigolds
/// somebody has hung on him, and his hands folded in namaste. He holds the
/// pose. He holds the smile.
CutoutRig buildNeta({
  required String id,
  required Vector2 feet,
  double facing = -1,
}) {
  const headRadius = 16.0;
  final skin = Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.35)!;
  final face = Face(
    facing: facing,
    radius: headRadius,
    skin: skin,
    mouthDrop: 0.7,
    browWeight: 2.4,
  )..rest = FaceExpression.happy;
  final head = RigPart(
    position: Vector2(0, -104),
    priority: 1,
    draw: (canvas, _) => drawHead(
      canvas,
      radius: headRadius,
      skin: skin,
      hair: _netaHair,
      moustache: true,
    ),
  );
  const kurta = Color(0xFFFFFFFF);
  // Hands together at the chest: each forearm folds in to meet the other.
  final leftArm = Limb(
    position: Vector2(-17, -84),
    restAngle: 0.2,
    outward: 1,
    bend: -2.2,
    sleeveLength: 34,
    sleeve: kurta,
    skin: skin,
    priority: 3,
  );
  final rightArm = Limb(
    position: Vector2(17, -84),
    restAngle: -0.2,
    outward: -1,
    bend: 2.2,
    sleeveLength: 34,
    sleeve: kurta,
    skin: skin,
    priority: 3,
  );
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.marigold,
    position: feet,
    headRadius: headRadius,
    legs: RigPart(draw: (canvas, _) => _drawNetaLegs(canvas)),
    torso: RigPart(
      priority: 1,
      draw: (canvas, _) => _drawNetaTorso(canvas, skin),
    ),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: facing > 0 ? rightArm : leftArm,
  );
}

/// Oiled, combed straight back, silvering at the temples.
void _netaHair(Canvas canvas, double r) {
  canvas.drawPath(
    Path()
      ..moveTo(-r * 1.0, -r * 0.05)
      ..cubicTo(-r * 1.1, -r * 1.0, r * 1.1, -r * 1.3, r * 1.0, -r * 0.05)
      ..lineTo(r * 0.88, -r * 0.5)
      ..cubicTo(r * 0.4, -r * 0.86, -r * 0.4, -r * 0.86, -r * 0.88, -r * 0.5)
      ..close(),
    Paint()..color = KathaInk.ink,
  );
  final silver = Paint()..color = KathaInk.paper.withValues(alpha: 0.55);
  canvas.drawRect(
    Rect.fromLTRB(-r * 1.0, -r * 0.5, -r * 0.86, -r * 0.02),
    silver,
  );
  canvas.drawRect(
    Rect.fromLTRB(r * 0.86, -r * 0.5, r * 1.0, -r * 0.02),
    silver,
  );
  // The shine of the oil.
  canvas.drawArc(
    Rect.fromLTRB(-r * 0.6, -r * 1.1, r * 0.6, -r * 0.5),
    math.pi * 1.15,
    math.pi * 0.5,
    false,
    Paint()
      ..color = KathaInk.paper.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.1,
  );
}

void _drawNetaTorso(Canvas canvas, Color skin) {
  canvas.drawRect(const Rect.fromLTRB(-5, -92, 5, -82), Paint()..color = skin);
  // A long white kurta, a comfortable middle.
  final kurta = Path()
    ..moveTo(-13, -88)
    ..quadraticBezierTo(-22, -87, -22, -76)
    ..quadraticBezierTo(-27, -52, -21, -30)
    ..lineTo(21, -30)
    ..quadraticBezierTo(27, -52, 22, -76)
    ..quadraticBezierTo(22, -87, 13, -88)
    ..close();
  canvas.drawPath(kurta, Paint()..color = const Color(0xFFFFFFFF));
  // The khadi jacket over it, open down the front.
  final jacket = Paint()..color = KathaInk.khakiShade;
  for (final side in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(side * 6, -88)
        ..lineTo(side * 18, -86)
        ..quadraticBezierTo(side * 24, -60, side * 20, -46)
        ..lineTo(side * 5, -46)
        ..close(),
      jacket,
    );
  }
  for (final y in [-80.0, -70.0, -60.0]) {
    canvas.drawCircle(Offset(-6.5, y), 0.9, Paint()..color = KathaInk.paper);
  }
  // The garland: a deep U of marigolds, to the waist.
  for (var i = 0; i <= 16; i++) {
    final u = i / 16;
    canvas.drawCircle(
      Offset(-13 + u * 26, -88 + math.sin(u * math.pi) * 30),
      3,
      Paint()..color = i.isEven ? KathaInk.marigold : KathaInk.brick,
    );
  }
}

void _drawNetaLegs(Canvas canvas) {
  final pyjama = Paint()
    ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.06)!;
  canvas.drawRect(const Rect.fromLTRB(-12, -31, -1, -4), pyjama);
  canvas.drawRect(const Rect.fromLTRB(1, -31, 12, -4), pyjama);
  final sandal = Paint()..color = KathaInk.brickShade;
  canvas.drawRRect(
    RRect.fromLTRBR(-13.5, -4, 0, 0.6, const Radius.circular(2.4)),
    sandal,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(1, -4, 14.5, 0.6, const Radius.circular(2.4)),
    sandal,
  );
}
