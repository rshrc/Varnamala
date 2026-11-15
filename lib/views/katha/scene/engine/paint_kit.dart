import 'dart:ui';

Paint fillOf(Color color) => Paint()..color = color;

/// Digits and a few symbols painted straight onto the canvas, for signs: the
/// art may show numbers (prices, 24x7) but never words.
class TextPainterLite {
  TextPainterLite._(this._paragraph);

  final Paragraph _paragraph;

  static TextPainterLite digits(String text, double size, Color color) {
    final builder =
        ParagraphBuilder(
            ParagraphStyle(fontSize: size, fontWeight: FontWeight.w800),
          )
          ..pushStyle(
            TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w800,
            ),
          )
          ..addText(text);
    return TextPainterLite._(
      builder.build()..layout(const ParagraphConstraints(width: 200)),
    );
  }

  void paint(Canvas canvas, Offset at) => canvas.drawParagraph(_paragraph, at);
}

Paint strokeOf(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

Picture recordPicture(void Function(Canvas canvas) paint) {
  final recorder = PictureRecorder();
  paint(Canvas(recorder));
  return recorder.endRecording();
}

/// A tiny stand-in for flutter's easing, so this file needs no widgets.
abstract final class KathaEase {
  static double easeOut(double t) => 1 - (1 - t) * (1 - t);
}
