import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/katha/scene/bubbles/bubble_icons.dart';

/// Every picture-bubble icon draws something.
///
/// With `KATHA_SNAPSHOTS=<dir>` each is also saved as
/// `<dir>/icon-<name>.png`, to compare a refactor pixel for pixel.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final out = Platform.environment['KATHA_SNAPSHOTS'];

  testWidgets('every bubble icon draws', (tester) async {
    await tester.runAsync(() async {
      for (final icon in kathaBubbleIcons) {
        final recorder = ui.PictureRecorder();
        drawBubbleIcon(
          ui.Canvas(recorder),
          icon,
          const ui.Rect.fromLTWH(0, 0, 40, 40),
        );
        final image = await recorder.endRecording().toImage(40, 40);
        final bytes = await image.toByteData();
        final inked = bytes!.buffer.asUint8List().any((byte) => byte != 0);
        expect(inked, isTrue, reason: '$icon drew nothing');
        if (out != null) {
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$out/icon-$icon.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(png!.buffer.asUint8List());
        }
      }
    });
  });
}
