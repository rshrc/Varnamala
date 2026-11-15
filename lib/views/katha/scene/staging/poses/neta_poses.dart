import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/neta.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/sets/ward_meeting.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// The neta, drawn in each pose the stories use.
extension NetaPoses on KathaStaging {
  List<Component> placeNeta(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case final pose:
        return [
          register(
            buildNeta(
              id: placement.id,
              feet: Vector2(
                x,
                pose == 'on_stage' ? WardMeetingBackdrop.stageTop : ground,
              ),
              facing: facing(placement),
            ),
          ),
        ];
    }
  }
}
