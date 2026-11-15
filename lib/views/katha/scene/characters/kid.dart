import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// Priya's nephew: about half Dev's height, a bowler's swagger, spiky hair,
/// a T-shirt and shorts. The same rig as the grown-ups, built small.
CutoutRig buildKid({
  required String id,
  required Vector2 feet,
  double facing = 1,
  bool sparkler = false,
}) {
  const headRadius = 15.0;
  const skin = KathaInk.skinWarm;
  final face = Face(facing: facing, radius: headRadius, skin: skin);
  final head = RigPart(
    position: Vector2(0, -102),
    priority: 1,
    draw: (canvas, _) =>
        drawHead(canvas, radius: headRadius, skin: skin, hair: _kidHair),
  );
  final leftArm = Limb(
    position: Vector2(-13, -82),
    restAngle: 0.1,
    outward: 1,
    bend: -0.1,
    sleeveLength: 10,
    sleeve: KathaInk.brick,
    skin: skin,
    priority: 2,
  );
  // A sparkler is held up and out, away from the face: the Sparkler prop
  // draws the wire and its sparks at the end of this arm.
  final rightArm = Limb(
    position: Vector2(13, -82),
    restAngle: sparkler ? -2.3 : -0.1,
    outward: -1,
    bend: sparkler ? 0.35 : 0.1,
    sleeveLength: 10,
    sleeve: KathaInk.brick,
    skin: skin,
    priority: 3,
    held: sparkler ? null : _drawBall,
  );
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.brick,
    position: feet,
    headRadius: headRadius,
    legs: RigPart(draw: (canvas, _) => _drawShorts(canvas)),
    torso: RigPart(priority: 1, draw: (canvas, _) => _drawTee(canvas)),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: rightArm,
  )..scale = Vector2.all(0.66);
}

void _kidHair(Canvas canvas, double r) {
  final path = Path()..moveTo(-r * 1.0, -r * 0.1);
  for (var i = 0; i <= 6; i++) {
    final a = math.pi + i * math.pi / 6;
    final spike = i.isEven ? 1.22 : 1.0;
    path.lineTo(math.cos(a) * r * spike, math.sin(a) * r * spike - r * 0.1);
  }
  path
    ..lineTo(r * 0.86, -r * 0.3)
    ..quadraticBezierTo(0, -r * 0.8, -r * 0.86, -r * 0.3)
    ..close();
  canvas.drawPath(path, Paint()..color = KathaInk.ink);
}

void _drawTee(Canvas canvas) {
  canvas.drawRect(
    const Rect.fromLTRB(-4, -92, 4, -84),
    Paint()..color = KathaInk.skinWarm,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(-15, -88, 15, -46, const Radius.circular(7)),
    Paint()..color = KathaInk.brick,
  );
  // A big number on the back of every gully cricketer's shirt.
  canvas.drawCircle(
    const Offset(0, -68),
    7,
    Paint()..color = KathaInk.paper.withValues(alpha: 0.85),
  );
  canvas.drawRect(
    const Rect.fromLTRB(-0.9, -72, 1.4, -64),
    Paint()..color = KathaInk.brick,
  );
}

void _drawShorts(Canvas canvas) {
  canvas.drawRect(
    const Rect.fromLTRB(-13, -48, 13, -30),
    Paint()..color = KathaInk.teal,
  );
  final leg = Paint()..color = KathaInk.skinWarm;
  canvas.drawRect(const Rect.fromLTRB(-10, -30, -2, -3), leg);
  canvas.drawRect(const Rect.fromLTRB(2, -30, 10, -3), leg);
  final shoe = Paint()..color = KathaInk.marigold;
  canvas.drawRRect(
    RRect.fromLTRBR(-12, -4, 0, 0.6, const Radius.circular(2.4)),
    shoe,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(2, -4, 14, 0.6, const Radius.circular(2.4)),
    shoe,
  );
}

void _drawBall(Canvas canvas, Offset hand) {
  canvas.drawCircle(hand.translate(0, 3), 3.6, Paint()..color = KathaInk.brick);
}
