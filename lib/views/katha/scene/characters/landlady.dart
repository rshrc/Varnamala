import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/characters/shared_parts.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/limb.dart';
import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// The landlady. Standing in her doorway with her arms folded: a cotton
/// saree with a marigold border, the pallu over her shoulder, a bun with a
/// string of jasmine, a bindi, and reading glasses on a chain - all the
/// better to look over at prospective tenants.
CutoutRig buildLandlady({
  required String id,
  required Vector2 feet,
  bool ladle = false,
}) {
  const headRadius = 13.5;
  final skin = Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.25)!;
  final face = Face(facing: -1, radius: headRadius, skin: skin, browWeight: 2);
  final head = RigPart(
    position: Vector2(0, -101),
    priority: 1,
    draw: (canvas, _) => drawHead(
      canvas,
      radius: headRadius,
      skin: skin,
      hair: _landladyHair,
      bindi: true,
      glasses: true,
    ),
  );
  // Arms folded across the chest: each forearm bends in front of the body.
  final leftArm = Limb(
    position: Vector2(-14, -80),
    restAngle: 0.08,
    outward: 1,
    bend: -1.75,
    upper: 17,
    fore: 17,
    sleeveLength: 9,
    sleeve: KathaInk.brick,
    skin: skin,
    priority: 2,
  );
  final rightArm = Limb(
    position: Vector2(14, -80),
    restAngle: ladle ? -0.35 : -0.08,
    outward: -1,
    bend: ladle ? 0.5 : 1.75,
    held: ladle ? _drawLadle : null,
    upper: 17,
    fore: 17,
    sleeveLength: 9,
    sleeve: KathaInk.brick,
    skin: skin,
    priority: 3,
  );
  return CutoutRig(
    actorId: id,
    linkColor: KathaInk.marigold,
    position: feet,
    headRadius: headRadius,
    legs: RigPart(draw: (canvas, _) => _drawSareeSkirt(canvas)),
    torso: RigPart(
      priority: 1,
      draw: (canvas, _) => _drawSareeTop(canvas, skin),
    ),
    head: head,
    face: face,
    leftArm: leftArm,
    rightArm: rightArm,
    gestureArm: leftArm,
  );
}

/// Hair parted in the middle and pulled back into a bun, jasmine around it.
void _landladyHair(Canvas canvas, double r) {
  final ink = Paint()..color = KathaInk.ink;
  canvas.drawCircle(Offset(r * 0.78, -r * 0.5), r * 0.5, ink);
  final jasmine = Paint()..color = const Color(0xFFFFFFFF);
  for (var i = 0; i < 7; i++) {
    final a = -0.4 + i * 0.42;
    canvas.drawCircle(
      Offset(
        r * 0.78 + math.cos(a) * r * 0.54,
        -r * 0.5 + math.sin(a) * r * 0.54,
      ),
      r * 0.1,
      jasmine,
    );
  }
  canvas.drawPath(
    Path()
      ..moveTo(-r * 1.02, r * 0.12)
      ..cubicTo(-r * 1.1, -r * 0.9, -r * 0.4, -r * 1.2, 0, -r * 1.14)
      ..cubicTo(r * 0.4, -r * 1.2, r * 1.1, -r * 0.9, r * 1.02, r * 0.12)
      ..lineTo(r * 0.86, r * 0.02)
      ..cubicTo(r * 0.8, -r * 0.5, r * 0.3, -r * 0.74, 0, -r * 0.8)
      ..cubicTo(-r * 0.3, -r * 0.74, -r * 0.8, -r * 0.5, -r * 0.86, r * 0.02)
      ..close(),
    ink,
  );
  // Grey streaks at the parting: she has seen a hundred tenants come and go.
  canvas.drawLine(
    Offset(0, -r * 1.1),
    Offset(-r * 0.3, -r * 0.82),
    Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.5)
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round,
  );
}

void _drawSareeSkirt(Canvas canvas) {
  // Pleats fall straight to the ground.
  final saree = Path()
    ..moveTo(-15, -50)
    ..lineTo(15, -50)
    ..lineTo(19, 0)
    ..lineTo(-19, 0)
    ..close();
  canvas.drawPath(saree, Paint()..color = KathaInk.leaf);
  final pleat = Paint()
    ..color = KathaInk.leafShade
    ..strokeWidth = 1.1;
  for (final x in [-4.0, 0.0, 4.0]) {
    canvas.drawLine(Offset(x * 0.8, -44), Offset(x * 1.4, -1), pleat);
  }
  canvas.drawRect(
    const Rect.fromLTRB(-19, -5, 19, 0),
    Paint()..color = KathaInk.marigold,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(-14, -1, -3, 2, const Radius.circular(1.5)),
    Paint()..color = KathaInk.brickShade,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(3, -1, 14, 2, const Radius.circular(1.5)),
    Paint()..color = KathaInk.brickShade,
  );
}

void _drawSareeTop(Canvas canvas, Color skin) {
  canvas.drawRect(const Rect.fromLTRB(-4, -90, 4, -80), Paint()..color = skin);
  // Blouse.
  canvas.drawPath(
    Path()
      ..moveTo(-10, -86)
      ..quadraticBezierTo(-16, -85, -16.5, -78)
      ..lineTo(-15, -50)
      ..lineTo(15, -50)
      ..lineTo(16.5, -78)
      ..quadraticBezierTo(16, -85, 10, -86)
      ..close(),
    Paint()..color = KathaInk.brick,
  );
  canvas.drawPath(
    Path()
      ..moveTo(-5, -86)
      ..quadraticBezierTo(0, -79, 5, -86)
      ..close(),
    Paint()..color = skin,
  );
  // Pallu: from the waist on her right, up over her left shoulder.
  final pallu = Path()
    ..moveTo(-15, -52)
    ..lineTo(-6, -52)
    ..lineTo(13, -86)
    ..lineTo(17, -80)
    ..lineTo(16, -50)
    ..close();
  canvas.drawPath(pallu, Paint()..color = KathaInk.leaf);
  canvas.drawLine(
    const Offset(-6, -52),
    const Offset(13, -86),
    Paint()
      ..color = KathaInk.marigold
      ..strokeWidth = 2.6,
  );
  // Waist where the saree tucks in.
  canvas.drawRect(
    const Rect.fromLTRB(-15, -52, 15, -48),
    Paint()..color = KathaInk.leafShade,
  );
  // Glasses chain, hanging round the neck.
  canvas.drawArc(
    const Rect.fromLTRB(-7, -92, 7, -76),
    0.2,
    math.pi - 0.4,
    false,
    Paint()
      ..color = KathaInk.marigold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8,
  );
}

/// A steel ladle, for serving one more spoonful.
void _drawLadle(Canvas canvas, Offset hand) {
  final steel = Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!;
  canvas.drawRect(
    Rect.fromLTRB(hand.dx - 1, hand.dy - 2, hand.dx + 1, hand.dy + 18),
    steel,
  );
  canvas.drawArc(
    Rect.fromCenter(center: hand.translate(0, 18), width: 10, height: 8),
    0,
    math.pi,
    true,
    steel,
  );
}
