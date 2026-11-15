import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/daughter.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/props/auto_rickshaw.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// Raju's daughter, drawn in each pose the stories use.
extension DaughterPoses on KathaStaging {
  List<Component> placeDaughter(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case 'in_auto_back':
        final driver = panel.characters
            .where((c) => c.rig == 'char.raju')
            .firstOrNull;
        final dx = driver == null ? 0.0 : driver.x * kathaWorldWidth - 260;
        return [
          register(
            buildDaughter(id: placement.id, feet: Vector2(x, 258), facing: -1),
          ),
          AutoRickshawFront(dx: dx),
          AutoCharm(dx: dx),
        ];
      case _:
        return [
          register(
            buildDaughter(
              id: placement.id,
              feet: Vector2(x, ground),
              facing: facing(placement),
            ),
          ),
        ];
    }
  }
}
