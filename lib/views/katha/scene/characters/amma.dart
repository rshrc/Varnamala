import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// What Amma has in her hand.
enum AmmaCarrying { suitcase, tiffin, jar, phone, nothing }

/// Dev's mother, arrived from the other end of the country: a printed kurta
/// and a cream dupatta, a maroon cardigan she will not take off in a city
/// that is twenty-four degrees, a grey streak in her bun, and an old
/// hard-shell suitcase with a cloth bag of pickle jars tied to its handle.
///
/// [seated] drops the legs, for the back of an auto.
CutoutRig buildAmma({
  required String id,
  required Vector2 feet,
  double facing = 1,
  bool seated = false,
  AmmaCarrying carrying = AmmaCarrying.nothing,
}) {
  const headRadius = 13.5;
  final skin = Color.lerp(KathaInk.skinWarm, KathaInk.paper, 0.06)!;
  final face = Face(
    facing: facing,
    radius: headRadius,
    skin: skin,
    browWeight: 2,
  );
  final head = RigPart(
    position: Vector2(0, -99),
    priority: 1,
    draw: (canvas, _) => drawHead(
      canvas,
      radius: headRadius,
      skin: skin,
      hair: _ammaHair,
      bindi: true,
    ),
  );
  const cardigan = Color(0xFF7A2E2E);
  final cuff = Color.lerp(cardigan, KathaInk.ink, 0.25)!;
  final phone = carrying == AmmaCarrying.phone;
  // The tiffin is held out in front, the better to be smelled.
  final tiffin =
      carrying == AmmaCarrying.tiffin || carrying == AmmaCarrying.jar;
  final near = Limb(
    position: Vector2(facing * 14, -79),
    restAngle: phone ? -facing * 2.2 : (tiffin ? -facing * 0.9 : -facing * 0.1),
    outward: facing < 0 ? 1 : -1,
    bend: phone ? -facing * 2.05 : (tiffin ? -facing * 0.7 : -facing * 0.15),
    upper: 17,
    fore: 16,
    sleeveLength: 30,
    sleeve: cardigan,
    cuff: cuff,
    skin: skin,
    priority: 3,
    held: phone
        ? drawPhone
        : carrying == AmmaCarrying.jar
        ? (facing > 0 ? _drawPickleJarRight : _drawPickleJarLeft)
        : null,
  );
  final far = Limb(
    position: Vector2(-facing * 14, -79),
    restAngle: facing * 0.12,
    outward: facing < 0 ? -1 : 1,
    bend: facing * 0.15,
    upper: 17,
    fore: 16,
    sleeveLength: 30,
    sleeve: cardigan,
    cuff: cuff,
    skin: skin,
    priority: 2,
    held: carrying == AmmaCarrying.suitcase ? _drawOldSuitcase : null,
  );
  final (left, right) = facing < 0 ? (near, far) : (far, near);
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.brickShade,
    position: feet,
    headRadius: headRadius,
    legs: seated ? null : RigPart(draw: (canvas, _) => _drawAmmaLegs(canvas)),
    torso: RigPart(
      priority: 1,
      draw: (canvas, _) => _drawAmmaTorso(canvas, skin),
    ),
    head: head,
    face: face,
    leftArm: left,
    rightArm: right,
    gestureArm: near,
  );
}

/// Parted in the middle and pulled back into a bun, a streak of grey she
/// has decided is distinguished.
void _ammaHair(Canvas canvas, double r) {
  final hair = Paint()..color = KathaInk.ink;
  canvas.drawCircle(Offset(0, -r * 0.98), r * 0.5, hair);
  canvas.drawPath(
    Path()
      ..moveTo(-r * 1.02, r * 0.12)
      ..cubicTo(-r * 1.12, -r * 0.9, -r * 0.4, -r * 1.22, 0, -r * 1.16)
      ..cubicTo(r * 0.4, -r * 1.22, r * 1.12, -r * 0.9, r * 1.02, r * 0.12)
      ..lineTo(r * 0.86, -r * 0.3)
      ..quadraticBezierTo(r * 0.5, -r * 0.84, 0, -r * 0.8)
      ..quadraticBezierTo(-r * 0.5, -r * 0.84, -r * 0.86, -r * 0.3)
      ..close(),
    hair,
  );
  canvas.drawPath(
    Path()
      ..moveTo(r * 0.12, -r * 1.12)
      ..quadraticBezierTo(r * 0.6, -r * 1.02, r * 0.9, -r * 0.4),
    Paint()
      ..color = KathaInk.paper.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.14
      ..strokeCap = StrokeCap.round,
  );
  // The parting.
  canvas.drawLine(
    Offset(0, -r * 1.14),
    Offset(0, -r * 0.82),
    Paint()
      ..color = _parting
      ..strokeWidth = r * 0.07,
  );
}

/// Sindoor-red in the parting.
const _parting = KathaInk.brick;

void _drawAmmaTorso(Canvas canvas, Color skin) {
  canvas.drawRect(const Rect.fromLTRB(-4, -89, 4, -80), Paint()..color = skin);
  // The kurta: printed, to the knee.
  final kurtaColour = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.15)!;
  final kurta = Path()
    ..moveTo(-11, -84)
    ..quadraticBezierTo(-18, -83, -18, -74)
    ..quadraticBezierTo(-21, -50, -19, -24)
    ..lineTo(19, -24)
    ..quadraticBezierTo(21, -50, 18, -74)
    ..quadraticBezierTo(18, -83, 11, -84)
    ..close();
  canvas.drawPath(kurta, Paint()..color = kurtaColour);
  canvas.save();
  canvas.clipPath(kurta);
  final print = Paint()..color = KathaInk.brick.withValues(alpha: 0.55);
  for (var y = -80.0; y < -24; y += 7) {
    for (var x = -18.0; x < 19; x += 7) {
      canvas.drawCircle(Offset(x + ((y ~/ 7).isEven ? 0 : 3.5), y), 1.1, print);
    }
  }
  canvas.drawRect(
    const Rect.fromLTRB(-20, -29, 20, -24),
    Paint()..color = KathaInk.brick,
  );
  canvas.restore();
  // The cardigan, open down the front.
  const cardigan = Color(0xFF7A2E2E);
  for (final side in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(side * 5, -85)
        ..lineTo(side * 17, -82)
        ..quadraticBezierTo(side * 20, -60, side * 18, -40)
        ..lineTo(side * 7, -42)
        ..close(),
      Paint()..color = cardigan,
    );
  }
  for (final y in [-74.0, -64.0, -54.0]) {
    canvas.drawCircle(Offset(-7.5, y), 1, Paint()..color = KathaInk.paper);
  }
  // The dupatta round her neck, both ends down the front.
  final dupatta = Paint()..color = KathaInk.paper;
  canvas.drawArc(
    const Rect.fromLTRB(-9, -92, 9, -78),
    0.1,
    math.pi - 0.2,
    false,
    Paint()
      ..color = KathaInk.paper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4,
  );
  canvas.drawRect(const Rect.fromLTRB(-9, -84, -4, -44), dupatta);
  canvas.drawRect(const Rect.fromLTRB(4, -84, 9, -50), dupatta);
}

void _drawAmmaLegs(Canvas canvas) {
  // A teal salwar, loose and gathered at the ankle, so the legs read as
  // legs against a pale street.
  final salwar = Paint()
    ..color = Color.lerp(KathaInk.teal, KathaInk.paper, 0.35)!;
  for (final side in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(side * 1, -26)
        ..lineTo(side * 15, -26)
        ..lineTo(side * 12, -6)
        ..lineTo(side * 2, -6)
        ..close(),
      salwar,
    );
  }
  final cuff = Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.15)!;
  canvas.drawRect(const Rect.fromLTRB(-11, -7, -2, -4), cuff);
  canvas.drawRect(const Rect.fromLTRB(2, -7, 11, -4), cuff);
  final jutti = Paint()..color = KathaInk.marigoldShade;
  canvas.drawRRect(
    RRect.fromLTRBR(-13, -4, 0, 0.6, const Radius.circular(3)),
    jutti,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(1, -4, 14, 0.6, const Radius.circular(3)),
    jutti,
  );
}

/// An old hard-shell suitcase with two buckles, and the cloth bag of pickle
/// jars tied to its handle that is the real luggage.
void _drawOldSuitcase(Canvas canvas, Offset hand) {
  final body = RRect.fromLTRBR(
    hand.dx - 15,
    hand.dy + 4,
    hand.dx + 15,
    hand.dy + 38,
    const Radius.circular(3),
  );
  canvas.drawRRect(
    body,
    Paint()..color = Color.lerp(KathaInk.marigoldShade, KathaInk.ink, 0.35)!,
  );
  canvas.drawRect(
    Rect.fromLTRB(body.left, body.top + 15, body.right, body.top + 18),
    Paint()..color = KathaInk.ink.withValues(alpha: 0.35),
  );
  for (final dx in [-8.0, 8.0]) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(hand.dx + dx, body.top + 3),
        width: 4,
        height: 4,
      ),
      Paint()..color = KathaInk.marigold,
    );
  }
  // The pickle bag, hanging off the far side.
  canvas.drawRRect(
    RRect.fromLTRBR(
      hand.dx + 10,
      hand.dy + 2,
      hand.dx + 26,
      hand.dy + 20,
      const Radius.circular(3),
    ),
    Paint()..color = KathaInk.leaf,
  );
  for (final dx in [13.0, 20.0]) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        hand.dx + dx,
        hand.dy - 3,
        hand.dx + dx + 5,
        hand.dy + 4,
        const Radius.circular(1.5),
      ),
      Paint()..color = KathaInk.brick,
    );
  }
}

/// The jar is drawn in the forearm's frame, which her reach tips over;
/// these turn it back upright.
void _drawPickleJarRight(Canvas canvas, Offset hand) =>
    _uprightJar(canvas, hand, 1.6);

void _drawPickleJarLeft(Canvas canvas, Offset hand) =>
    _uprightJar(canvas, hand, -1.6);

void _uprightJar(Canvas canvas, Offset hand, double turn) {
  canvas.save();
  canvas.translate(hand.dx, hand.dy);
  canvas.rotate(turn);
  canvas.translate(-hand.dx, -hand.dy - 6);
  _drawPickleJar(canvas, hand);
  canvas.restore();
}

/// A glass jar of mango pickle, oil-dark, a cloth tied over its mouth.
void _drawPickleJar(Canvas canvas, Offset hand) {
  final jar = RRect.fromLTRBR(
    hand.dx - 7,
    hand.dy - 6,
    hand.dx + 7,
    hand.dy + 12,
    const Radius.circular(3),
  );
  canvas.drawRRect(
    jar,
    Paint()..color = Color.lerp(KathaInk.marigoldShade, KathaInk.brick, 0.4)!,
  );
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 5, hand.dy - 4, hand.dx - 3, hand.dy + 10),
    Paint()..color = KathaInk.paper.withValues(alpha: 0.35),
  );
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 8, hand.dy - 9, hand.dx + 8, hand.dy - 5),
    Paint()..color = KathaInk.brick,
  );
  canvas.drawLine(
    Offset(hand.dx - 8, hand.dy - 6),
    Offset(hand.dx + 8, hand.dy - 6),
    Paint()
      ..color = KathaInk.paper
      ..strokeWidth = 1,
  );
}
