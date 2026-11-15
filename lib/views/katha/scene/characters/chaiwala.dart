import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// Chai Anna: runs the stall, remembers every order, has seen every kind of
/// newcomer. Balding, a grey moustache, a white vest, a towel on his shoulder
/// and a pencil behind his ear for the tab nobody pays. Drawn from the waist
/// up; the counter hides the rest.
CutoutRig buildChaiwala({required String id, required Vector2 waist}) {
  const headRadius = 13.5;
  const skin = KathaInk.skinDeep;
  final face = Face(
    facing: -1,
    radius: headRadius,
    skin: skin,
    mouthDrop: 1.4,
    browWeight: 2.4,
  );
  final head = RigPart(
    position: Vector2(0, -48),
    priority: 1,
    draw: (canvas, _) => drawHead(
      canvas,
      radius: headRadius,
      skin: skin,
      hair: _chaiwalaHair,
      moustache: true,
    ),
  );
  final leftArm = Limb(
    position: Vector2(-13, -28),
    restAngle: 0.35,
    outward: 1,
    bend: 0.6,
    upper: 16,
    fore: 15,
    sleeveLength: 0,
    sleeve: skin,
    skin: skin,
    priority: 3,
    held: _drawTeaPot,
  );
  final rightArm = Limb(
    position: Vector2(13, -28),
    restAngle: -0.35,
    outward: -1,
    bend: -0.6,
    upper: 16,
    fore: 15,
    sleeveLength: 0,
    sleeve: skin,
    skin: skin,
    priority: 3,
    held: drawTeaGlass,
  );
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.leaf,
    position: waist,
    headRadius: headRadius,
    torso: RigPart(draw: (canvas, _) => _drawChaiwalaTorso(canvas)),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: leftArm,
  );
}

/// Bald on top, a fringe of grey at the sides, and the pencil.
void _chaiwalaHair(Canvas canvas, double r) {
  final grey = Paint()..color = Color.lerp(KathaInk.ink, KathaInk.paper, 0.55)!;
  for (final side in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(side * r * 1.02, r * 0.2)
        ..quadraticBezierTo(
          side * r * 1.1,
          -r * 0.5,
          side * r * 0.62,
          -r * 0.82,
        )
        ..lineTo(side * r * 0.7, -r * 0.4)
        ..quadraticBezierTo(side * r * 0.86, -r * 0.1, side * r * 0.86, r * 0.2)
        ..close(),
      grey,
    );
  }
  // A shine on the dome.
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(-r * 0.3, -r * 0.72),
      width: r * 0.4,
      height: r * 0.16,
    ),
    Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.35),
  );
  canvas.save();
  canvas.translate(r * 0.94, -r * 0.2);
  canvas.rotate(-0.5);
  canvas.drawRRect(
    RRect.fromLTRBR(-1.2, -r * 0.8, 1.2, 0, const Radius.circular(1)),
    Paint()..color = KathaInk.marigold,
  );
  canvas.restore();
}

void _drawChaiwalaTorso(Canvas canvas) {
  const skin = KathaInk.skinDeep;
  canvas.drawRect(
    const Rect.fromLTRB(-4.5, -38, 4.5, -30),
    Paint()..color = skin,
  );
  // Shoulders and arms are bare: a sleeveless vest.
  canvas.drawPath(
    Path()
      ..moveTo(-16, -32)
      ..quadraticBezierTo(-19, -28, -18, -18)
      ..lineTo(-16, 6)
      ..lineTo(16, 6)
      ..lineTo(18, -18)
      ..quadraticBezierTo(19, -28, 16, -32)
      ..close(),
    Paint()..color = skin,
  );
  final vest = Path()
    ..moveTo(-10, -32)
    ..quadraticBezierTo(0, -20, 10, -32)
    ..lineTo(12, -32)
    ..lineTo(14, 6)
    ..lineTo(-14, 6)
    ..lineTo(-12, -32)
    ..close();
  canvas.drawPath(vest, Paint()..color = const Color(0xFFFFFFFF));
  final rib = Paint()
    ..color = KathaInk.ink.withValues(alpha: 0.08)
    ..strokeWidth = 0.8;
  for (var x = -10.0; x <= 10; x += 3) {
    canvas.drawLine(Offset(x, -22), Offset(x, 6), rib);
  }
  // The towel over his shoulder: marigold, checked.
  canvas.save();
  canvas.translate(-12, -33);
  canvas.rotate(-0.1);
  canvas.drawRRect(
    RRect.fromLTRBR(-4, -1, 4, 20, const Radius.circular(1.4)),
    Paint()..color = KathaInk.marigold,
  );
  final check = Paint()
    ..color = KathaInk.brick.withValues(alpha: 0.7)
    ..strokeWidth = 0.9;
  for (var y = 3.0; y < 19; y += 4.5) {
    canvas.drawLine(Offset(-4, y), Offset(4, y), check);
  }
  canvas.restore();
}

/// The tea pot, a long-spouted aluminium kettle.
void _drawTeaPot(Canvas canvas, Offset hand) {
  final metal = Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!;
  canvas.drawRRect(
    RRect.fromLTRBR(
      hand.dx - 6,
      hand.dy - 2,
      hand.dx + 6,
      hand.dy + 10,
      const Radius.circular(3),
    ),
    metal,
  );
  canvas.drawLine(
    Offset(hand.dx - 5, hand.dy + 2),
    Offset(hand.dx - 12, hand.dy - 3),
    metal
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round,
  );
}
