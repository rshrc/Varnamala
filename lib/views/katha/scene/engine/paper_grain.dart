import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// Paper grain over everything, a few percent strong: most of what makes a
/// flat drawing read as a storybook page. A fixed seed, so it never shimmers.
class PaperGrain extends PositionComponent {
  PaperGrain() : super(priority: 100);

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final random = math.Random(7);
    final dark = Paint()..color = KathaInk.ink.withValues(alpha: 0.05);
    final light = Paint()..color = KathaInk.paper.withValues(alpha: 0.08);
    for (var i = 0; i < 1600; i++) {
      final at = Offset(
        random.nextDouble() * kathaWorldWidth,
        random.nextDouble() * kathaWorldHeight,
      );
      canvas.drawCircle(
        at,
        0.35 + random.nextDouble() * 0.6,
        i.isEven ? dark : light,
      );
    }
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);
}
