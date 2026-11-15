import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// Raju Autowala: the auto driver. Seated, facing left toward Dev. Only the
/// upper body is drawn; the auto hides the rest.
///
/// [facing] +1 turns him round to talk to his passenger.
CutoutRig buildRaju({
  required String id,
  required Vector2 seat,
  double facing = -1,
  bool standing = false,
}) {
  const headRadius = 13.0;
  const skin = KathaInk.skinDeep;
  final face = Face(
    facing: facing,
    radius: headRadius,
    skin: skin,
    mouthDrop: 1.6,
    browWeight: 2.3,
  );
  final head = RigPart(
    position: Vector2(0, -47),
    priority: 1,
    draw: (canvas, _) => drawHead(
      canvas,
      radius: headRadius,
      skin: skin,
      hair: _rajuHair,
      moustache: true,
    ),
  );
  // The arm nearer Dev reaches forward to the handlebar; the far one rests at
  // his side and comes into play when he shrugs.
  final leftArm = Limb(
    position: Vector2(-13, -27),
    restAngle: 0.42,
    outward: 1,
    bend: 0.85,
    upper: 15,
    fore: 15,
    sleeveLength: 11,
    sleeve: KathaInk.khaki,
    cuff: KathaInk.khakiShade,
    skin: skin,
    priority: 3,
  );
  final rightArm = Limb(
    position: Vector2(13, -27),
    restAngle: -0.16,
    outward: -1,
    bend: -0.3,
    upper: 15,
    fore: 15,
    sleeveLength: 11,
    sleeve: KathaInk.khaki,
    cuff: KathaInk.khakiShade,
    skin: skin,
    priority: 0,
  );
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.brick,
    position: seat,
    headRadius: headRadius,
    legs: standing ? RigPart(draw: (canvas, _) => _drawRajuLegs(canvas)) : null,
    torso: RigPart(priority: 1, draw: (canvas, _) => _drawRajuTorso(canvas)),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: facing < 0 ? leftArm : rightArm,
  );
}

/// Khaki trousers and chappals, for when Raju is out of his auto.
void _drawRajuLegs(Canvas canvas) {
  final trousers = Paint()..color = KathaInk.khakiShade;
  canvas.drawPath(
    Path()
      ..moveTo(-14, 2)
      ..lineTo(14, 2)
      ..lineTo(12, 44)
      ..lineTo(2, 44)
      ..lineTo(0, 12)
      ..lineTo(-2, 44)
      ..lineTo(-12, 44)
      ..close(),
    trousers,
  );
  final sole = Paint()..color = KathaInk.brickShade;
  final strap = Paint()..color = KathaInk.ink;
  for (final x in [-7.0, 7.0]) {
    canvas.drawRRect(
      RRect.fromLTRBR(x - 6.5, 43, x + 6.5, 46.5, const Radius.circular(1.8)),
      sole,
    );
    canvas.drawRect(Rect.fromLTRB(x - 3, 42, x + 3, 44), strap);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, 43.4), width: 8, height: 3.4),
      Paint()..color = KathaInk.skinDeep,
    );
  }
}

/// Oiled and combed flat with a side parting, greying at the temples.
void _rajuHair(Canvas canvas, double r) {
  final path = Path()
    ..moveTo(-r * 1.02, r * 0.3)
    ..cubicTo(-r * 1.14, -r * 0.8, -r * 0.5, -r * 1.24, r * 0.1, -r * 1.2)
    ..cubicTo(r * 0.8, -r * 1.16, r * 1.14, -r * 0.7, r * 1.02, r * 0.3)
    ..lineTo(r * 0.88, r * 0.22)
    ..lineTo(r * 0.84, -r * 0.4)
    ..cubicTo(r * 0.4, -r * 0.5, -r * 0.2, -r * 0.44, -r * 0.6, -r * 0.72)
    ..cubicTo(-r * 0.76, -r * 0.5, -r * 0.84, -r * 0.3, -r * 0.86, r * 0.22)
    ..close();
  canvas.drawPath(path, Paint()..color = KathaInk.ink);
  final grey = Paint()..color = KathaInk.paper.withValues(alpha: 0.4);
  canvas.drawRect(Rect.fromLTWH(r * 0.84, -r * 0.2, r * 0.16, r * 0.4), grey);
  canvas.drawRect(Rect.fromLTWH(-r * 1.0, -r * 0.16, r * 0.14, r * 0.4), grey);
  // Sunglasses pushed up into the hair: he has been driving since dawn.
  final lens = Paint()..color = KathaInk.teal;
  for (final x in [-r * 0.62, r * 0.02]) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        x,
        -r * 0.98,
        x + r * 0.5,
        -r * 0.66,
        Radius.circular(r * 0.14),
      ),
      lens,
    );
    canvas.drawLine(
      Offset(x + r * 0.1, -r * 0.9),
      Offset(x + r * 0.26, -r * 0.9),
      Paint()
        ..color = KathaInk.paper.withValues(alpha: 0.7)
        ..strokeWidth = r * 0.06
        ..strokeCap = StrokeCap.round,
    );
  }
  canvas.drawLine(
    Offset(-r * 0.12, -r * 0.84),
    Offset(r * 0.02, -r * 0.84),
    Paint()
      ..color = KathaInk.teal
      ..strokeWidth = r * 0.08,
  );
}

void _drawRajuTorso(Canvas canvas) {
  const skin = KathaInk.skinDeep;
  canvas.drawRect(const Rect.fromLTRB(-4, -37, 4, -29), Paint()..color = skin);
  canvas.drawOval(
    const Rect.fromLTRB(-4, -36.5, 4, -32),
    Paint()..color = Color.lerp(skin, KathaInk.ink, 0.25)!,
  );
  final shirt = Path()
    ..moveTo(-10, -32)
    ..quadraticBezierTo(-17, -31, -17.5, -24)
    ..lineTo(-15, 5)
    ..lineTo(15, 5)
    ..lineTo(17.5, -24)
    ..quadraticBezierTo(17, -31, 10, -32)
    ..close();
  canvas.drawPath(shirt, Paint()..color = KathaInk.khaki);
  canvas.save();
  canvas.clipPath(shirt);
  canvas.drawRect(
    const Rect.fromLTRB(8, -32, 18, 5),
    Paint()..color = KathaInk.ink.withValues(alpha: 0.12),
  );
  canvas.restore();

  final dark = Paint()..color = KathaInk.khakiShade;
  // Open collar.
  canvas.drawPath(
    Path()
      ..moveTo(-5.4, -32)
      ..lineTo(0, -23.5)
      ..lineTo(5.4, -32)
      ..close(),
    Paint()..color = skin,
  );
  for (final side in [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(side * 8.5, -32.5)
        ..lineTo(side * 5, -33)
        ..lineTo(side * 0.6, -24)
        ..lineTo(side * 5.6, -26.5)
        ..close(),
      dark,
    );
    // Epaulette: the uniform's giveaway.
    canvas.drawRRect(
      RRect.fromLTRBR(
        side < 0 ? -16.5 : 9.5,
        -31.2,
        side < 0 ? -9.5 : 16.5,
        -28.4,
        const Radius.circular(1.2),
      ),
      dark,
    );
    // Flap pocket with a button.
    final left = side < 0 ? -12.5 : 4.5;
    canvas.drawRRect(
      RRect.fromLTRBR(left, -19, left + 8, -10, const Radius.circular(1.2)),
      dark,
    );
    canvas.drawRect(
      Rect.fromLTRB(left, -19, left + 8, -16.4),
      Paint()..color = Color.lerp(KathaInk.khakiShade, KathaInk.ink, 0.15)!,
    );
    canvas.drawCircle(
      Offset(left + 4, -16.2),
      0.9,
      Paint()..color = KathaInk.paper,
    );
  }
  final seam = Paint()
    ..color = KathaInk.ink.withValues(alpha: 0.28)
    ..strokeWidth = 1;
  canvas.drawLine(const Offset(0, -23.5), const Offset(0, 5), seam);

  // The towel over his far shoulder: brick with pale checks.
  canvas.save();
  canvas.translate(12.5, -31);
  canvas.rotate(0.1);
  const towel = Rect.fromLTRB(-3.6, -1, 3.6, 22);
  canvas.drawRRect(
    RRect.fromRectAndRadius(towel, const Radius.circular(1.4)),
    Paint()..color = KathaInk.brick,
  );
  final check = Paint()
    ..color = KathaInk.paper.withValues(alpha: 0.75)
    ..strokeWidth = 0.9;
  for (var y = 3.0; y < 21; y += 4.5) {
    canvas.drawLine(Offset(-3.6, y), Offset(3.6, y), check);
  }
  canvas.drawLine(const Offset(0, -1), const Offset(0, 22), check);
  canvas.restore();
}
