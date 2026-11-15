import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/idle_bit.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// `bg.pg_door`: the landlady's house. Pastel walls, a grilled window, a
/// tulsi planter, a kolam freshly drawn at the door, bougainvillea over the
/// compound wall, a coconut tree, and her son's scooter parked where nobody
/// else is allowed to park.
class PgDoorBackdrop extends PositionComponent {
  PgDoorBackdrop({this.night = false}) : super(priority: -10);

  /// The same door after dark: a deep sky, a moon, light from the hall.
  final bool night;

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    _paint(canvas);
    if (night) _darken(canvas);
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    // Late afternoon: the sky has gone warm.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.marigold, 0.12)!,
    );
    canvas.drawCircle(
      const Offset(60, 40),
      13,
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.75),
    );

    _coconutTree(canvas);
    _house(canvas);
    _compoundWall(canvas);
    _scooter(canvas);

    // The lane: no kerb here, just packed earth and a gutter.
    canvas.drawRect(
      const Rect.fromLTRB(0, 206, kathaWorldWidth, 224),
      Paint()..color = KathaInk.footpath,
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 224, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = Color.lerp(KathaInk.footpath, KathaInk.ink, 0.1)!,
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 222, kathaWorldWidth, 225),
      Paint()..color = KathaInk.ink.withValues(alpha: 0.3),
    );
    _kolam(canvas, const Offset(272, 214));
  }

  static void _darken(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      Paint()
        ..color = Color.lerp(
          KathaInk.ink,
          KathaInk.teal,
          0.3,
        )!.withValues(alpha: 0.55),
    );
    // Stars, and a moon where the sun was.
    final star = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8);
    for (final (x, y) in [
      (20.0, 18.0),
      (140.0, 30.0),
      (170.0, 12.0),
      (230.0, 24.0),
      (330.0, 14.0),
      (380.0, 34.0),
    ]) {
      canvas.drawCircle(Offset(x, y), 1, star);
    }
    canvas.drawCircle(
      const Offset(60, 40),
      11,
      Paint()..color = KathaInk.paper,
    );
    canvas.drawCircle(
      const Offset(65, 36),
      10,
      Paint()..color = Color.lerp(KathaInk.ink, KathaInk.teal, 0.3)!,
    );
    // Warm light from the open door and the window.
    canvas.drawRect(
      const Rect.fromLTRB(252, 124, 294, 206),
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      Path()
        ..moveTo(252, 206)
        ..lineTo(294, 206)
        ..lineTo(310, 224)
        ..lineTo(236, 224)
        ..close(),
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.25),
    );
    canvas.drawRect(
      const Rect.fromLTRB(352, 112, 384, 158),
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.45),
    );
  }

  static void _house(Canvas canvas) {
    final wall = Paint()
      ..color = Color.lerp(KathaInk.paper, KathaInk.teal, 0.28)!;
    canvas.drawRect(const Rect.fromLTRB(180, 64, 400, 206), wall);
    // Sunshade over the door and a parapet on top.
    canvas.drawRect(
      const Rect.fromLTRB(176, 58, 400, 66),
      Paint()..color = KathaInk.paper,
    );
    canvas.drawRect(
      const Rect.fromLTRB(236, 108, 310, 114),
      Paint()..color = KathaInk.paper,
    );
    // Door: open, a dark hall behind it, a wooden frame.
    canvas.drawRect(
      const Rect.fromLTRB(248, 120, 298, 206),
      Paint()..color = KathaInk.brickShade,
    );
    canvas.drawRect(
      const Rect.fromLTRB(252, 124, 294, 206),
      Paint()..color = KathaInk.interior,
    );
    // A string of mango leaves over the door, for luck.
    for (var i = 0; i < 8; i++) {
      final x = 254 + i * 5.4;
      canvas.drawPath(
        Path()
          ..moveTo(x, 124)
          ..quadraticBezierTo(x + 2.4, 129, x + 1, 133)
          ..quadraticBezierTo(x - 1, 129, x, 124),
        Paint()..color = KathaInk.leaf,
      );
    }
    // Nameplate: blank, because its text comes from the telling.
    canvas.drawRRect(
      RRect.fromLTRBR(304, 132, 326, 142, const Radius.circular(1.5)),
      Paint()..color = KathaInk.teal,
    );
    // Window with a grille, and a curtain half drawn.
    canvas.drawRect(
      const Rect.fromLTRB(330, 112, 384, 158),
      Paint()..color = KathaInk.interior,
    );
    canvas.drawRect(
      const Rect.fromLTRB(330, 112, 352, 158),
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.75),
    );
    final grille = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 1.2;
    for (var x = 336.0; x < 384; x += 8) {
      canvas.drawLine(Offset(x, 112), Offset(x, 158), grille);
    }
    canvas.drawLine(const Offset(330, 135), const Offset(384, 135), grille);
    canvas.drawRect(
      const Rect.fromLTRB(326, 158, 388, 162),
      Paint()..color = KathaInk.paper,
    );
    // Upstairs: a balcony with a sari drying on the rail.
    canvas.drawRect(
      const Rect.fromLTRB(200, 76, 240, 100),
      Paint()..color = KathaInk.interior,
    );
    canvas.drawRect(
      const Rect.fromLTRB(196, 96, 244, 100),
      Paint()..color = KathaInk.paper,
    );
    canvas.drawPath(
      Path()
        ..moveTo(204, 96)
        ..lineTo(234, 96)
        ..lineTo(232, 110)
        ..quadraticBezierTo(220, 114, 206, 110)
        ..close(),
      Paint()..color = KathaInk.brick,
    );
    // Tulsi planter by the door.
    canvas.drawRect(
      const Rect.fromLTRB(216, 184, 232, 206),
      Paint()..color = KathaInk.brick,
    );
    canvas.drawRect(
      const Rect.fromLTRB(214, 182, 234, 186),
      Paint()..color = KathaInk.paper,
    );
    final leaf = Paint()..color = KathaInk.leaf;
    for (final (x, y) in [
      (220.0, 176.0),
      (226.0, 172.0),
      (230.0, 177.0),
      (224.0, 179.0),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 6, height: 8),
        leaf,
      );
    }
  }

  /// The compound wall and its open gate, bougainvillea spilling over.
  static void _compoundWall(Canvas canvas) {
    final wall = Paint()
      ..color = Color.lerp(KathaInk.paper, KathaInk.marigold, 0.25)!;
    canvas.drawRect(const Rect.fromLTRB(0, 168, 160, 206), wall);
    canvas.drawRect(
      const Rect.fromLTRB(0, 164, 162, 170),
      Paint()..color = KathaInk.paper,
    );
    // Gate pillar and the gate, swung open against the wall.
    canvas.drawRect(const Rect.fromLTRB(160, 150, 172, 206), wall);
    canvas.drawRect(
      const Rect.fromLTRB(158, 146, 174, 152),
      Paint()..color = KathaInk.paper,
    );
    final grille = Paint()
      ..color = KathaInk.teal
      ..strokeWidth = 1.6;
    canvas.drawRect(
      const Rect.fromLTRB(120, 160, 158, 204),
      Paint()
        ..color = KathaInk.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (var x = 126.0; x < 158; x += 6) {
      canvas.drawLine(Offset(x, 160), Offset(x, 204), grille);
    }
    // A board hung on the gate: the To-Let sign, its words from the telling.
    canvas.drawRect(
      const Rect.fromLTRB(126, 170, 152, 184),
      Paint()..color = KathaInk.marigold,
    );
    canvas.drawRect(
      const Rect.fromLTRB(126, 170, 152, 184),
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    // Bougainvillea over the wall.
    final leaf = Paint()..color = KathaInk.leaf;
    final flower = Paint()
      ..color = Color.lerp(KathaInk.brick, KathaInk.paper, 0.15)!;
    final random = math.Random(3);
    for (var i = 0; i < 26; i++) {
      final x = random.nextDouble() * 110;
      final y = 156 + random.nextDouble() * 16;
      canvas.drawCircle(
        Offset(x, y),
        4 + random.nextDouble() * 3,
        i % 3 == 0 ? leaf : flower,
      );
    }
  }

  static void _coconutTree(Canvas canvas) {
    final trunk = Paint()
      ..color = KathaInk.brickShade
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(90, 170)
        ..quadraticBezierTo(82, 100, 104, 42),
      trunk,
    );
    final frond = Paint()
      ..color = KathaInk.leaf
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final (dx, dy) in [
      (-34.0, 10.0),
      (-26.0, -14.0),
      (0.0, -24.0),
      (28.0, -12.0),
      (36.0, 12.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(104, 42)
          ..quadraticBezierTo(
            104 + dx * 0.6,
            42 + dy - 8,
            104 + dx,
            42 + dy + 10,
          ),
        frond,
      );
    }
    for (final dx in [-4.0, 2.0, 7.0]) {
      canvas.drawCircle(
        Offset(104 + dx, 47),
        3.4,
        Paint()..color = KathaInk.marigoldShade,
      );
    }
  }

  /// Her son's scooter: a step-through with a rounded rear cowl, a flat
  /// floorboard, the front apron rising to the handlebar and headlamp.
  static void _scooter(Canvas canvas) {
    final ink = Paint()..color = KathaInk.ink;
    final body = Paint()..color = KathaInk.teal;
    final shade = Paint()
      ..color = Color.lerp(KathaInk.teal, KathaInk.ink, 0.3)!;
    // Wheels: small, the way scooter wheels are.
    for (final x in [344.0, 386.0]) {
      canvas.drawCircle(Offset(x, 214), 7, ink);
      canvas.drawCircle(Offset(x, 214), 2.6, Paint()..color = KathaInk.paper);
    }
    // Rear cowl over the back wheel, and the seat on top.
    canvas.drawPath(
      Path()
        ..moveTo(368, 210)
        ..quadraticBezierTo(366, 192, 382, 190)
        ..quadraticBezierTo(398, 191, 396, 210)
        ..close(),
      body,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(366, 184, 394, 190, const Radius.circular(3)),
      ink,
    );
    // Floorboard joining front and back.
    canvas.drawRect(const Rect.fromLTRB(348, 205, 372, 210), shade);
    // Front apron, rising from the floorboard to the steering column.
    canvas.drawPath(
      Path()
        ..moveTo(340, 208)
        ..quadraticBezierTo(338, 194, 348, 182)
        ..lineTo(354, 182)
        ..quadraticBezierTo(352, 196, 354, 210)
        ..close(),
      body,
    );
    // Mudguard over the front wheel.
    canvas.drawArc(
      const Rect.fromLTRB(335, 205, 353, 223),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = KathaInk.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // Steering column, handlebar and headlamp.
    canvas.drawRect(const Rect.fromLTRB(348, 172, 352, 184), ink);
    canvas.drawLine(
      const Offset(342, 172),
      const Offset(360, 172),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      const Offset(347, 177),
      2.6,
      Paint()..color = KathaInk.paper,
    );
  }

  /// A kolam: rice-flour loops round a grid of dots, drawn fresh every
  /// morning at the threshold.
  static void _kolam(Canvas canvas, Offset c) {
    final flour = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final dot = Paint()..color = const Color(0xFFFFFFFF);
    for (var i = -2; i <= 2; i++) {
      for (var j = -1; j <= 1; j++) {
        canvas.drawCircle(c + Offset(i * 6.0, j * 3.0), 0.7, dot);
      }
    }
    canvas.drawOval(Rect.fromCenter(center: c, width: 34, height: 10), flour);
    for (final dx in [-12.0, 0.0, 12.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: c + Offset(dx, 0), width: 10, height: 7),
        flour,
      );
    }
  }
}

/// A striped palm squirrel running along the compound wall, then stopping
/// to flick its tail.
class WallSquirrel extends IdleBit {
  WallSquirrel() : super(seconds: 1.6, chance: 0.6, position: Vector2(40, 164));

  static final _fur = Color.lerp(KathaInk.khakiShade, KathaInk.ink, 0.2)!;

  @override
  void render(Canvas canvas) {
    final dash = math.sin(t * math.pi) * 14;
    canvas.save();
    canvas.translate(dash, 0);
    final fur = Paint()..color = _fur;
    final flick = math.sin(t * math.pi * 6) * 0.5 * (1 - t);
    canvas.save();
    canvas.translate(-5, -3);
    canvas.rotate(-0.6 + flick);
    canvas.drawOval(const Rect.fromLTRB(-3, -12, 2, 0), fur);
    canvas.restore();
    canvas.drawOval(const Rect.fromLTRB(-6, -6, 5, 0), fur);
    canvas.drawCircle(const Offset(5, -4), 2.6, fur);
    final stripe = Paint()
      ..color = KathaInk.paper.withValues(alpha: 0.7)
      ..strokeWidth = 0.6;
    canvas.drawLine(const Offset(-4, -4), const Offset(3, -4.4), stripe);
    canvas.drawCircle(
      const Offset(6, -4.6),
      0.5,
      Paint()..color = KathaInk.ink,
    );
    canvas.restore();
  }
}
