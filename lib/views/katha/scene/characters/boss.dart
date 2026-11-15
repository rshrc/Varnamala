import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// The boss: short, round, delighted with himself. A white shirt straining
/// at the buttons, a tie, big glasses, hair combed with care, and a phone
/// in his hand at all times for the morning forwards.
CutoutRig buildBoss({
  required String id,
  required Vector2 feet,
  double facing = -1,
  bool seated = false,
}) {
  const headRadius = 14.5;
  final skin = Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.5)!;
  final face = Face(
    facing: facing,
    radius: headRadius,
    skin: skin,
    mouthDrop: 0.6,
    browWeight: 2.2,
  );
  final head = RigPart(
    position: Vector2(0, -98),
    priority: 1,
    draw: (canvas, _) => drawHead(
      canvas,
      radius: headRadius,
      skin: skin,
      hair: _bossHair,
      glasses: true,
    ),
  );
  final phoneArm = Limb(
    position: Vector2(facing * 16, -76),
    restAngle: facing * 0.5,
    outward: facing < 0 ? 1 : -1,
    bend: facing * 1.3,
    upper: 16,
    fore: 15,
    sleeveLength: 14,
    sleeve: const Color(0xFFFFFFFF),
    skin: skin,
    priority: 3,
    held: drawPhone,
  );
  final otherArm = Limb(
    position: Vector2(-facing * 16, -76),
    restAngle: -facing * 0.12,
    outward: facing < 0 ? -1 : 1,
    bend: -facing * 0.15,
    upper: 16,
    fore: 15,
    sleeveLength: 14,
    sleeve: const Color(0xFFFFFFFF),
    skin: skin,
    priority: 2,
  );
  final (left, right) = facing < 0
      ? (phoneArm, otherArm)
      : (otherArm, phoneArm);
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.ink,
    position: feet,
    headRadius: headRadius,
    legs: seated ? null : RigPart(draw: (canvas, _) => _drawBossLegs(canvas)),
    torso: RigPart(
      priority: 1,
      draw: (canvas, _) => _drawBossTorso(canvas, skin),
    ),
    head: head,
    face: face,
    leftArm: left,
    rightArm: right,
    gestureArm: phoneArm,
  );
}

void _bossHair(Canvas canvas, double r) {
  canvas.drawPath(
    Path()
      ..moveTo(-r * 1.0, -r * 0.1)
      ..cubicTo(-r * 1.08, -r * 0.9, -r * 0.3, -r * 1.24, r * 0.3, -r * 1.12)
      ..cubicTo(r * 0.9, -r * 1.0, r * 1.06, -r * 0.6, r * 1.0, -r * 0.1)
      ..lineTo(r * 0.86, -r * 0.4)
      ..quadraticBezierTo(r * 0.2, -r * 0.92, -r * 0.5, -r * 0.7)
      ..lineTo(-r * 0.86, -r * 0.3)
      ..close(),
    Paint()..color = KathaInk.ink,
  );
  // The parting, combed with great care.
  canvas.drawLine(
    Offset(-r * 0.3, -r * 1.12),
    Offset(-r * 0.5, -r * 0.76),
    Paint()
      ..color = KathaInk.paper.withValues(alpha: 0.45)
      ..strokeWidth = r * 0.06,
  );
}

void _drawBossTorso(Canvas canvas, Color skin) {
  canvas.drawRect(
    const Rect.fromLTRB(-4.5, -87, 4.5, -79),
    Paint()..color = skin,
  );
  // A white shirt round a round belly.
  final shirt = Path()
    ..moveTo(-11, -83)
    ..quadraticBezierTo(-19, -82, -19, -72)
    ..quadraticBezierTo(-24, -52, -16, -38)
    ..lineTo(16, -38)
    ..quadraticBezierTo(24, -52, 19, -72)
    ..quadraticBezierTo(19, -82, 11, -83)
    ..close();
  canvas.drawPath(shirt, Paint()..color = const Color(0xFFFFFFFF));
  canvas.save();
  canvas.clipPath(shirt);
  canvas.drawRect(
    const Rect.fromLTRB(8, -84, 26, -36),
    Paint()..color = KathaInk.ink.withValues(alpha: 0.08),
  );
  canvas.restore();
  // Tie.
  canvas.drawPath(
    Path()
      ..moveTo(-2.4, -83)
      ..lineTo(2.4, -83)
      ..lineTo(1.6, -79)
      ..lineTo(4, -54)
      ..lineTo(0, -50)
      ..lineTo(-4, -54)
      ..lineTo(-1.6, -79)
      ..close(),
    Paint()..color = KathaInk.brick,
  );
  // Buttons doing their best.
  for (final y in [-66.0, -58.0, -46.0]) {
    canvas.drawCircle(
      Offset(7, y),
      0.9,
      Paint()..color = KathaInk.ink.withValues(alpha: 0.4),
    );
  }
  canvas.drawRect(
    const Rect.fromLTRB(-16.5, -40, 16.5, -37),
    Paint()..color = KathaInk.ink,
  );
}

void _drawBossLegs(Canvas canvas) {
  final trousers = Paint()
    ..color = Color.lerp(KathaInk.ink, KathaInk.paper, 0.18)!;
  canvas.drawRect(const Rect.fromLTRB(-12, -39, -1, -3), trousers);
  canvas.drawRect(const Rect.fromLTRB(1, -39, 12, -3), trousers);
  final shoe = Paint()..color = KathaInk.ink;
  canvas.drawRRect(
    RRect.fromLTRBR(-13.5, -4, 0, 0.6, const Radius.circular(2.4)),
    shoe,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(1, -4, 14.5, 0.6, const Radius.circular(2.4)),
    shoe,
  );
}
