import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/bubbles/bubble_icons.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// A speech bubble drawn in pictures, shown in mute mode in place of the
/// text. It carries icons and digits only, so it says the same thing in every
/// language - and to someone who reads none of them.
class PictureBubble extends PositionComponent {
  PictureBubble({required this.bubble, required Vector2 speaker, this.lean = 0})
    : super(position: speaker, priority: 50, anchor: Anchor.bottomCenter);

  final KathaBubble bubble;

  /// -1 grows the bubble out to the left of the speaker, +1 to the right, 0
  /// centres it. Bubbles lean away from the middle of the picture, so they
  /// do not cover what is going on between the characters - or the hoarding
  /// behind them.
  final double lean;

  /// Where the tail meets the bubble, from its left edge.
  double get _tailX => size.x / 2 - lean * (size.x / 2 - 16);

  static const _iconSize = 22.0;
  static const _gap = 4.0;
  static const _pad = 6.0;
  static const _tail = 9.0;

  late final TextPainter? _digits = bubble.digits == null
      ? null
      : (TextPainter(
          text: TextSpan(
            text: bubble.digits,
            style: const TextStyle(
              color: KathaInk.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout());

  double get _contentWidth {
    var width =
        bubble.icons.length * _iconSize +
        math.max(0, bubble.icons.length - 1) * _gap;
    if (_digits != null) width += _gap + _digits.width;
    return width;
  }

  @override
  Future<void> onLoad() async {
    size = Vector2(_contentWidth + _pad * 2, _iconSize + _pad * 2 + _tail);
    // Keep the tail over the speaker: slide the body the other way.
    position.x += size.x / 2 - _tailX;
  }

  /// Pops in, unless motion is reduced.
  void popIn({required bool reducedMotion}) {
    if (reducedMotion) return;
    scale = Vector2.all(0.7);
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.18, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final body = RRect.fromLTRBR(
      0,
      0,
      size.x,
      size.y - _tail,
      const Radius.circular(10),
    );
    final tail = Path()
      ..moveTo(_tailX - 6, size.y - _tail - 1)
      ..lineTo(_tailX, size.y)
      ..lineTo(_tailX + 6, size.y - _tail - 1)
      ..close();
    final fill = Paint()..color = KathaInk.paper;
    final outline = Paint()
      ..color = KathaInk.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, outline);
    canvas.drawPath(tail, fill);
    canvas.drawLine(
      Offset(_tailX - 6, size.y - _tail),
      Offset(_tailX, size.y),
      outline,
    );
    canvas.drawLine(
      Offset(_tailX, size.y),
      Offset(_tailX + 6, size.y - _tail),
      outline,
    );

    var x = _pad;
    for (final (i, icon) in bubble.icons.indexed) {
      // The number belongs to the first picture: the note it is printed on,
      // the calendar it counts.
      final box = Rect.fromLTWH(x, _pad, _iconSize, _iconSize);
      drawBubbleIcon(canvas, icon, box);
      x += _iconSize + _gap;
      if (i == 0 && _digits != null) {
        _digits.paint(
          canvas,
          Offset(x - 1, _pad + (_iconSize - _digits.height) / 2),
        );
        x += _digits.width + _gap;
      }
    }
    if (bubble.icons.isEmpty && _digits != null) {
      _digits.paint(canvas, Offset(x, _pad + (_iconSize - _digits.height) / 2));
    }
  }
}
