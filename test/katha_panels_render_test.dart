import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:words625/courses/katha.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/katha_panel_game.dart';
import 'package:words625/views/katha/scene/staging/katha_backdrops.dart';

/// Every panel of every episode loads and draws its first frame.
///
/// With `KATHA_SNAPSHOTS=<dir>` it also saves each frame as
/// `<dir>/<episode>-<panel>.png`, so a refactor of the art can be checked
/// pixel for pixel against a run from before it:
///
///   KATHA_SNAPSHOTS=/tmp/before flutter test test/katha_panels_render_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final out = Platform.environment['KATHA_SNAPSHOTS'];

  testWidgets('every Katha panel renders', (tester) async {
    await tester.runAsync(() async {
      final repository = KathaRepository();
      var drawn = 0;
      for (final episode in KathaCatalogue.episodes) {
        final story = await repository.load(
          series: KathaCatalogue.series,
          episode: episode,
          lang: 'kn',
        );
        for (final panel in story.scene.panels) {
          if (!kathaDrawnBackdrops.contains(panel.background)) continue;
          final game = await initializeGame(
            () => KathaPanelGame(scene: story.scene, panel: panel),
          );
          game.onGameResize(Vector2(kathaWorldWidth, kathaWorldHeight));
          await game.ready();
          game.update(0);

          final recorder = ui.PictureRecorder();
          game.render(ui.Canvas(recorder));
          final image = await recorder.endRecording().toImage(
            kathaWorldWidth.toInt(),
            kathaWorldHeight.toInt(),
          );
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          expect(png, isNotNull, reason: '$episode ${panel.id}');
          if (out != null) {
            File('$out/$episode-${panel.id}.png')
              ..createSync(recursive: true)
              ..writeAsBytesSync(png!.buffer.asUint8List());
          }
          game.close();
          drawn++;
        }
      }
      expect(drawn, greaterThan(KathaCatalogue.episodes.length));
    });
  });
}
