import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// Priya: Dev's colleague, quick, kind, and unimpressed by the boss. A
/// marigold kurti over jeans, a ponytail, an office lanyard.
CutoutRig buildPriya({
  required String id,
  required Vector2 feet,
  double facing = -1,
}) {
  const headRadius = 13.5;
  const skin = KathaInk.skinWarm;
  final face = Face(facing: facing, radius: headRadius, skin: skin);
  final head = RigPart(
    position: Vector2(0, -102),
    priority: 1,
    draw: (canvas, _) => drawHead(
      canvas,
      radius: headRadius,
      skin: skin,
      hair: (canvas, r) => _priyaHair(canvas, r, facing),
    ),
  );
  final leftArm = Limb(
    position: Vector2(-13.5, -82),
    restAngle: 0.08,
    outward: 1,
    bend: -0.15,
    upper: 18,
    fore: 17,
    sleeveLength: 22,
    sleeve: KathaInk.marigold,
    skin: skin,
    priority: 2,
  );
  final rightArm = Limb(
    position: Vector2(13.5, -82),
    restAngle: -0.08,
    outward: -1,
    bend: 0.15,
    upper: 18,
    fore: 17,
    sleeveLength: 22,
    sleeve: KathaInk.marigold,
    skin: skin,
    priority: 3,
  );
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.marigoldShade,
    position: feet,
    headRadius: headRadius,
    legs: RigPart(draw: (canvas, _) => drawJeans(canvas)),
    torso: RigPart(priority: 1, draw: (canvas, _) => _drawKurti(canvas)),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: facing < 0 ? leftArm : rightArm,
  );
}

void _priyaHair(Canvas canvas, double r, double facing) {
  final ink = Paint()..color = KathaInk.ink;
  // The ponytail, swinging out behind her.
  canvas.drawPath(
    Path()
      ..moveTo(-facing * r * 0.7, -r * 0.6)
      ..quadraticBezierTo(
        -facing * r * 1.9,
        -r * 0.2,
        -facing * r * 1.5,
        r * 1.2,
      )
      ..quadraticBezierTo(
        -facing * r * 1.3,
        r * 0.2,
        -facing * r * 0.6,
        -r * 0.2,
      )
      ..close(),
    ink,
  );
  canvas.drawPath(
    Path()
      ..moveTo(-r * 1.02, r * 0.1)
      ..cubicTo(-r * 1.1, -r * 0.9, -r * 0.4, -r * 1.22, r * 0.1, -r * 1.16)
      ..cubicTo(r * 0.7, -r * 1.12, r * 1.1, -r * 0.8, r * 1.02, r * 0.1)
      ..lineTo(r * 0.88, -r * 0.1)
      ..cubicTo(
        r * 0.6,
        -r * 0.62,
        facing * r * 0.2,
        -r * 0.82,
        -r * 0.4,
        -r * 0.6,
      )
      ..cubicTo(-r * 0.7, -r * 0.46, -r * 0.84, -r * 0.24, -r * 0.88, r * 0.1)
      ..close(),
    ink,
  );
  canvas.drawCircle(
    Offset(-facing * r * 0.78, -r * 0.48),
    r * 0.14,
    Paint()..color = KathaInk.brick,
  );
}

void _drawKurti(Canvas canvas) {
  const skin = KathaInk.skinWarm;
  canvas.drawRect(const Rect.fromLTRB(-4, -91, 4, -82), Paint()..color = skin);
  // A long kurti, flaring a little below the waist.
  canvas.drawPath(
    Path()
      ..moveTo(-10, -87)
      ..quadraticBezierTo(-17, -86, -17, -78)
      ..lineTo(-15, -52)
      ..lineTo(-18, -32)
      ..lineTo(18, -32)
      ..lineTo(15, -52)
      ..lineTo(17, -78)
      ..quadraticBezierTo(17, -86, 10, -87)
      ..close(),
    Paint()..color = KathaInk.marigold,
  );
  // Embroidered neckline and a hem border.
  canvas.drawPath(
    Path()
      ..moveTo(-5, -87)
      ..quadraticBezierTo(0, -78, 5, -87)
      ..close(),
    Paint()..color = skin,
  );
  final trim = Paint()
    ..color = KathaInk.brick
    ..strokeWidth = 1.6
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
    Path()
      ..moveTo(-6, -87)
      ..quadraticBezierTo(0, -76, 6, -87),
    trim,
  );
  canvas.drawLine(const Offset(-18, -33.5), const Offset(18, -33.5), trim);
  // The lanyard and her office ID.
  canvas.drawPath(
    Path()
      ..moveTo(-5, -86)
      ..lineTo(-1, -66)
      ..lineTo(1, -66)
      ..lineTo(5, -86),
    Paint()
      ..color = KathaInk.teal
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(-4, -66, 4, -56, const Radius.circular(1.2)),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  canvas.drawRect(
    const Rect.fromLTRB(-2.6, -64, 2.6, -60.6),
    Paint()..color = KathaInk.teal,
  );
}
