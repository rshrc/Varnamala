import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/kid.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// Chinnu, drawn in each pose the stories use.
extension KidPoses on KathaStaging {
  List<Component> placeKid(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case _:
        return [
          register(
            buildKid(
              id: placement.id,
              feet: Vector2(x, ground),
              sparkler: placement.pose == 'sparkler',
            ),
          ),
        ];
    }
  }
}
