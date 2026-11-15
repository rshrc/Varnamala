import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// Raju's daughter, second year of environmental engineering: a green top,
/// a long braid, reading glasses she pushes up when she is thinking, and the
/// bag of a student who carries her lab with her.
CutoutRig buildDaughter({
  required String id,
  required Vector2 feet,
  double facing = 1,
}) {
  const headRadius = 13.0;
  final skin = Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.3)!;
  final face = Face(facing: facing, radius: headRadius, skin: skin);
  final head = RigPart(
    position: Vector2(0, -100),
    priority: 1,
    draw: (canvas, _) => drawHead(
      canvas,
      radius: headRadius,
      skin: skin,
      hair: _braidHair,
      glasses: true,
    ),
  );
  Limb arm(double side, int priority) => Limb(
    position: Vector2(side * 13, -80),
    restAngle: -side * 0.08,
    outward: -side,
    bend: side * 0.15,
    upper: 17,
    fore: 16,
    sleeveLength: 12,
    sleeve: KathaInk.leaf,
    skin: skin,
    priority: priority,
  );
  final leftArm = arm(-1, 2);
  final rightArm = arm(1, 3);
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.leafShade,
    position: feet,
    headRadius: headRadius,
    legs: RigPart(draw: (canvas, _) => drawJeans(canvas)),
    torso: RigPart(
      priority: 1,
      draw: (canvas, _) => _drawStudentTop(canvas, skin),
    ),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: facing < 0 ? leftArm : rightArm,
  );
}

/// Pulled back tight, a long braid down the back.
void _braidHair(Canvas canvas, double r) {
  final hair = Paint()..color = KathaInk.ink;
  canvas.drawPath(
    Path()
      ..moveTo(-r * 1.02, r * 0.1)
      ..cubicTo(-r * 1.1, -r * 0.9, -r * 0.4, -r * 1.24, 0, -r * 1.18)
      ..cubicTo(r * 0.4, -r * 1.24, r * 1.1, -r * 0.9, r * 1.02, r * 0.1)
      ..lineTo(r * 0.88, -r * 0.34)
      ..quadraticBezierTo(0, -r * 0.92, -r * 0.88, -r * 0.34)
      ..close(),
    hair,
  );
  for (var i = 0; i < 5; i++) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-r * 0.9, r * (0.3 + i * 0.42)),
        width: r * 0.5,
        height: r * 0.5,
      ),
      hair,
    );
  }
  canvas.drawCircle(
    Offset(-r * 0.9, r * 2.4),
    r * 0.16,
    Paint()..color = KathaInk.brick,
  );
}

void _drawStudentTop(Canvas canvas, Color skin) {
  canvas.drawRect(const Rect.fromLTRB(-4, -90, 4, -80), Paint()..color = skin);
  final top = Path()
    ..moveTo(-10, -84)
    ..quadraticBezierTo(-17, -83, -17, -75)
    ..lineTo(-14, -44)
    ..lineTo(14, -44)
    ..lineTo(17, -75)
    ..quadraticBezierTo(17, -83, 10, -84)
    ..close();
  canvas.drawPath(top, Paint()..color = KathaInk.leaf);
  canvas.drawPath(
    Path()
      ..moveTo(-5, -84)
      ..lineTo(0, -76)
      ..lineTo(5, -84)
      ..close(),
    Paint()..color = skin,
  );
  // A bag strap across her, and an ID card on a lanyard.
  canvas.drawLine(
    const Offset(-14, -82),
    const Offset(13, -50),
    Paint()
      ..color = KathaInk.brickShade
      ..strokeWidth = 3,
  );
  canvas.drawRect(
    const Rect.fromLTRB(-3, -66, 4, -57),
    Paint()..color = KathaInk.paper,
  );
}
