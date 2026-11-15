import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:words625/views/katha/scene/bubbles/bubble_icon_pen.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// Home, food and things around the house.
const homeIcons = <String, BubbleIconPainter>{
  'house': _house,
  'bed': _bed,
  'fan': _fan,
  'key': _key,
  'bucket': _bucket,
  'water': _water,
  'bottle': _bottle,
  'cylinder': _cylinder,
  'flame': _flame,
  'tiffin': _tiffin,
  'plate': _plate,
  'tea': _tea,
  'drumstick': _drumstick,
  'sweets': _sweets,
  'chili': _chili,
  'corn': _corn,
  'biscuit': _biscuit,
  'fish': _fish,
  'candle': _candle,
  'cigarette': _cigarette,
};

void _house(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 8, c.dy - 2, c.dx + 8, c.dy + 9),
    Paint()..color = KathaInk.teal,
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 11, c.dy - 1)
      ..lineTo(c.dx, c.dy - 10)
      ..lineTo(c.dx + 11, c.dy - 1)
      ..close(),
    Paint()..color = KathaInk.brick,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 2.4, c.dy + 2, c.dx + 2.4, c.dy + 9),
    Paint()..color = KathaInk.paper,
  );
}

void _bed(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 12, c.dy - 1, c.dx + 12, c.dy + 5),
    Paint()..color = KathaInk.marigold,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTRB(c.dx - 11, c.dy - 6, c.dx - 3, c.dy - 1),
      const Radius.circular(2),
    ),
    Paint()..color = KathaInk.paper,
  );
  canvas.drawLine(
    c.translate(-13, -8),
    c.translate(-13, 10),
    stroke..strokeWidth = 2,
  );
  canvas.drawLine(c.translate(13, 0), c.translate(13, 10), stroke);
}

void _fan(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink) = pen;
  // A ceiling fan from below: three blades round a hub.
  final blade = Paint()
    ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.45)!;
  for (var i = 0; i < 3; i++) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(i * 2.094);
    canvas.drawOval(const Rect.fromLTRB(-2.4, -10, 2.4, -1), blade);
    canvas.restore();
  }
  canvas.drawCircle(c, 2.6, ink);
}

void _key(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  final gold = Paint()..color = KathaInk.marigoldShade;
  canvas.drawCircle(c.translate(-5, 0), 5, gold);
  canvas.drawCircle(c.translate(-5, 0), 2, Paint()..color = KathaInk.paper);
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 1, c.dy - 1.4, c.dx + 10, c.dy + 1.4),
    gold,
  );
  canvas.drawRect(Rect.fromLTRB(c.dx + 5, c.dy, c.dx + 7, c.dy + 4), gold);
  canvas.drawRect(Rect.fromLTRB(c.dx + 8, c.dy, c.dx + 10, c.dy + 3), gold);
}

void _bucket(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 9, c.dy - 6)
      ..lineTo(c.dx + 9, c.dy - 6)
      ..lineTo(c.dx + 7, c.dy + 10)
      ..lineTo(c.dx - 7, c.dy + 10)
      ..close(),
    Paint()..color = KathaInk.teal,
  );
  canvas.drawArc(
    Rect.fromCenter(center: c.translate(0, -6), width: 18, height: 14),
    math.pi,
    math.pi,
    false,
    stroke..strokeWidth = 1.4,
  );
}

void _water(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // A tap with a drop.
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 9, c.dy - 7, c.dx + 3, c.dy - 3),
    Paint()..color = KathaInk.ink.withValues(alpha: 0.6),
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 1, c.dy - 3, c.dx + 3, c.dy),
    Paint()..color = KathaInk.ink.withValues(alpha: 0.6),
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx + 1, c.dy + 2)
      ..quadraticBezierTo(c.dx + 5, c.dy + 7, c.dx + 1, c.dy + 9)
      ..quadraticBezierTo(c.dx - 3, c.dy + 7, c.dx + 1, c.dy + 2)
      ..close(),
    Paint()..color = KathaInk.teal,
  );
}

void _bottle(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 5,
      c.dy - 3,
      c.dx + 5,
      c.dy + 10,
      const Radius.circular(2),
    ),
    Paint()..color = KathaInk.leaf,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 2, c.dy - 10, c.dx + 2, c.dy - 3),
    Paint()..color = KathaInk.leaf,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 4, c.dy + 1, c.dx + 4, c.dy + 6),
    Paint()..color = KathaInk.paper,
  );
}

void _cylinder(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink) = pen;
  final body = RRect.fromLTRBR(
    c.dx - 7,
    c.dy - 6,
    c.dx + 7,
    c.dy + 12,
    const Radius.circular(5),
  );
  canvas.drawRRect(body, Paint()..color = KathaInk.brick);
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 4.5, c.dy - 11, c.dx + 4.5, c.dy - 5),
    Paint()..color = KathaInk.brickShade,
  );
  canvas.drawRect(Rect.fromLTRB(c.dx - 2, c.dy - 13, c.dx + 2, c.dy - 10), ink);
}

void _flame(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawPath(
    Path()
      ..moveTo(c.dx, c.dy - 12)
      ..quadraticBezierTo(c.dx + 11, c.dy, c.dx + 6, c.dy + 9)
      ..quadraticBezierTo(c.dx, c.dy + 13, c.dx - 6, c.dy + 9)
      ..quadraticBezierTo(c.dx - 11, c.dy, c.dx, c.dy - 12),
    Paint()..color = const Color(0xFF4F8CE0),
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(0, 5), width: 6, height: 9),
    Paint()..color = KathaInk.paper,
  );
}

void _tiffin(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  final steel = Paint()
    ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.35)!;
  for (var i = 0; i < 3; i++) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          c.dx - 9,
          c.dy + 4 - i * 6.0,
          c.dx + 9,
          c.dy + 9 - i * 6.0,
        ),
        const Radius.circular(1.5),
      ),
      steel,
    );
  }
  canvas.drawLine(
    c.translate(-10, 8),
    c.translate(-10, -12),
    stroke..strokeWidth = 1.2,
  );
  canvas.drawLine(c.translate(10, 8), c.translate(10, -12), stroke);
  canvas.drawLine(c.translate(-10, -12), c.translate(10, -12), stroke);
}

void _plate(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  // Breakfast: a plate, something round and white, something golden.
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(0, 4), width: 22, height: 8),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(0, 4), width: 22, height: 8),
    stroke..strokeWidth = 1,
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(-4, 0), width: 9, height: 6),
    Paint()..color = KathaInk.paper,
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(5, 0), width: 8, height: 6),
    Paint()..color = KathaInk.marigold,
  );
}

void _tea(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  // A glass of chai, steaming.
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 6, c.dy - 4)
      ..lineTo(c.dx + 6, c.dy - 4)
      ..lineTo(c.dx + 4.6, c.dy + 9)
      ..lineTo(c.dx - 4.6, c.dy + 9)
      ..close(),
    Paint()..color = KathaInk.khakiShade,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 6, c.dy - 4, c.dx + 6, c.dy - 1.6),
    Paint()..color = KathaInk.paper,
  );
  for (final x in [-2.5, 2.5]) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + x, c.dy - 6)
        ..quadraticBezierTo(c.dx + x + 2.5, c.dy - 8.5, c.dx + x, c.dy - 11),
      stroke
        ..color = KathaInk.ink.withValues(alpha: 0.35)
        ..strokeWidth = 1.2,
    );
  }
}

void _drumstick(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // Meat: a roast chicken leg, the universal question at a landlady's door.
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-0.75);
  canvas.drawPath(
    Path()
      ..moveTo(0, 2)
      ..cubicTo(-10, 0, -9, -12, 0, -12)
      ..cubicTo(9, -12, 10, 0, 0, 2)
      ..close(),
    Paint()..color = Color.lerp(KathaInk.brick, KathaInk.marigold, 0.45)!,
  );
  canvas.drawOval(
    const Rect.fromLTRB(-5, -10, 0, -5),
    Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.35),
  );
  final bone = Paint()..color = const Color(0xFFFFFFFF);
  canvas.drawRect(const Rect.fromLTRB(-1.8, 1, 1.8, 9), bone);
  canvas.drawCircle(const Offset(-2.2, 10), 2.4, bone);
  canvas.drawCircle(const Offset(2.2, 10), 2.4, bone);
  canvas.restore();
}

void _sweets(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  for (final o in [c.translate(-6, 4), c.translate(6, 4), c.translate(0, -5)]) {
    canvas.drawCircle(o, 6, Paint()..color = KathaInk.marigold);
    canvas.drawCircle(
      o.translate(-1.5, -1.5),
      1.2,
      Paint()..color = KathaInk.marigoldShade,
    );
  }
}

void _chili(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 9, c.dy - 6)
      ..quadraticBezierTo(c.dx + 8, c.dy - 4, c.dx + 8, c.dy + 9)
      ..quadraticBezierTo(c.dx - 2, c.dy + 2, c.dx - 9, c.dy - 1)
      ..close(),
    Paint()..color = KathaInk.brick,
  );
  canvas.drawLine(
    c.translate(-9, -4),
    c.translate(-12, -9),
    Paint()
      ..color = KathaInk.leaf
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round,
  );
}

void _corn(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 9, height: 20),
      const Radius.circular(4.5),
    ),
    Paint()..color = KathaInk.marigold,
  );
  for (final dy in [-5.0, 0.0, 5.0]) {
    canvas.drawCircle(
      c.translate(-1.5, dy),
      1.2,
      Paint()..color = KathaInk.ink.withValues(alpha: 0.4),
    );
  }
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 4, c.dy + 8)
      ..lineTo(c.dx - 9, c.dy + 12)
      ..lineTo(c.dx + 9, c.dy + 12)
      ..lineTo(c.dx + 4, c.dy + 8)
      ..close(),
    Paint()..color = KathaInk.leaf,
  );
}

void _biscuit(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  final biscuit = Paint()
    ..color = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.35)!;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 20, height: 14),
      const Radius.circular(2.5),
    ),
    biscuit,
  );
  for (final o in [
    c.translate(-5, -3),
    c.translate(5, -3),
    c.translate(0, 3),
  ]) {
    canvas.drawCircle(o, 1.1, Paint()..color = KathaInk.marigoldShade);
  }
}

void _fish(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  final fishPaint = Paint()..color = KathaInk.teal;
  canvas.drawOval(
    Rect.fromLTRB(c.dx - 8, c.dy - 5, c.dx + 6, c.dy + 5),
    fishPaint,
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx + 4, c.dy)
      ..lineTo(c.dx + 11, c.dy - 6)
      ..lineTo(c.dx + 11, c.dy + 6)
      ..close(),
    fishPaint,
  );
  canvas.drawCircle(
    c.translate(-4.5, -1),
    1.1,
    Paint()..color = KathaInk.paper,
  );
}

void _candle(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  canvas.drawCircle(
    c.translate(0, -6),
    9,
    Paint()..color = KathaInk.marigold.withValues(alpha: 0.3),
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 3.5, c.dy - 2, c.dx + 3.5, c.dy + 11),
    Paint()..color = KathaInk.paper,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 3.5, c.dy - 2, c.dx + 3.5, c.dy + 11),
    stroke..strokeWidth = 1,
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx, c.dy - 3)
      ..quadraticBezierTo(c.dx - 4, c.dy - 8, c.dx, c.dy - 13)
      ..quadraticBezierTo(c.dx + 4, c.dy - 8, c.dx, c.dy - 3),
    Paint()..color = const Color(0xFFFFB347),
  );
}

void _cigarette(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-0.4);
  canvas.drawRect(
    const Rect.fromLTRB(-10, -1.8, 6, 1.8),
    Paint()..color = KathaInk.paper,
  );
  canvas.drawRect(
    const Rect.fromLTRB(6, -1.8, 10, 1.8),
    Paint()..color = KathaInk.marigold,
  );
  canvas.drawRect(
    const Rect.fromLTRB(-10, -1.8, 10, 1.8),
    Paint()
      ..color = KathaInk.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7,
  );
  canvas.drawCircle(const Offset(-11, 0), 1.6, Paint()..color = KathaInk.brick);
  canvas.restore();
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 9, c.dy + 2)
      ..quadraticBezierTo(c.dx - 13, c.dy - 3, c.dx - 9, c.dy - 7),
    stroke..color = KathaInk.ink.withValues(alpha: 0.4),
  );
}
