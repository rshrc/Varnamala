import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/landlady.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/sets/ward_meeting.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// The landlady, drawn in each pose the stories use.
extension LandladyPoses on KathaStaging {
  List<Component> placeLandlady(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case _:
        // On her doorstep at the door; on the floor indoors.
        final step = placement.pose == 'on_stage'
            ? WardMeetingBackdrop.stageTop
            : panel.background.startsWith('bg.pg_door')
            ? 208.0
            : ground;
        return [
          register(
            buildLandlady(
              id: placement.id,
              feet: Vector2(x, step),
              ladle: placement.pose == 'serving' || placement.pose == 'cooking',
            ),
          ),
        ];
    }
  }
}
