import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:words625/views/katha/scene/bubbles/bubble_icon_pen.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// Work, money and getting about.
const workIcons = <String, BubbleIconPainter>{
  'laptop': _laptop,
  'chart': _chart,
  'briefcase': _briefcase,
  'phone': _phone,
  'wifi': _wifi,
  'calendar': _calendar,
  'clock': _clock,
  'rupee': _rupee,
  'meter': _meter,
  'meter_broken': _meterBroken,
  'auto': _auto,
  'traffic': _traffic,
  'plane': _plane,
  'suitcase': _suitcase,
  'poster': _poster,
  'mic': _mic,
  'pin': _pin,
};

void _laptop(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink) = pen;
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 11,
      c.dy - 10,
      c.dx + 11,
      c.dy + 4,
      const Radius.circular(2),
    ),
    ink,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 9, c.dy - 8, c.dx + 9, c.dy + 2),
    Paint()..color = Color.lerp(KathaInk.teal, KathaInk.paper, 0.5)!,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 14,
      c.dy + 4,
      c.dx + 14,
      c.dy + 8,
      const Radius.circular(2),
    ),
    ink,
  );
}

void _chart(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  for (final (i, h) in [8.0, 13.0, 19.0].indexed) {
    canvas.drawRect(
      Rect.fromLTRB(
        c.dx - 11 + i * 8.0,
        c.dy + 10 - h,
        c.dx - 5 + i * 8.0,
        c.dy + 10,
      ),
      Paint()..color = i == 2 ? KathaInk.marigold : KathaInk.teal,
    );
  }
  canvas.drawLine(
    c.translate(-13, 10),
    c.translate(13, 10),
    stroke..strokeWidth = 1.4,
  );
}

void _briefcase(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  // A new job.
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 10,
      c.dy - 4,
      c.dx + 10,
      c.dy + 8,
      const Radius.circular(2),
    ),
    Paint()..color = KathaInk.brickShade,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 4,
      c.dy - 8,
      c.dx + 4,
      c.dy - 3,
      const Radius.circular(1.5),
    ),
    stroke..color = KathaInk.brickShade,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 10, c.dy, c.dx + 10, c.dy + 1.4),
    Paint()..color = KathaInk.marigold,
  );
}

void _phone(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink) = pen;
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 6,
      c.dy - 10,
      c.dx + 6,
      c.dy + 10,
      const Radius.circular(2.4),
    ),
    ink,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 4.4, c.dy - 7.6, c.dx + 4.4, c.dy + 6.6),
    Paint()..color = Color.lerp(KathaInk.teal, KathaInk.paper, 0.4)!,
  );
  // A forwarded sunrise.
  canvas.drawCircle(c.translate(0, 0), 2.6, Paint()..color = KathaInk.marigold);
}

void _wifi(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  final arc = Paint()
    ..color = KathaInk.teal
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round;
  for (final r in [4.0, 8.0, 12.0]) {
    canvas.drawArc(
      Rect.fromCircle(center: c.translate(0, 7), radius: r),
      -math.pi * 0.78,
      math.pi * 0.56,
      false,
      arc,
    );
  }
  canvas.drawCircle(c.translate(0, 7), 1.8, Paint()..color = KathaInk.teal);
}

void _calendar(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  // A month: a calendar page with its rings.
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 9,
      c.dy - 7,
      c.dx + 9,
      c.dy + 9,
      const Radius.circular(2),
    ),
    Paint()..color = KathaInk.paper,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 9,
      c.dy - 7,
      c.dx + 9,
      c.dy + 9,
      const Radius.circular(2),
    ),
    stroke..strokeWidth = 1.2,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 9, c.dy - 7, c.dx + 9, c.dy - 2),
    Paint()..color = KathaInk.brick,
  );
  for (final x in [-4.0, 4.0]) {
    canvas.drawLine(
      c.translate(x, -10),
      c.translate(x, -5),
      stroke..strokeWidth = 1.6,
    );
  }
  for (var row = 0; row < 2; row++) {
    for (var col = 0; col < 3; col++) {
      canvas.drawRect(
        Rect.fromLTWH(c.dx - 6 + col * 4.5, c.dy + 0.5 + row * 4, 2.4, 2),
        Paint()..color = KathaInk.ink.withValues(alpha: 0.5),
      );
    }
  }
}

void _clock(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  final red = Paint()..color = KathaInk.brick;
  canvas.drawCircle(c.translate(-6, -7), 3, red);
  canvas.drawCircle(c.translate(6, -7), 3, red);
  canvas.drawCircle(c, 8, red);
  canvas.drawCircle(c, 6, Paint()..color = const Color(0xFFFFFFFF));
  canvas.drawLine(c, c.translate(0, -4.4), stroke..strokeWidth = 1.2);
  canvas.drawLine(c, c.translate(3, 1), stroke);
}

void _rupee(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  // A banknote with the rupee sign.
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 10,
      c.dy - 6.5,
      c.dx + 10,
      c.dy + 6.5,
      const Radius.circular(2),
    ),
    Paint()..color = Color.lerp(KathaInk.leaf, KathaInk.paper, 0.45)!,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 10,
      c.dy - 6.5,
      c.dx + 10,
      c.dy + 6.5,
      const Radius.circular(2),
    ),
    stroke..color = KathaInk.leaf,
  );
  drawGlyph(canvas, '₹', c, KathaInk.ink, size: 11);
}

void _meter(BubbleIconPen pen) => _meterFace(pen, broken: false);

void _meterBroken(BubbleIconPen pen) => _meterFace(pen, broken: true);

/// The taxi meter: a working one shows dashes, a broken one a red cross.
void _meterFace(BubbleIconPen pen, {required bool broken}) {
  final BubbleIconPen(:canvas, :c, :ink) = pen;
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 10,
      c.dy - 7,
      c.dx + 10,
      c.dy + 7,
      const Radius.circular(2.5),
    ),
    ink,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 7, c.dy - 4, c.dx + 7, c.dy + 4),
    Paint()..color = KathaInk.paper,
  );
  final mark = Paint()
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  if (broken) {
    mark.color = KathaInk.brick;
    canvas.drawLine(
      Offset(c.dx - 3, c.dy - 2.5),
      Offset(c.dx + 3, c.dy + 2.5),
      mark,
    );
    canvas.drawLine(
      Offset(c.dx + 3, c.dy - 2.5),
      Offset(c.dx - 3, c.dy + 2.5),
      mark,
    );
  } else {
    mark.color = KathaInk.teal;
    canvas.drawLine(Offset(c.dx - 5, c.dy), Offset(c.dx - 1, c.dy), mark);
    canvas.drawLine(Offset(c.dx + 1, c.dy), Offset(c.dx + 5, c.dy), mark);
  }
}

void _auto(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink) = pen;
  // The rickshaw in miniature: canopy, body, two wheels.
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 9,
      c.dy - 9,
      c.dx + 9,
      c.dy + 1,
      const Radius.circular(4),
    ),
    ink,
  );
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 10,
      c.dy - 1,
      c.dx + 10,
      c.dy + 6,
      const Radius.circular(2),
    ),
    Paint()..color = KathaInk.marigold,
  );
  canvas.drawCircle(Offset(c.dx - 6, c.dy + 7), 3, ink);
  canvas.drawCircle(Offset(c.dx + 6, c.dy + 7), 3, ink);
}

void _traffic(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // Three cars nose to tail.
  for (final (x, y, color) in [
    (-6.0, -5.0, KathaInk.teal),
    (4.0, -1.0, KathaInk.brick),
    (-4.0, 6.0, KathaInk.marigold),
  ]) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        c.dx + x - 5,
        c.dy + y - 2.6,
        c.dx + x + 5,
        c.dy + y + 2.6,
        const Radius.circular(1.6),
      ),
      Paint()..color = color,
    );
  }
}

void _plane(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink) = pen;
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 13, c.dy + 2)
      ..lineTo(c.dx + 12, c.dy - 3)
      ..quadraticBezierTo(c.dx + 15, c.dy - 2, c.dx + 12, c.dy + 1)
      ..close(),
    ink,
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 2, c.dy)
      ..lineTo(c.dx - 8, c.dy - 11)
      ..lineTo(c.dx - 4, c.dy - 11)
      ..lineTo(c.dx + 5, c.dy - 1)
      ..close(),
    ink,
  );
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 1, c.dy + 1)
      ..lineTo(c.dx - 6, c.dy + 10)
      ..lineTo(c.dx - 2, c.dy + 10)
      ..lineTo(c.dx + 5, c.dy + 1)
      ..close(),
    ink,
  );
}

void _suitcase(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink, :stroke) = pen;
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 10,
      c.dy - 6,
      c.dx + 10,
      c.dy + 11,
      const Radius.circular(3),
    ),
    Paint()..color = KathaInk.teal,
  );
  canvas.drawLine(
    c.translate(0, -6),
    c.translate(0, -13),
    stroke..strokeWidth = 1.8,
  );
  canvas.drawLine(c.translate(-4, -13), c.translate(4, -13), stroke);
  for (final dx in [-6.0, 6.0]) {
    canvas.drawCircle(c.translate(dx, 13), 1.8, ink);
  }
}

void _poster(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 13, c.dy - 10, c.dx + 13, c.dy + 8),
    Paint()..color = KathaInk.paper,
  );
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 13, c.dy - 10, c.dx + 13, c.dy + 8),
    stroke..strokeWidth = 1.2,
  );
  canvas.drawCircle(
    c.translate(-5, -2),
    4.4,
    Paint()..color = KathaInk.skinDeep,
  );
  canvas.drawCircle(c.translate(6, -2), 4, Paint()..color = KathaInk.skinWarm);
  canvas.drawRect(
    Rect.fromLTRB(c.dx - 13, c.dy + 4, c.dx + 13, c.dy + 8),
    Paint()..color = KathaInk.teal,
  );
  canvas.drawLine(c.translate(-9, 8), c.translate(-9, 13), stroke);
  canvas.drawLine(c.translate(9, 8), c.translate(9, 13), stroke);
}

void _mic(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink, :stroke) = pen;
  canvas.drawRRect(
    RRect.fromLTRBR(
      c.dx - 5,
      c.dy - 13,
      c.dx + 5,
      c.dy + 2,
      const Radius.circular(5),
    ),
    ink,
  );
  canvas.drawArc(
    Rect.fromLTRB(c.dx - 9, c.dy - 6, c.dx + 9, c.dy + 7),
    0,
    math.pi,
    false,
    stroke..strokeWidth = 1.6,
  );
  canvas.drawLine(c.translate(0, 7), c.translate(0, 12), stroke);
  canvas.drawLine(c.translate(-5, 12), c.translate(5, 12), stroke);
}

void _pin(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // A map pin: where?
  canvas.drawPath(
    Path()
      ..moveTo(c.dx, c.dy + 10)
      ..cubicTo(c.dx - 12, c.dy - 2, c.dx - 7, c.dy - 10, c.dx, c.dy - 10)
      ..cubicTo(c.dx + 7, c.dy - 10, c.dx + 12, c.dy - 2, c.dx, c.dy + 10)
      ..close(),
    Paint()..color = KathaInk.brick,
  );
  canvas.drawCircle(c.translate(0, -3), 3, Paint()..color = KathaInk.paper);
}
