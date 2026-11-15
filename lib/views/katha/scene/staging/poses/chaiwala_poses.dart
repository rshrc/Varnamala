import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/chaiwala.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/sets/chai_stall.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// The chaiwala, drawn in each pose the stories use.
extension ChaiwalaPoses on KathaStaging {
  List<Component> placeChaiwala(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case _:
        // Behind his counter: the counter is drawn after him and hides his legs.
        return [
          register(buildChaiwala(id: placement.id, waist: Vector2(x, 178))),
          ChaiCounterFront(),
        ];
    }
  }
}
