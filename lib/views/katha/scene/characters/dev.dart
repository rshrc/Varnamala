import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';
import 'package:words625/views/katha/scene/sets/kitchen.dart';

/// What Dev has in his left hand.
enum DevCarrying {
  bag,
  tea,
  bat,
  nothing,
  plate,
  phone,
  corn,
  biscuits,

  /// The red gas cylinder, carried by its collar: heavy.
  cylinder,
}

/// Dev: the newcomer. Standing, facing right, a big bag in his left hand.
///
/// [seated] drops the legs, for the back seat of an auto: the body hides
/// below the auto's side and only the upper body shows. [facing] is -1 to
/// look left.
CutoutRig buildDev({
  required String id,
  required Vector2 feet,
  double facing = 1,
  bool seated = false,
  DevCarrying carrying = DevCarrying.bag,
  bool batting = false,
}) {
  const headRadius = 14.0;
  const skin = KathaInk.skinWarm;
  final face = Face(facing: facing, radius: headRadius, skin: skin);
  final head = RigPart(
    position: Vector2(0, -107),
    priority: 1,
    draw: (canvas, _) =>
        drawHead(canvas, radius: headRadius, skin: skin, hair: _devHair),
  );
  final cuff = Color.lerp(KathaInk.teal, KathaInk.paper, 0.35)!;
  // Which arm does what. The phone goes to the ear on the side Dev faces;
  // everything else rides in the left hand.
  final phone = carrying == DevCarrying.phone;
  final batsLeft = batting && facing < 0;
  final batsRight = batting && facing >= 0;
  final leftHeld = switch (carrying) {
    DevCarrying.bag => _drawDuffel,
    DevCarrying.tea => drawTeaGlass,
    DevCarrying.bat =>
      batting ? (batsLeft ? _drawBatGrounded : null) : _drawBat,
    DevCarrying.plate => _drawPlate,
    DevCarrying.corn => _drawCorn,
    DevCarrying.biscuits => _drawBiscuits,
    DevCarrying.cylinder => _drawCylinderHeld,
    DevCarrying.phone => facing < 0 ? drawPhone : null,
    DevCarrying.nothing => null,
  };
  final leftArm = Limb(
    position: Vector2(-15, -85),
    restAngle: batsLeft
        ? 0.5
        : batsRight
        ? -0.8
        : phone && facing < 0
        ? 2.2
        : 0.1,
    outward: 1,
    bend: phone && facing < 0 ? 2.05 : (batting ? -0.3 : -0.16),
    sleeve: KathaInk.teal,
    cuff: cuff,
    skin: skin,
    priority: 2,
    held: leftHeld,
  );
  final rightArm = Limb(
    position: Vector2(15, -85),
    restAngle: batsLeft
        ? 0.8
        : batsRight
        ? -0.5
        : phone && facing >= 0
        ? -2.2
        : -0.1,
    outward: -1,
    bend: phone && facing >= 0 ? -2.05 : (batting ? 0.3 : -0.2),
    sleeve: KathaInk.teal,
    cuff: cuff,
    skin: skin,
    priority: 3,
    held: batsRight
        ? _drawBatGrounded
        : phone && facing >= 0
        ? drawPhone
        : null,
  );
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.teal,
    position: feet,
    headRadius: headRadius,
    legs: seated ? null : RigPart(draw: (canvas, _) => _drawDevLegs(canvas)),
    torso: RigPart(priority: 1, draw: (canvas, _) => _drawDevTorso(canvas)),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: facing > 0 ? rightArm : leftArm,
  );
}

/// A cricket bat, held by the handle, blade down.
void _drawBat(Canvas canvas, Offset hand) {
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 1.4, hand.dy - 2, hand.dx + 1.4, hand.dy + 8),
    Paint()..color = KathaInk.ink,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
      hand.dx - 4,
      hand.dy + 8,
      hand.dx + 4,
      hand.dy + 36,
      const Radius.circular(2),
    ),
    Paint()..color = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.35)!,
  );
}

/// The bat held out in a stance, longer reach, blade to the ground.
void _drawBatGrounded(Canvas canvas, Offset hand) {
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 1.5, hand.dy - 3, hand.dx + 1.5, hand.dy + 10),
    Paint()..color = KathaInk.ink,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
      hand.dx - 4.5,
      hand.dy + 10,
      hand.dx + 4.5,
      hand.dy + 46,
      const Radius.circular(2),
    ),
    Paint()..color = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.35)!,
  );
  canvas.drawLine(
    Offset(hand.dx, hand.dy + 14),
    Offset(hand.dx, hand.dy + 42),
    Paint()
      ..color = KathaInk.marigoldShade.withValues(alpha: 0.5)
      ..strokeWidth = 1,
  );
}

/// Breakfast on a steel plate: two idlis, a vada, a cup of sambar.
void _drawPlate(Canvas canvas, Offset hand) {
  final plate = Rect.fromCenter(
    center: hand.translate(0, 2),
    width: 30,
    height: 9,
  );
  canvas.drawOval(
    plate,
    Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.25)!,
  );
  canvas.drawOval(
    plate.deflate(2),
    Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.1)!,
  );
  for (final dx in [-8.0, -1.0]) {
    canvas.drawOval(
      Rect.fromCenter(center: hand.translate(dx, -1), width: 9, height: 6),
      Paint()..color = KathaInk.paper,
    );
  }
  canvas.drawCircle(
    hand.translate(8, -1),
    4.4,
    Paint()..color = KathaInk.marigoldShade,
  );
  canvas.drawCircle(
    hand.translate(8, -1),
    1.4,
    Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.1)!,
  );
}

/// Roasted corn on the cob, charred, with lime and chilli.
void _drawCorn(Canvas canvas, Offset hand) {
  canvas.drawRRect(
    RRect.fromLTRBR(
      hand.dx - 4,
      hand.dy - 20,
      hand.dx + 4,
      hand.dy + 2,
      const Radius.circular(4),
    ),
    Paint()..color = KathaInk.marigold,
  );
  final char = Paint()..color = KathaInk.ink.withValues(alpha: 0.45);
  for (final (dx, dy) in [(-2.0, -15.0), (1.5, -10.0), (-1.0, -5.0)]) {
    canvas.drawCircle(hand.translate(dx, dy), 1.4, char);
  }
  canvas.drawCircle(
    hand.translate(2, -17),
    1.2,
    Paint()..color = KathaInk.brick,
  );
  canvas.drawPath(
    Path()
      ..moveTo(hand.dx - 4, hand.dy + 2)
      ..lineTo(hand.dx - 8, hand.dy + 8)
      ..lineTo(hand.dx, hand.dy + 3)
      ..lineTo(hand.dx + 8, hand.dy + 8)
      ..lineTo(hand.dx + 4, hand.dy + 2)
      ..close(),
    Paint()..color = KathaInk.leaf,
  );
}

/// A packet of glucose biscuits: dinner.
void _drawBiscuits(Canvas canvas, Offset hand) {
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 8, hand.dy - 4, hand.dx + 8, hand.dy + 4),
    Paint()..color = KathaInk.marigold,
  );
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 8, hand.dy - 1, hand.dx + 8, hand.dy + 1),
    Paint()..color = KathaInk.brick,
  );
  canvas.drawCircle(
    hand.translate(-10, -1),
    3.4,
    Paint()..color = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.4)!,
  );
}

/// Thick hair swept up and over to one side, with some height to it.
void _devHair(Canvas canvas, double r) {
  final path = Path()
    ..moveTo(-r * 1.04, r * 0.1)
    ..cubicTo(-r * 1.2, -r * 0.9, -r * 0.5, -r * 1.46, r * 0.2, -r * 1.36)
    ..cubicTo(r * 0.86, -r * 1.3, r * 1.2, -r * 0.8, r * 1.04, -r * 0.06)
    ..lineTo(r * 0.96, -r * 0.34)
    ..cubicTo(r * 0.6, -r * 0.82, r * 0.1, -r * 0.86, -r * 0.34, -r * 0.62)
    ..cubicTo(-r * 0.66, -r * 0.5, -r * 0.84, -r * 0.24, -r * 0.9, r * 0.14)
    ..close();
  canvas.drawPath(path, Paint()..color = KathaInk.ink);
  // One lock catching the light, so the hair is a shape and not a cap.
  canvas.drawPath(
    Path()
      ..moveTo(-r * 0.2, -r * 1.12)
      ..quadraticBezierTo(r * 0.3, -r * 1.22, r * 0.66, -r * 0.92),
    Paint()
      ..color = KathaInk.paper.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round,
  );
}

void _drawDevLegs(Canvas canvas) {
  final trousers = Paint()..color = KathaInk.denim;
  // Slightly tapered, the nearer leg a touch forward.
  for (final (left, right, foot) in [(-12.0, -1.0, -11.5), (1.0, 12.0, 2.0)]) {
    canvas.drawPath(
      Path()
        ..moveTo(left, -49)
        ..lineTo(right, -49)
        ..lineTo(right - 1.4, -4)
        ..lineTo(left + 1.4, -4)
        ..close(),
      trousers,
    );
    // Turn-up at the ankle.
    canvas.drawRect(
      Rect.fromLTRB(left + 1.2, -7, right - 1.2, -4),
      Paint()..color = Color.lerp(KathaInk.denim, KathaInk.paper, 0.3)!,
    );
    // Shoe with a pale sole.
    canvas.drawRRect(
      RRect.fromLTRBR(foot, -4.6, foot + 13.5, 0.6, const Radius.circular(2.6)),
      Paint()..color = KathaInk.brickShade,
    );
    canvas.drawRect(
      Rect.fromLTRB(foot + 0.6, -0.4, foot + 13, 1),
      Paint()..color = KathaInk.paper,
    );
  }
}

void _drawDevTorso(Canvas canvas) {
  const skin = KathaInk.skinWarm;
  canvas.drawRect(const Rect.fromLTRB(-4, -96, 4, -86), Paint()..color = skin);
  canvas.drawOval(
    const Rect.fromLTRB(-4, -95, 4, -90),
    Paint()..color = Color.lerp(skin, KathaInk.ink, 0.22)!,
  );
  // Shirt: broad at the shoulder, narrower at the waist.
  final shirt = Path()
    ..moveTo(-11, -90)
    ..quadraticBezierTo(-18, -89, -18.5, -82)
    ..lineTo(-14, -45)
    ..quadraticBezierTo(0, -41, 14, -45)
    ..lineTo(18.5, -82)
    ..quadraticBezierTo(18, -89, 11, -90)
    ..close();
  canvas.drawPath(shirt, Paint()..color = KathaInk.teal);
  // The side away from the light, one step darker.
  canvas.save();
  canvas.clipPath(shirt);
  canvas.drawRect(
    const Rect.fromLTRB(-19, -90, -9, -41),
    Paint()..color = KathaInk.ink.withValues(alpha: 0.14),
  );
  canvas.restore();
  // Collar and the skin it opens on.
  canvas.drawPath(
    Path()
      ..moveTo(-5.4, -90)
      ..lineTo(0, -81)
      ..lineTo(5.4, -90)
      ..close(),
    Paint()..color = skin,
  );
  final collar = Paint()
    ..color = Color.lerp(KathaInk.teal, KathaInk.paper, 0.35)!;
  canvas.drawPath(
    Path()
      ..moveTo(-8.5, -90.5)
      ..lineTo(-5, -91)
      ..lineTo(-0.6, -81.5)
      ..lineTo(-5.4, -84.5)
      ..close(),
    collar,
  );
  canvas.drawPath(
    Path()
      ..moveTo(8.5, -90.5)
      ..lineTo(5, -91)
      ..lineTo(0.6, -81.5)
      ..lineTo(5.4, -84.5)
      ..close(),
    collar,
  );
  // Placket, buttons, pocket.
  final seam = Paint()
    ..color = KathaInk.ink.withValues(alpha: 0.3)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  canvas.drawLine(const Offset(0, -81), const Offset(0, -44), seam);
  for (final y in [-74.0, -64.0, -54.0]) {
    canvas.drawCircle(Offset(0, y), 1.1, Paint()..color = KathaInk.paper);
  }
  canvas.drawRRect(
    RRect.fromLTRBR(5, -76, 12.5, -68, const Radius.circular(1.2)),
    seam,
  );
  // The address he is looking for, sticking out of his pocket.
  canvas.save();
  canvas.translate(9, -77);
  canvas.rotate(0.12);
  canvas.drawRect(
    const Rect.fromLTRB(-2.6, -5, 2.6, 2),
    Paint()..color = KathaInk.paper,
  );
  canvas.restore();
  // Headphones round his neck.
  canvas.drawArc(
    const Rect.fromLTRB(-8, -97, 8, -84),
    0.1,
    math.pi - 0.2,
    false,
    Paint()
      ..color = KathaInk.marigold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round,
  );
  for (final x in [-8.0, 8.0]) {
    canvas.drawRRect(
      RRect.fromLTRBR(x - 2.6, -93, x + 2.6, -86, const Radius.circular(2)),
      Paint()..color = KathaInk.ink,
    );
  }
  // Belt.
  canvas.drawRect(
    const Rect.fromLTRB(-13.6, -47, 13.6, -44),
    Paint()..color = KathaInk.ink,
  );
  canvas.drawRect(
    const Rect.fromLTRB(-2.2, -47.4, 2.2, -43.6),
    Paint()..color = KathaInk.marigold,
  );
}

/// A big duffel bag, hanging from the hand by its straps. Green, so it stands
/// clear of the brick stall and the marigold auto behind it.
void _drawDuffel(Canvas canvas, Offset hand) {
  final body = RRect.fromLTRBR(
    hand.dx - 21,
    hand.dy + 5,
    hand.dx + 11,
    hand.dy + 25,
    const Radius.circular(8),
  );
  final strap = Paint()
    ..color = KathaInk.leafShade
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(hand, Offset(hand.dx - 11, hand.dy + 7), strap);
  canvas.drawLine(hand, Offset(hand.dx + 3, hand.dy + 7), strap);
  canvas.drawRRect(body, Paint()..color = KathaInk.leaf);
  // End panel, zip and a luggage tag.
  canvas.save();
  canvas.clipRRect(body);
  canvas.drawRect(
    Rect.fromLTRB(body.left, body.top, body.left + 7, body.bottom),
    Paint()..color = KathaInk.leafShade,
  );
  canvas.restore();
  canvas.drawLine(
    Offset(body.left + 9, body.top + 6),
    Offset(body.right - 4, body.top + 6),
    Paint()
      ..color = KathaInk.paper.withValues(alpha: 0.7)
      ..strokeWidth = 1.2,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
      body.right - 9,
      body.top + 9,
      body.right - 3,
      body.top + 16,
      const Radius.circular(1),
    ),
    Paint()..color = KathaInk.marigold,
  );
}

/// The cylinder hanging from Dev's hand by its collar, its base just off the
/// ground: he can carry it, but only just.
void _drawCylinderHeld(Canvas canvas, Offset hand) =>
    gasCylinder(canvas, hand.translate(0, 44), height: 40);
