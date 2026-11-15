import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// `bg.fair`: the groundnut fair in the evening. Striped stalls down a lane,
/// heaps of groundnuts in baskets, lanterns strung overhead, an old temple
/// tower beyond the trees.
class FairBackdrop extends PositionComponent {
  FairBackdrop() : super(priority: -10);

  static const ground = 230.0;

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    _paint(Canvas(recorder));
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    // Dusk.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, 140),
      fillOf(Color.lerp(const Color(0xFF2E3B5E), kathaDawnPink, 0.35)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 100, kathaWorldWidth, 140),
      fillOf(Color.lerp(kathaDawnPink, kathaDawnGold, 0.4)!),
    );
    // The temple tower, stepped, beyond the trees.
    final stone = fillOf(
      Color.lerp(const Color(0xFF2E3B5E), KathaInk.ink, 0.3)!,
    );
    for (var i = 0; i < 6; i++) {
      final w = 70.0 - i * 10;
      canvas.drawRect(Rect.fromLTWH(200 - w / 2, 110 - i * 12.0, w, 13), stone);
    }
    canvas.drawCircle(const Offset(200, 36), 5, fillOf(KathaInk.marigold));
    for (final (x, r) in [
      (110.0, 34.0),
      (150.0, 26.0),
      (270.0, 30.0),
      (320.0, 36.0),
    ]) {
      canvas.drawCircle(
        Offset(x, 124),
        r,
        fillOf(Color.lerp(KathaInk.leafShade, KathaInk.ink, 0.35)!),
      );
    }
    // The lane.
    canvas.drawRect(
      const Rect.fromLTRB(0, 140, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.marigoldShade, 0.4)!),
    );
    // Stalls on both sides, striped canopies.
    for (final (l, r) in [(0.0, 120.0), (290.0, 400.0)]) {
      canvas.drawRect(
        Rect.fromLTRB(l, 150, r, 206),
        fillOf(Color.lerp(KathaInk.brick, KathaInk.ink, 0.3)!),
      );
      for (var x = l; x < r; x += 16) {
        canvas.drawRect(
          Rect.fromLTWH(x, 136, 8, 16),
          fillOf(KathaInk.marigold),
        );
        canvas.drawRect(
          Rect.fromLTWH(x + 8, 136, 8, 16),
          fillOf(KathaInk.paper),
        );
      }
      // Baskets heaped with groundnuts.
      for (var x = l + 18; x < r - 10; x += 34) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 14, 204)
            ..lineTo(x + 14, 204)
            ..lineTo(x + 11, 222)
            ..lineTo(x - 11, 222)
            ..close(),
          fillOf(KathaInk.marigoldShade),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, 200), width: 30, height: 18),
          fillOf(const Color(0xFFC9A46A)),
        );
        for (var k = 0; k < 6; k++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(x - 9 + k * 3.6, 196 + (k % 2) * 4.0),
              width: 5,
              height: 3,
            ),
            fillOf(const Color(0xFF9C7A45)),
          );
        }
      }
    }
    // Lanterns strung across the lane.
    canvas.drawPath(
      Path()
        ..moveTo(0, 60)
        ..quadraticBezierTo(200, 92, 400, 60),
      Paint()
        ..color = KathaInk.ink.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (var i = 1; i < 12; i++) {
      final x = i * 33.0;
      final y = 60 + 32 * (1 - math.pow((x - 200) / 200, 2)).toDouble() * 0.5;
      canvas.drawCircle(
        Offset(x, y + 6),
        9,
        fillOf(kathaDawnGold.withValues(alpha: 0.25)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y + 6), width: 8, height: 11),
        fillOf(i.isEven ? KathaInk.brick : KathaInk.marigold),
      );
    }
  }
}
