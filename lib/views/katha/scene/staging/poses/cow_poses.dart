import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/sets/signal.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// The cow, drawn in each pose the stories use.
extension CowPoses on KathaStaging {
  List<Component> placeCow(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case _:
        return [
          register(RoadCow(actorId: placement.id, position: Vector2(x, 246))),
        ];
    }
  }
}
