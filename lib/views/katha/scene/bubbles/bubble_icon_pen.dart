
import 'package:flutter/painting.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// Draws one icon with a [BubbleIconPen].
typedef BubbleIconPainter = void Function(BubbleIconPen pen);

/// What every bubble icon is drawn with: the canvas, the box it fills and
/// its centre, and the two pens most icons use.
final class BubbleIconPen {
  BubbleIconPen(this.canvas, this.box)
    : c = box.center,
      ink = Paint()..color = KathaInk.ink,
      stroke = Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;

  final Canvas canvas;
  final Rect box;

  /// The box's centre, which every icon is drawn around.
  final Offset c;

  /// Solid ink, for filled shapes.
  final Paint ink;

  /// A round-capped ink line.
  final Paint stroke;
}

/// [glyph] as bold text centred on [centre]: a `?`, a `₹`.
void drawGlyph(
  Canvas canvas,
  String glyph,
  Offset centre,
  Color color, {
  double size = 18,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: glyph,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w900,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
}
