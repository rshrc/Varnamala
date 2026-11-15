import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:words625/views/katha/scene/bubbles/bubble_icon_pen.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// Weather, nature, people and celebrations.
const lifeIcons = <String, BubbleIconPainter>{
  'sun': _sun,
  'moon': _moon,
  'rain': _rain,
  'bolt': _bolt,
  'cow': _cow,
  'mosquito': _mosquito,
  'zzz': _zzz,
  'person': _person,
  'heart': _heart,
  'ring': _ring,
  'cricket': _cricket,
  'diya': _diya,
  'firework': _firework,
};

void _sun(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // The morning.
  final sun = Paint()..color = KathaInk.marigold;
  canvas.drawCircle(c, 5, sun);
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4;
    canvas.drawLine(
      c + Offset(math.cos(a) * 7, math.sin(a) * 7),
      c + Offset(math.cos(a) * 10, math.sin(a) * 10),
      Paint()
        ..color = KathaInk.marigold
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }
}

void _moon(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawCircle(c, 8, Paint()..color = KathaInk.marigold);
  canvas.drawCircle(c.translate(4, -3), 7, Paint()..color = KathaInk.paper);
}

void _rain(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  final cloud = Paint()..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.4)!;
  canvas.drawCircle(c.translate(-4, -4), 5, cloud);
  canvas.drawCircle(c.translate(3, -5), 6, cloud);
  canvas.drawRect(Rect.fromLTRB(c.dx - 9, c.dy - 4, c.dx + 9, c.dy + 1), cloud);
  final drop = Paint()
    ..color = KathaInk.teal
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  for (final x in [-6.0, 0.0, 6.0]) {
    canvas.drawLine(c.translate(x, 4), c.translate(x - 1.6, 9), drop);
  }
}

void _bolt(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawPath(
    Path()
      ..moveTo(c.dx + 3, c.dy - 12)
      ..lineTo(c.dx - 6, c.dy + 2)
      ..lineTo(c.dx, c.dy + 2)
      ..lineTo(c.dx - 3, c.dy + 12)
      ..lineTo(c.dx + 7, c.dy - 3)
      ..lineTo(c.dx + 1, c.dy - 3)
      ..close(),
    Paint()..color = KathaInk.marigoldShade,
  );
}

void _cow(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  final hide = Paint()
    ..color = Color.lerp(KathaInk.paper, KathaInk.khaki, 0.5)!;
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 10,
      c.dy - 5,
      c.dx + 4,
      c.dy + 4,
      const Radius.circular(4),
    ),
    hide,
  );
  canvas.drawCircle(c.translate(6, -3), 4.4, hide);
  for (final x in [-8.0, -4.0, 0.0, 3.0]) {
    canvas.drawLine(
      c.translate(x, 4),
      c.translate(x, 9),
      stroke..strokeWidth = 1.6,
    );
  }
  canvas.drawLine(
    c.translate(5, -7),
    c.translate(4, -10),
    stroke..color = KathaInk.brick,
  );
}

void _mosquito(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink, :stroke) = pen;
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(-2, -4), width: 8, height: 5),
    Paint()..color = KathaInk.teal.withValues(alpha: 0.35),
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(3, -4), width: 8, height: 5),
    Paint()..color = KathaInk.teal.withValues(alpha: 0.35),
  );
  canvas.drawOval(Rect.fromCenter(center: c, width: 14, height: 4.4), ink);
  for (final dx in [-4.0, 0.0, 4.0]) {
    canvas.drawLine(
      c.translate(dx, 2),
      c.translate(dx - 2, 8),
      stroke..strokeWidth = 1,
    );
  }
  canvas.drawLine(
    c.translate(7, 0),
    c.translate(12, 2),
    stroke..strokeWidth = 1,
  );
}

void _zzz(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  final z = Paint()
    ..color = KathaInk.teal
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;
  for (final (o, size) in [
    (c.translate(-6, 5), 8.0),
    (c.translate(4, -3), 6.0),
  ]) {
    canvas.drawPath(
      Path()
        ..moveTo(o.dx - size / 2, o.dy - size / 2)
        ..lineTo(o.dx + size / 2, o.dy - size / 2)
        ..lineTo(o.dx - size / 2, o.dy + size / 2)
        ..lineTo(o.dx + size / 2, o.dy + size / 2),
      z,
    );
  }
}

void _person(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawCircle(
    c.translate(0, -5),
    4.4,
    Paint()..color = KathaInk.skinWarm,
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 8, c.dy + 10)
      ..quadraticBezierTo(c.dx - 8, c.dy, c.dx, c.dy)
      ..quadraticBezierTo(c.dx + 8, c.dy, c.dx + 8, c.dy + 10)
      ..close(),
    Paint()..color = KathaInk.teal,
  );
}

void _heart(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawPath(
    Path()
      ..moveTo(c.dx, c.dy + 8)
      ..cubicTo(c.dx - 13, c.dy - 1, c.dx - 6, c.dy - 11, c.dx, c.dy - 4)
      ..cubicTo(c.dx + 6, c.dy - 11, c.dx + 13, c.dy - 1, c.dx, c.dy + 8)
      ..close(),
    Paint()..color = KathaInk.brick,
  );
}

void _ring(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // A wedding ring with its stone.
  canvas.drawCircle(
    c.translate(0, 3),
    6.5,
    Paint()
      ..color = KathaInk.marigold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4,
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx, c.dy - 9)
      ..lineTo(c.dx + 4, c.dy - 5.5)
      ..lineTo(c.dx, c.dy - 2.5)
      ..lineTo(c.dx - 4, c.dy - 5.5)
      ..close(),
    Paint()..color = KathaInk.teal,
  );
}

void _cricket(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink) = pen;
  canvas.save();
  canvas.translate(c.dx - 2, c.dy);
  canvas.rotate(0.5);
  canvas.drawRect(const Rect.fromLTRB(-1.4, -11, 1.4, -4), ink);
  canvas.drawRRect(
    RRect.fromLTRBR(-3.6, -4, 3.6, 10, const Radius.circular(1.6)),
    Paint()..color = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.3)!,
  );
  canvas.restore();
  canvas.drawCircle(c.translate(7, 5), 3.4, Paint()..color = KathaInk.brick);
}

void _diya(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  canvas.drawCircle(
    c.translate(0, -2),
    10,
    Paint()..color = KathaInk.marigold.withValues(alpha: 0.3),
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 11, c.dy + 3)
      ..quadraticBezierTo(c.dx, c.dy + 14, c.dx + 11, c.dy + 3)
      ..close(),
    Paint()..color = KathaInk.brick,
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 3, c.dy + 3)
      ..quadraticBezierTo(c.dx, c.dy - 13, c.dx + 3, c.dy + 3),
    Paint()..color = KathaInk.marigold,
  );
}

void _firework(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  for (var i = 0; i < 12; i++) {
    final a = i * math.pi / 6;
    canvas.drawLine(
      c + Offset(math.cos(a) * 5, math.sin(a) * 5),
      c + Offset(math.cos(a) * 12, math.sin(a) * 12),
      Paint()
        ..color = i.isEven ? KathaInk.marigold : KathaInk.brick
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }
  canvas.drawCircle(c, 2.4, Paint()..color = KathaInk.marigold);
}
