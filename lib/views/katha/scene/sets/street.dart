import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/idle_bit.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// `bg.street_auto`: a Nagara street. Skyline, a chai stall and a shuttered
/// shop, a footpath with the black-and-yellow kerb every Indian city paints,
/// and the road.
///
/// Drawn once into a [Picture] and replayed, since nothing in it moves.
class StreetBackdrop extends PositionComponent {
  StreetBackdrop({this.overcast = false}) : super(priority: -10);

  /// The same street under monsoon cloud: no sun, a heavier sky.
  final bool overcast;

  late final Picture _picture = recordPicture(overcast);

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static Picture recordPicture(bool overcast) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    _paint(canvas, overcast: overcast);
    return recorder.endRecording();
  }

  static void _paint(Canvas canvas, {bool overcast = false}) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = KathaInk.paper,
    );

    if (overcast) {
      _clouds(canvas);
    } else {
      _sky(canvas);
    }

    // Far: the skyline.
    const baseline = 182.0;
    const blocks = [
      (0.0, 46.0, 96.0),
      (44.0, 38.0, 128.0),
      (80.0, 54.0, 82.0),
      (132.0, 40.0, 112.0),
      (170.0, 62.0, 90.0),
      (230.0, 34.0, 130.0),
      (262.0, 58.0, 100.0),
      (318.0, 40.0, 84.0),
      (356.0, 48.0, 118.0),
    ];
    final building = Paint()..color = KathaInk.skyline;
    final window = Paint()..color = KathaInk.skylineWindow;
    for (var i = 0; i < blocks.length; i++) {
      final (x, w, h) = blocks[i];
      canvas.drawRect(Rect.fromLTWH(x, baseline - h, w, h), building);
      for (var row = 0; row < (h - 14) ~/ 14; row++) {
        for (var col = 0; col < (w - 8) ~/ 10; col++) {
          // A stable scatter of dark windows, so the skyline is not a grid.
          if ((i * 7 + row * 3 + col * 5) % 4 == 0) continue;
          canvas.drawRect(
            Rect.fromLTWH(x + 6 + col * 10, baseline - h + 8 + row * 14, 4, 6),
            window,
          );
        }
      }
    }
    // A water tank on a roof: the most Indian thing on any skyline.
    canvas.drawRRect(
      RRect.fromLTRBR(52, 40, 70, 54, const Radius.circular(3)),
      building,
    );
    canvas.drawRect(const Rect.fromLTWH(54, 54, 2, 6), building);
    canvas.drawRect(const Rect.fromLTWH(66, 54, 2, 6), building);

    _hoarding(canvas);
    _unfinishedFlyover(canvas);

    // Overhead cables, sagging between poles.
    final cable = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.28)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    final pole = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.45)
      ..strokeWidth = 2.2;
    for (final x in [24.0, 262.0, 388.0]) {
      canvas.drawLine(Offset(x, 70), Offset(x, 204), pole);
    }
    for (final (a, b) in [(24.0, 262.0), (262.0, 388.0)]) {
      for (final dy in [0.0, 5.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(a, 74 + dy)
            ..quadraticBezierTo((a + b) / 2, 94 + dy, b, 74 + dy),
          cable,
        );
      }
    }

    _washingLine(canvas);
    _stuckKite(canvas);
    _chaiStall(canvas);
    _shutteredShop(canvas);
    _tree(canvas);

    // Footpath and kerb.
    canvas.drawRect(
      const Rect.fromLTRB(0, 202, kathaWorldWidth, 222),
      Paint()..color = KathaInk.footpath,
    );
    for (var x = 0.0; x < kathaWorldWidth; x += 16) {
      canvas.drawRect(
        Rect.fromLTWH(x, 220, 8, 5),
        Paint()..color = KathaInk.ink,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 8, 220, 8, 5),
        Paint()..color = KathaInk.marigold,
      );
    }

    // Road, with a dashed centre line.
    canvas.drawRect(
      const Rect.fromLTRB(0, 225, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = KathaInk.road,
    );
    final dash = Paint()..color = KathaInk.paper.withValues(alpha: 0.75);
    for (var x = 6.0; x < kathaWorldWidth; x += 34) {
      canvas.drawRect(Rect.fromLTWH(x, 250, 18, 2.5), dash);
    }
    _pothole(canvas);
  }

  /// Monsoon cloud, low and heavy, where the sun was.

  static void _clouds(Canvas canvas) {
    final cloud = Paint()
      ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.35)!;

    for (final (x, y, r) in [
      (40.0, 26.0, 26.0),
      (110.0, 18.0, 30.0),
      (190.0, 28.0, 28.0),
      (270.0, 16.0, 32.0),
      (350.0, 26.0, 30.0),
    ]) {
      canvas.drawCircle(Offset(x, y), r, cloud);
    }

    canvas.drawRect(const Rect.fromLTRB(0, 0, kathaWorldWidth, 30), cloud);
  }

  /// A low sun, two clouds and a pair of birds.
  static void _sky(Canvas canvas) {
    canvas.drawCircle(
      const Offset(364, 34),
      24,
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      const Offset(364, 34),
      14,
      Paint()..color = KathaInk.marigold.withValues(alpha: 0.85),
    );
    final cloud = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8);
    for (final (x, y, w) in [(96.0, 34.0, 1.0), (236.0, 26.0, 0.8)]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 46 * w, height: 12 * w),
        cloud,
      );
      canvas.drawCircle(Offset(x - 8 * w, y - 5 * w), 8 * w, cloud);
      canvas.drawCircle(Offset(x + 6 * w, y - 7 * w), 10 * w, cloud);
    }
    final bird = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    for (final (x, y) in [(160.0, 24.0), (172.0, 31.0)]) {
      canvas.drawPath(
        Path()
          ..moveTo(x - 4, y)
          ..quadraticBezierTo(x - 2, y - 3, x, y)
          ..quadraticBezierTo(x + 2, y - 3, x + 4, y),
        bird,
      );
    }
  }

  /// Washing strung across a rooftop.
  static void _washingLine(Canvas canvas) {
    canvas.drawLine(
      const Offset(4, 78),
      const Offset(44, 86),
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.5)
        ..strokeWidth = 0.8,
    );
    final clothes = [
      (7.0, KathaInk.brick, 7.0, 10.0),
      (17.0, KathaInk.marigold, 6.0, 8.0),
      (26.0, KathaInk.teal, 8.0, 12.0),
      (37.0, KathaInk.paper, 5.0, 7.0),
    ];
    for (final (x, color, w, h) in clothes) {
      final y = 78 + (x - 4) * 8 / 40;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
    }
  }

  /// A hoarding for a neta who exists nowhere and everywhere: a giant
  /// beaming face, a marigold garland, hands folded in namaste, and beside
  /// him the gleaming flyover he has promised. The joke is what stands
  /// behind the auto (see [_unfinishedFlyover]). Fictional on purpose: no
  /// real face, no party symbol, no party colours.
  ///
  /// The band along the bottom is blank, because signboard text comes from
  /// the telling, never from the art.
  static void _hoarding(Canvas canvas) {
    final post = Paint()..color = KathaInk.ink.withValues(alpha: 0.7);
    canvas.drawRect(const Rect.fromLTRB(150, 110, 154, 204), post);
    canvas.drawRect(const Rect.fromLTRB(236, 110, 240, 204), post);
    canvas.drawLine(
      const Offset(152, 150),
      const Offset(238, 120),
      post..strokeWidth = 1.6,
    );

    const board = Rect.fromLTRB(140, 44, 250, 112);
    canvas.drawRect(board, Paint()..color = KathaInk.paper);
    canvas.save();
    canvas.clipRect(board);

    // Sunburst behind the great man.
    const centre = Offset(172, 74);
    final ray = Paint()..color = KathaInk.marigold.withValues(alpha: 0.4);
    for (var i = 0; i < 16; i += 2) {
      final a = i * math.pi / 8;
      final b = (i + 1) * math.pi / 8;
      canvas.drawPath(
        Path()
          ..moveTo(centre.dx, centre.dy)
          ..lineTo(centre.dx + math.cos(a) * 120, centre.dy + math.sin(a) * 120)
          ..lineTo(centre.dx + math.cos(b) * 120, centre.dy + math.sin(b) * 120)
          ..close(),
        ray,
      );
    }

    // The promised flyover, gleaming, with traffic gliding over it.
    final flyoverSky = Paint()
      ..color = Color.lerp(KathaInk.paper, KathaInk.teal, 0.12)!;
    canvas.drawRRect(
      RRect.fromLTRBR(196, 52, 246, 98, const Radius.circular(4)),
      flyoverSky,
    );
    final deck = Paint()
      ..color = KathaInk.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(198, 84)
        ..quadraticBezierTo(221, 66, 244, 84),
      deck,
    );
    for (final x in [209.0, 233.0]) {
      canvas.drawRect(
        Rect.fromLTRB(x - 1.6, 78, x + 1.6, 96),
        Paint()..color = KathaInk.teal,
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(196, 94, 246, 98),
      Paint()..color = KathaInk.leaf,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(211, 70.5, 218, 74.5, const Radius.circular(1.4)),
      Paint()..color = KathaInk.brick,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(225, 71, 231, 75, const Radius.circular(1.4)),
      Paint()..color = KathaInk.marigold,
    );
    _sparkle(canvas, const Offset(203, 60), 4);
    _sparkle(canvas, const Offset(240, 62), 3);
    _sparkle(canvas, const Offset(222, 56), 2.4);

    // The neta. Kurta first, then the garland over it.
    final kurta = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawPath(
      Path()
        ..moveTo(146, 112)
        ..quadraticBezierTo(148, 90, 172, 88)
        ..quadraticBezierTo(196, 90, 198, 112)
        ..close(),
      kurta,
    );
    final skin = Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.35)!;
    final skinPaint = Paint()..color = skin;
    // Hands pressed together: namaste, to the voters.
    canvas.drawPath(
      Path()
        ..moveTo(166, 110)
        ..quadraticBezierTo(166, 96, 172, 92)
        ..quadraticBezierTo(178, 96, 178, 110)
        ..close(),
      skinPaint,
    );
    canvas.drawLine(
      const Offset(172, 94),
      const Offset(172, 109),
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.35)
        ..strokeWidth = 0.8,
    );
    // Garland of marigolds, a deep U round the neck.
    for (var i = 0; i <= 10; i++) {
      final u = i / 10;
      final x = 156 + u * 32;
      final y = 86 + math.sin(u * math.pi) * 9;
      canvas.drawCircle(
        Offset(x, y),
        2.6,
        Paint()..color = i.isEven ? KathaInk.marigold : KathaInk.brick,
      );
    }
    // Head: big, round, pleased with itself.
    canvas.drawCircle(const Offset(155.5, 73), 3.2, skinPaint);
    canvas.drawCircle(const Offset(188.5, 73), 3.2, skinPaint);
    canvas.drawOval(const Rect.fromLTRB(156, 54, 188, 90), skinPaint);
    canvas.drawArc(
      const Rect.fromLTRB(162, 80, 182, 92),
      0.35,
      math.pi - 0.7,
      false,
      Paint()
        ..color = Color.lerp(skin, KathaInk.ink, 0.22)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Oiled hair, combed back, silvering at the sides.
    canvas.drawPath(
      Path()
        ..moveTo(156, 70)
        ..cubicTo(154, 52, 188, 48, 188, 70)
        ..lineTo(186, 64)
        ..cubicTo(180, 57, 164, 57, 158, 64)
        ..close(),
      Paint()..color = KathaInk.ink,
    );
    final grey = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55);
    canvas.drawRect(const Rect.fromLTRB(156.6, 64, 158.4, 70), grey);
    canvas.drawRect(const Rect.fromLTRB(185.6, 64, 187.4, 70), grey);
    // Sunglasses, because he is a star.
    final shades = Paint()..color = KathaInk.ink;
    canvas.drawRRect(
      RRect.fromLTRBR(161, 66, 170, 72, const Radius.circular(2.4)),
      shades,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(174, 66, 183, 72, const Radius.circular(2.4)),
      shades,
    );
    canvas.drawLine(
      const Offset(170, 68),
      const Offset(174, 68),
      shades..strokeWidth = 1.4,
    );
    canvas.drawLine(
      const Offset(163, 67.5),
      const Offset(166, 67.5),
      Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6)
        ..strokeWidth = 1,
    );
    // A moustache of authority over the widest grin on the street.
    canvas.drawPath(
      Path()
        ..moveTo(162, 78)
        ..quadraticBezierTo(167, 73.5, 172, 76)
        ..quadraticBezierTo(177, 73.5, 182, 78)
        ..quadraticBezierTo(177, 77, 172, 78.4)
        ..quadraticBezierTo(167, 77, 162, 78)
        ..close(),
      Paint()..color = KathaInk.ink,
    );
    final grin = Path()
      ..moveTo(164, 79.5)
      ..quadraticBezierTo(172, 89, 180, 79.5)
      ..close();
    canvas.drawPath(grin, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawPath(
      grin,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (final x in [168.0, 172.0, 176.0]) {
      canvas.drawLine(
        Offset(x, 80),
        Offset(x, 82.4),
        Paint()
          ..color = KathaInk.ink.withValues(alpha: 0.4)
          ..strokeWidth = 0.6,
      );
    }
    _sparkle(canvas, const Offset(181, 82), 2.6);

    // The blank band where the slogan would go.
    canvas.drawRect(
      const Rect.fromLTRB(140, 104, 250, 112),
      Paint()..color = KathaInk.brick,
    );
    canvas.restore();
    canvas.drawRect(
      board,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  /// The flyover as it actually is: one pillar, years old, rebar rusting out
  /// of the top and a weed making itself at home.
  static void _unfinishedFlyover(Canvas canvas) {
    final concrete = Paint()
      ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!;
    final stain = Paint()..color = KathaInk.ink.withValues(alpha: 0.12);
    canvas.drawPath(
      Path()
        ..moveTo(290, 204)
        ..lineTo(290, 74)
        ..lineTo(294, 70)
        ..lineTo(297, 74)
        ..lineTo(301, 67)
        ..lineTo(305, 73)
        ..lineTo(310, 70)
        ..lineTo(310, 204)
        ..close(),
      concrete,
    );
    // A stub of the cross-beam it was meant to carry.
    canvas.drawPath(
      Path()
        ..moveTo(310, 80)
        ..lineTo(322, 80)
        ..lineTo(320, 85)
        ..lineTo(323, 88)
        ..lineTo(310, 92)
        ..close(),
      concrete,
    );
    canvas.drawRect(const Rect.fromLTRB(290, 96, 310, 104), stain);
    canvas.drawRect(const Rect.fromLTRB(297, 120, 300, 160), stain);
    final rebar = Paint()
      ..color = KathaInk.brickShade
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final (x, top, lean) in [
      (292.0, 54.0, -3.0),
      (296.0, 50.0, 0.0),
      (300.0, 56.0, 5.0),
      (304.0, 48.0, 1.0),
      (308.0, 55.0, 6.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 72)
          ..quadraticBezierTo(x, top + 6, x + lean, top),
        rebar,
      );
    }
    for (final y in [82.0, 85.0]) {
      canvas.drawLine(Offset(321, y), Offset(329, y - 2), rebar);
    }
    // The weed, the only thing up there that has grown.
    final weed = Paint()..color = KathaInk.leaf;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(299, 66), width: 5, height: 9),
      weed,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(303, 67), width: 7, height: 4),
      weed,
    );
  }

  /// A pothole full of last night's rain, with the one traffic cone anyone
  /// has done about it.
  static void _pothole(Canvas canvas) {
    final hole = Path()
      ..moveTo(60, 239)
      ..cubicTo(64, 231, 88, 230, 102, 235)
      ..cubicTo(110, 239, 104, 247, 92, 247)
      ..cubicTo(78, 249, 58, 247, 60, 239)
      ..close();
    canvas.drawPath(hole, Paint()..color = KathaInk.ink);
    canvas.save();
    canvas.clipPath(hole);
    canvas.drawOval(
      const Rect.fromLTRB(63, 235, 104, 248),
      Paint()..color = Color.lerp(KathaInk.teal, KathaInk.ink, 0.35)!,
    );
    final glint = Paint()
      ..color = KathaInk.paper.withValues(alpha: 0.55)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(72, 240), const Offset(82, 240), glint);
    canvas.drawLine(const Offset(86, 243), const Offset(92, 243), glint);
    canvas.restore();
    final crack = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.7)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(60, 239)
        ..lineTo(52, 236)
        ..lineTo(46, 238),
      crack,
    );
    canvas.drawPath(
      Path()
        ..moveTo(104, 237)
        ..lineTo(112, 233)
        ..lineTo(118, 235),
      crack,
    );
    // Broken chunks of asphalt at the rim.
    final chunk = Paint()
      ..color = Color.lerp(KathaInk.road, KathaInk.paper, 0.2)!;
    canvas.drawRect(const Rect.fromLTWH(94, 248, 4, 2.4), chunk);
    canvas.drawRect(const Rect.fromLTWH(66, 230.6, 3, 2), chunk);

    // The cone.
    canvas.drawRect(
      const Rect.fromLTRB(112, 248, 126, 251),
      Paint()..color = KathaInk.ink,
    );
    canvas.drawPath(
      Path()
        ..moveTo(114, 248)
        ..lineTo(118.2, 233)
        ..lineTo(119.8, 233)
        ..lineTo(124, 248)
        ..close(),
      Paint()..color = KathaInk.marigold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(116.2, 240)
        ..lineTo(121.8, 240)
        ..lineTo(122.6, 243)
        ..lineTo(115.4, 243)
        ..close(),
      Paint()..color = KathaInk.paper,
    );
  }

  /// A four-pointed glint, the universal sign of "brand new".
  static void _sparkle(Canvas canvas, Offset c, double r) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
        ..close(),
      Paint()..color = const Color(0xFFFFFFFF),
    );
  }

  /// A kite that lost its fight with the cables.
  static void _stuckKite(Canvas canvas) {
    canvas.save();
    canvas.translate(104, 88);
    canvas.rotate(0.5);
    canvas.drawPath(
      Path()
        ..moveTo(0, -8)
        ..lineTo(6, 0)
        ..lineTo(0, 9)
        ..lineTo(-6, 0)
        ..close(),
      Paint()..color = KathaInk.brick,
    );
    final rib = Paint()
      ..color = KathaInk.paper.withValues(alpha: 0.8)
      ..strokeWidth = 0.8;
    canvas.drawLine(const Offset(0, -8), const Offset(0, 9), rib);
    canvas.drawLine(const Offset(-6, 0), const Offset(6, 0), rib);
    canvas.drawPath(
      Path()
        ..moveTo(0, 9)
        ..quadraticBezierTo(5, 14, 0, 19)
        ..quadraticBezierTo(-4, 23, 1, 27),
      Paint()
        ..color = KathaInk.brick
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  static void _chaiStall(Canvas canvas) {
    final post = Paint()..color = KathaInk.ink;
    canvas.drawRect(const Rect.fromLTWH(12, 146, 3, 58), post);
    canvas.drawRect(const Rect.fromLTWH(98, 146, 3, 58), post);
    // Counter.
    canvas.drawRect(
      const Rect.fromLTRB(8, 176, 106, 204),
      Paint()..color = KathaInk.brick,
    );
    canvas.drawRect(
      const Rect.fromLTRB(8, 176, 106, 180),
      Paint()..color = KathaInk.brickShade,
    );
    // Striped awning with a scalloped edge.
    for (var i = 0; i < 7; i++) {
      final x = 6.0 + i * 14.4;
      canvas.drawRect(
        Rect.fromLTWH(x, 136, 14.4, 14),
        Paint()..color = i.isEven ? KathaInk.marigold : KathaInk.paper,
      );
      canvas.drawCircle(
        Offset(x + 7.2, 150),
        7.2,
        Paint()..color = i.isEven ? KathaInk.marigold : KathaInk.paper,
      );
    }
    canvas.drawLine(
      const Offset(6, 136),
      const Offset(107, 136),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1.5,
    );
    // A kettle and a row of glasses.
    canvas.drawRRect(
      RRect.fromLTRBR(22, 164, 36, 176, const Radius.circular(4)),
      post,
    );
    canvas.drawLine(
      const Offset(36, 168),
      const Offset(42, 164),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 2,
    );
    final glass = Paint()..color = KathaInk.paper;
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromLTWH(56 + i * 9.0, 168, 5, 8), glass);
    }
  }

  static void _shutteredShop(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(118, 132, 208, 204),
      Paint()..color = KathaInk.shopWall,
    );
    canvas.drawRect(
      const Rect.fromLTRB(126, 154, 200, 204),
      Paint()..color = KathaInk.shutter,
    );
    final line = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var y = 158.0; y < 204; y += 5) {
      canvas.drawLine(Offset(126, y), Offset(200, y), line);
    }
    // Film posters pasted on the shutter, one peeling at the corner.
    canvas.save();
    canvas.translate(142, 176);
    canvas.rotate(-0.06);
    canvas.drawRect(
      const Rect.fromLTRB(-9, -12, 9, 12),
      Paint()..color = KathaInk.marigold,
    );
    canvas.drawCircle(
      const Offset(0, -3),
      4.6,
      Paint()..color = KathaInk.brick,
    );
    canvas.drawRect(
      const Rect.fromLTRB(-6, 5, 6, 7.4),
      Paint()..color = KathaInk.ink,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(166, 180);
    canvas.rotate(0.08);
    canvas.drawRect(
      const Rect.fromLTRB(-8, -11, 8, 11),
      Paint()..color = KathaInk.paper,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, -7)
        ..lineTo(2, -1.6)
        ..lineTo(7, -1.6)
        ..lineTo(3, 1.8)
        ..lineTo(4.6, 7)
        ..lineTo(0, 3.8)
        ..lineTo(-4.6, 7)
        ..lineTo(-3, 1.8)
        ..lineTo(-7, -1.6)
        ..lineTo(-2, -1.6)
        ..close(),
      Paint()..color = KathaInk.teal,
    );
    canvas.restore();
    // A plant in an old paint tin by the door.
    canvas.drawRect(
      const Rect.fromLTRB(106, 194, 115, 204),
      Paint()..color = KathaInk.brickShade,
    );
    for (final (x, y) in [(107.0, 190.0), (111.0, 186.0), (115.0, 191.0)]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 6, height: 9),
        Paint()..color = KathaInk.leaf,
      );
    }
    // The board: blank, because signboard text comes from the telling.
    canvas.drawRRect(
      RRect.fromLTRBR(124, 138, 202, 150, const Radius.circular(2)),
      Paint()..color = KathaInk.teal,
    );
  }

  static void _tree(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(368, 150, 376, 206),
      Paint()..color = KathaInk.brickShade,
    );
    final leaf = Paint()..color = KathaInk.leaf;
    for (final (x, y, r) in [
      (360.0, 132.0, 20.0),
      (382.0, 126.0, 22.0),
      (372.0, 108.0, 20.0),
      (396.0, 140.0, 16.0),
    ]) {
      canvas.drawCircle(Offset(x, y), r, leaf);
    }
  }
}

/// A street dog asleep on the footpath. Now and then the tail thumps and an
/// ear twitches: dreaming.
class StreetDog extends IdleBit {
  StreetDog({Vector2? at})
    : super(seconds: 1.2, position: at ?? Vector2(56, 213));

  static final _tan = Color.lerp(KathaInk.marigold, KathaInk.brick, 0.55)!;
  static final _dark = Color.lerp(_tan, KathaInk.ink, 0.35)!;

  @override
  void render(Canvas canvas) {
    final fur = Paint()..color = _tan;
    final wag = math.sin(t * math.pi * 6) * 0.55 * (1 - t);
    // Tail first, so the body covers its root.
    canvas.save();
    canvas.translate(-14, -1);
    canvas.rotate(-0.9 + wag);
    canvas.drawRRect(
      RRect.fromLTRBR(-1.6, -12, 1.6, 0, const Radius.circular(1.6)),
      fur,
    );
    canvas.restore();
    canvas.drawOval(const Rect.fromLTRB(-16, -7, 14, 6), fur);
    canvas.drawOval(
      const Rect.fromLTRB(-10, -6, 2, 1),
      Paint()..color = KathaInk.paper.withValues(alpha: 0.35),
    );
    // Head resting on the paws.
    canvas.drawRRect(
      RRect.fromLTRBR(8, 1, 22, 5.5, const Radius.circular(2.4)),
      fur,
    );
    canvas.drawCircle(const Offset(13, -1), 6.2, fur);
    canvas.drawOval(const Rect.fromLTRB(15, -1, 23, 4.4), fur);
    canvas.drawCircle(
      const Offset(22.4, 1),
      1.3,
      Paint()..color = KathaInk.ink,
    );
    canvas.save();
    canvas.translate(9.5, -5);
    canvas.rotate(0.5 + math.sin(t * math.pi * 4) * 0.3 * (1 - t));
    canvas.drawOval(
      const Rect.fromLTRB(-2.6, -1, 2.6, 7),
      Paint()..color = _dark,
    );
    canvas.restore();
    // A closed, contented eye.
    canvas.drawArc(
      const Rect.fromLTRB(13.4, -2.6, 17.4, 0.6),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );
  }
}

/// A crow perched on top of the neta's hoarding, pecking at it when the
/// mood takes - which is about the respect the poster gets from the street.
class PosterCrow extends IdleBit {
  PosterCrow() : super(seconds: 0.9, chance: 0.5, position: Vector2(176, 44.5));

  @override
  void render(Canvas canvas) {
    final ink = Paint()..color = KathaInk.ink;
    final leg = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 0.9;
    canvas.drawLine(const Offset(-1.5, -4), const Offset(-1.5, 0), leg);
    canvas.drawLine(const Offset(1.5, -4), const Offset(1.5, 0), leg);
    // The whole bird tips forward from its feet to peck, twice.
    canvas.save();
    canvas.translate(0, -4);
    canvas.rotate(math.sin(t * math.pi * 2).abs() * 0.7);
    canvas.drawOval(const Rect.fromLTRB(-7, -8, 5, 0), ink);
    canvas.drawPath(
      Path()
        ..moveTo(-6, -5)
        ..lineTo(-12, -3)
        ..lineTo(-6, -1.5)
        ..close(),
      ink,
    );
    canvas.drawCircle(const Offset(5, -8), 3.4, ink);
    canvas.drawPath(
      Path()
        ..moveTo(7.6, -9.4)
        ..lineTo(12.4, -7.6)
        ..lineTo(7.6, -6.4)
        ..close(),
      Paint()..color = KathaInk.khakiShade,
    );
    canvas.drawCircle(
      const Offset(6, -8.8),
      0.7,
      Paint()..color = KathaInk.paper,
    );
    canvas.restore();
  }
}

/// A black cat on the shop roof, watching everything. Its tail hangs over
/// the edge and flicks.
class RoofCat extends IdleBit {
  RoofCat() : super(seconds: 1.4, chance: 0.5, position: Vector2(190, 132));

  @override
  void render(Canvas canvas) {
    final ink = Paint()..color = KathaInk.ink;
    final flick = math.sin(t * math.pi * 3) * 0.5 * (1 - t);
    canvas.save();
    canvas.translate(5, -2);
    canvas.rotate(-0.25 + flick);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(6, 4, 4, 13),
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
    canvas.drawOval(const Rect.fromLTRB(-6.5, -14, 6.5, 0.5), ink);
    canvas.drawCircle(const Offset(-1, -17), 5.2, ink);
    for (final x in [-4.6, 2.6]) {
      canvas.drawPath(
        Path()
          ..moveTo(x - 2.2, -19.5)
          ..lineTo(x, -25)
          ..lineTo(x + 2.2, -19.5)
          ..close(),
        ink,
      );
    }
    final eye = Paint()..color = KathaInk.marigold;
    canvas.drawOval(const Rect.fromLTRB(-4.2, -18.6, -2, -16.2), eye);
    canvas.drawOval(const Rect.fromLTRB(0, -18.6, 2.2, -16.2), eye);
  }
}

/// The hoarding's peeling corner, lifting in the breeze now and then.
class PosterFlap extends IdleBit {
  PosterFlap() : super(seconds: 1.3, chance: 0.6, position: Vector2(250, 112));

  @override
  void render(Canvas canvas) {
    // How far the corner has folded back along the diagonal: a little at
    // rest, more when the breeze catches it.
    final fold = 0.3 + math.sin(t * math.pi) * 0.45;
    const size = 14.0;
    // Where the corner was: bare board.
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-size, 0)
        ..lineTo(0, -size)
        ..close(),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.35)!,
    );
    // The corner itself, folded back with its pale underside showing.
    final tip = Offset(-size * fold, -size * fold);
    final flap = Path()
      ..moveTo(-size, 0)
      ..lineTo(0, -size)
      ..lineTo(tip.dx, tip.dy)
      ..close();
    canvas.drawPath(flap, Paint()..color = KathaInk.paper);
    canvas.drawPath(
      flap,
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }
}
