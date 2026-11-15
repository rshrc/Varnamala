import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/raju.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/props/auto_rickshaw.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// Raju, drawn in each pose the stories use.
extension RajuPoses on KathaStaging {
  List<Component> placeRaju(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case 'in_auto':
        // The auto is part of the pose: he sits inside it, so it is drawn in
        // two layers around him.
        final dx = x - 260;
        return [
          AutoRickshawBack(dx: dx),
          register(buildRaju(id: placement.id, seat: Vector2(x, 200))),
          AutoRickshawFront(dx: dx),
          AutoCharm(dx: dx),
        ];
      case 'in_auto_turned':
        // Same seat, turned round to talk to the passenger behind him.
        final dx = x - 260;
        return [
          AutoRickshawBack(dx: dx),
          register(
            buildRaju(id: placement.id, seat: Vector2(x, 200), facing: 1),
          ),
        ];
      case 'standing':
        return [
          register(
            buildRaju(
              id: placement.id,
              seat: Vector2(x, ground - 46),
              standing: true,
            ),
          ),
        ];
      default:
        return unplaced(placement);
    }
  }
}
