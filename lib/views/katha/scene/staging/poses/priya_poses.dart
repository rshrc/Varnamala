import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/priya.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// Priya, drawn in each pose the stories use.
extension PriyaPoses on KathaStaging {
  List<Component> placePriya(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case _:
        return [
          register(
            buildPriya(
              id: placement.id,
              feet: Vector2(x, ground),
              facing: facing(placement),
            ),
          ),
        ];
    }
  }
}
