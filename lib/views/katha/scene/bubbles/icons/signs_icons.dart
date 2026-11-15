
import 'package:flutter/painting.dart';
import 'package:words625/views/katha/scene/bubbles/bubble_icon_pen.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// Signs that answer, ask and react.
const signsIcons = <String, BubbleIconPainter>{
  'ok': _ok,
  'no': _no,
  'question': _question,
  'go': _go,
  'speech': _speech,
  'pinch': _pinch,
};

void _ok(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // A tick in a circle: agreed.
  canvas.drawCircle(c, 9, Paint()..color = KathaInk.leaf);
  canvas.drawPath(
    Path()
      ..moveTo(c.dx - 4.5, c.dy + 0.5)
      ..lineTo(c.dx - 1, c.dy + 4)
      ..lineTo(c.dx + 5, c.dy - 3.5),
    Paint()
      ..color = KathaInk.paper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}

void _no(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // A red circle, struck through: no.
  final red = Paint()
    ..color = KathaInk.brick
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.6;
  canvas.drawCircle(c, 8.5, red);
  canvas.drawLine(c.translate(-6, 6), c.translate(6, -6), red);
}

void _question(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  drawGlyph(canvas, '?', c, KathaInk.teal);
}

void _go(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c) = pen;
  // An arrow: move along.
  final arrow = Paint()
    ..color = KathaInk.brick
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(c.translate(-9, 0), c.translate(8, 0), arrow);
  canvas.drawPath(
    Path()
      ..moveTo(c.dx + 2, c.dy - 6)
      ..lineTo(c.dx + 8, c.dy)
      ..lineTo(c.dx + 2, c.dy + 6),
    arrow,
  );
}

void _speech(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :ink, :stroke) = pen;
  // Speaking: a little face with sound coming out of its mouth.
  canvas.drawCircle(
    c.translate(-4, 0),
    6.5,
    Paint()..color = KathaInk.skinWarm,
  );
  canvas.drawCircle(c.translate(-2, -1.5), 0.9, ink);
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(0, 2.4), width: 2.6, height: 2),
    ink,
  );
  for (final r in [4.0, 7.0]) {
    canvas.drawArc(
      Rect.fromCircle(center: c.translate(3, 2), radius: r),
      -0.6,
      1.2,
      false,
      stroke,
    );
  }
}

void _pinch(BubbleIconPen pen) {
  final BubbleIconPen(:canvas, :c, :stroke) = pen;
  // Finger and thumb almost touching: "a little".
  final skin = Paint()
    ..color = KathaInk.skinWarm
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(c.translate(-6, 8), c.translate(-2, -6), skin);
  canvas.drawLine(c.translate(6, 8), c.translate(2, -2), skin);
  canvas.drawLine(
    c.translate(-1, -8),
    c.translate(1, -5),
    stroke..strokeWidth = 1,
  );
}
