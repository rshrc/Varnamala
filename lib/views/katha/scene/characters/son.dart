import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// What the landlady's son has in his hand.
enum SonCarrying { suitcase, phone, sweets, nothing }

/// The landlady's son, home from the other end of the country: a red hoodie,
/// headphones round his neck that never come off, a beard his mother has
/// opinions about, and a trolley case. Taller than Dev, and more at ease.
///
/// [seated] drops the legs, for a meal on the floor.
CutoutRig buildSon({
  required String id,
  required Vector2 feet,
  double facing = 1,
  bool seated = false,
  SonCarrying carrying = SonCarrying.nothing,
}) {
  const headRadius = 14.5;
  final skin = Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.2)!;
  final face = Face(
    facing: facing,
    radius: headRadius,
    skin: skin,
    mouthDrop: 0.3,
  );
  final head = RigPart(
    position: Vector2(0, -110),
    priority: 1,
    draw: (canvas, _) =>
        drawHead(canvas, radius: headRadius, skin: skin, hair: _sonHair),
  );
  const hoodie = KathaInk.brick;
  final cuff = KathaInk.brickShade;
  final phone = carrying == SonCarrying.phone;
  final leftArm = Limb(
    position: Vector2(-16, -87),
    restAngle: phone && facing < 0 ? 2.2 : 0.1,
    outward: 1,
    bend: phone && facing < 0 ? 2.05 : -0.16,
    sleeveLength: 33,
    sleeve: hoodie,
    cuff: cuff,
    skin: skin,
    priority: 2,
    held: switch (carrying) {
      SonCarrying.suitcase => _drawTrolley,
      SonCarrying.sweets => _drawSweetBox,
      SonCarrying.phone => facing < 0 ? drawPhone : null,
      SonCarrying.nothing => null,
    },
  );
  final rightArm = Limb(
    position: Vector2(16, -87),
    restAngle: phone && facing >= 0 ? -2.2 : -0.1,
    outward: -1,
    bend: phone && facing >= 0 ? -2.05 : -0.2,
    sleeveLength: 33,
    sleeve: hoodie,
    cuff: cuff,
    skin: skin,
    priority: 3,
    held: phone && facing >= 0 ? drawPhone : null,
  );
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.brick,
    position: feet,
    headRadius: headRadius,
    legs: seated ? null : RigPart(draw: (canvas, _) => _drawSonLegs(canvas)),
    torso: RigPart(priority: 1, draw: (canvas, _) => _drawHoodie(canvas, skin)),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: facing > 0 ? rightArm : leftArm,
  );
}

/// Faded at the sides, a quiff on top, and a beard trimmed by someone who
/// charges for it.
void _sonHair(Canvas canvas, double r) {
  final hair = Paint()..color = KathaInk.ink;
  canvas.drawPath(
    Path()
      ..moveTo(-r * 1.0, -r * 0.06)
      ..cubicTo(-r * 1.06, -r * 0.84, -r * 0.6, -r * 1.3, r * 0.02, -r * 1.36)
      ..cubicTo(r * 0.5, -r * 1.66, r * 1.22, -r * 1.3, r * 1.0, -r * 0.06)
      ..lineTo(r * 0.9, -r * 0.42)
      ..cubicTo(r * 0.4, -r * 0.72, -r * 0.4, -r * 0.72, -r * 0.9, -r * 0.42)
      ..close(),
    hair,
  );
  // The fade: a paler band where the clippers went.
  final fade = Paint()
    ..color = Color.lerp(KathaInk.ink, KathaInk.skinWarm, 0.45)!;
  canvas.drawRect(
    Rect.fromLTRB(-r * 1.0, -r * 0.42, -r * 0.88, r * 0.04),
    fade,
  );
  canvas.drawRect(Rect.fromLTRB(r * 0.88, -r * 0.42, r * 1.0, r * 0.04), fade);
  // Beard: along the jaw and round the chin, a gap left for the mouth.
  canvas.drawPath(
    Path()
      ..moveTo(-r * 0.98, r * 0.02)
      ..cubicTo(-r * 0.96, r * 0.78, -r * 0.56, r * 1.22, 0, r * 1.24)
      ..cubicTo(r * 0.56, r * 1.22, r * 0.96, r * 0.78, r * 0.98, r * 0.02)
      ..lineTo(r * 0.82, r * 0.08)
      ..cubicTo(r * 0.74, r * 0.6, r * 0.42, r * 0.86, 0, r * 0.88)
      ..cubicTo(-r * 0.42, r * 0.86, -r * 0.74, r * 0.6, -r * 0.82, r * 0.08)
      ..close(),
    hair,
  );
}

void _drawHoodie(Canvas canvas, Color skin) {
  const hoodie = KathaInk.brick;
  // The hood, bunched behind the neck.
  canvas.drawOval(
    const Rect.fromLTRB(-13, -97, 13, -84),
    Paint()..color = KathaInk.brickShade,
  );
  canvas.drawRect(const Rect.fromLTRB(-4, -98, 4, -88), Paint()..color = skin);
  final body = Path()
    ..moveTo(-12, -91)
    ..quadraticBezierTo(-20, -90, -20, -82)
    ..lineTo(-17, -44)
    ..quadraticBezierTo(0, -40, 17, -44)
    ..lineTo(20, -82)
    ..quadraticBezierTo(20, -90, 12, -91)
    ..close();
  canvas.drawPath(body, Paint()..color = hoodie);
  canvas.save();
  canvas.clipPath(body);
  canvas.drawRect(
    const Rect.fromLTRB(-21, -92, -10, -40),
    Paint()..color = KathaInk.ink.withValues(alpha: 0.16),
  );
  // Ribbed hem.
  canvas.drawRect(
    const Rect.fromLTRB(-20, -49, 20, -40),
    Paint()..color = KathaInk.brickShade,
  );
  canvas.restore();
  // Kangaroo pocket.
  canvas.drawRRect(
    RRect.fromLTRBR(-11, -64, 11, -51, const Radius.circular(4)),
    Paint()..color = Color.lerp(hoodie, KathaInk.ink, 0.14)!,
  );
  // Drawstrings.
  final string = Paint()
    ..color = KathaInk.paper
    ..strokeWidth = 1.2
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(const Offset(-3, -89), const Offset(-4, -74), string);
  canvas.drawLine(const Offset(3, -89), const Offset(4, -76), string);
  // Headphones round the neck, cups resting on the collarbones.
  canvas.drawArc(
    const Rect.fromLTRB(-13, -100, 13, -80),
    0.15,
    math.pi - 0.3,
    false,
    Paint()
      ..color = KathaInk.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6,
  );
  for (final x in [-12.0, 12.0]) {
    canvas.drawRRect(
      RRect.fromLTRBR(x - 4.4, -92, x + 4.4, -82, const Radius.circular(3)),
      Paint()..color = KathaInk.ink,
    );
    canvas.drawCircle(Offset(x, -87), 1.6, Paint()..color = KathaInk.teal);
  }
}

void _drawSonLegs(Canvas canvas) {
  // Joggers, cuffed at the ankle, and white trainers.
  final joggers = Paint()
    ..color = Color.lerp(KathaInk.ink, KathaInk.paper, 0.32)!;
  for (final (left, right, foot) in [(-13.0, -1.0, -12.5), (1.0, 13.0, 2.0)]) {
    canvas.drawPath(
      Path()
        ..moveTo(left, -47)
        ..lineTo(right, -47)
        ..lineTo(right - 2, -8)
        ..lineTo(left + 2, -8)
        ..close(),
      joggers,
    );
    canvas.drawRect(
      Rect.fromLTRB(left + 2, -9, right - 2, -4),
      Paint()..color = Color.lerp(KathaInk.ink, KathaInk.paper, 0.2)!,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(foot, -5, foot + 14, 0.8, const Radius.circular(3)),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRect(
      Rect.fromLTRB(foot + 1, -0.6, foot + 13, 0.8),
      Paint()..color = KathaInk.shutter,
    );
  }
  // A stripe down the outside of each leg.
  final stripe = Paint()
    ..color = KathaInk.paper.withValues(alpha: 0.6)
    ..strokeWidth = 1.2;
  canvas.drawLine(const Offset(-12, -46), const Offset(-10.6, -9), stripe);
  canvas.drawLine(const Offset(12, -46), const Offset(10.6, -9), stripe);
}

/// A hard-shell trolley case, its handle pulled up into his hand.
void _drawTrolley(Canvas canvas, Offset hand) {
  final shell = Color.lerp(KathaInk.teal, KathaInk.ink, 0.15)!;
  canvas.drawLine(
    hand,
    hand.translate(0, 10),
    Paint()
      ..color = KathaInk.shutter
      ..strokeWidth = 2.2,
  );
  final body = RRect.fromLTRBR(
    hand.dx - 13,
    hand.dy + 10,
    hand.dx + 13,
    hand.dy + 42,
    const Radius.circular(4),
  );
  canvas.drawRRect(body, Paint()..color = shell);
  for (final dx in [-6.0, 0.0, 6.0]) {
    canvas.drawLine(
      Offset(hand.dx + dx, body.top + 3),
      Offset(hand.dx + dx, body.bottom - 3),
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.2)
        ..strokeWidth = 1,
    );
  }
  // An airline tag, and the wheels.
  canvas.drawRect(
    Rect.fromLTWH(body.left - 3, body.top + 4, 5, 8),
    Paint()..color = KathaInk.marigold,
  );
  for (final dx in [-9.0, 9.0]) {
    canvas.drawCircle(
      Offset(hand.dx + dx, body.bottom + 2),
      2.4,
      Paint()..color = KathaInk.ink,
    );
  }
}

/// A box of sweets from the shop, tied with string, carried by the knot.
void _drawSweetBox(Canvas canvas, Offset hand) {
  final string = Paint()
    ..color = KathaInk.brick
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  canvas.drawLine(hand, hand.translate(-5, 8), string);
  canvas.drawLine(hand, hand.translate(5, 8), string);
  final box = Rect.fromLTRB(
    hand.dx - 12,
    hand.dy + 8,
    hand.dx + 12,
    hand.dy + 22,
  );
  canvas.drawRect(box, Paint()..color = KathaInk.paper);
  canvas.drawRect(
    Rect.fromLTRB(box.left, box.top, box.right, box.top + 4),
    Paint()..color = KathaInk.marigold,
  );
  canvas.drawLine(
    Offset(hand.dx, box.top),
    Offset(hand.dx, box.bottom),
    string,
  );
}
