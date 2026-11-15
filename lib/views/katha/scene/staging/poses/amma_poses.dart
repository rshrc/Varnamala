import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/amma.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/props/auto_rickshaw.dart';
import 'package:words625/views/katha/scene/sets/ward_meeting.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// Dev's Amma, drawn in each pose the stories use.
extension AmmaPoses on KathaStaging {
  List<Component> placeAmma(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case 'in_auto_back':
        // In the back of the auto, like Dev on his first day.
        final driver = panel.characters
            .where((c) => c.rig == 'char.raju')
            .firstOrNull;
        final dx = driver == null ? 0.0 : driver.x * kathaWorldWidth - 260;
        return [
          register(
            buildAmma(
              id: placement.id,
              feet: Vector2(x, 256),
              facing: -1,
              seated: true,
            ),
          ),
          AutoRickshawFront(dx: dx),
          AutoCharm(dx: dx),
        ];
      case final pose:
        return [
          register(
            buildAmma(
              id: placement.id,
              feet: Vector2(
                x,
                placement.pose == 'on_stage'
                    ? WardMeetingBackdrop.stageTop
                    : panel.background.startsWith('bg.pg_door')
                    ? 212
                    : ground,
              ),
              facing: facing(placement),
              carrying: switch (pose) {
                'standing_suitcase' => AmmaCarrying.suitcase,
                'standing_tiffin' => AmmaCarrying.tiffin,
                'standing_jar' => AmmaCarrying.jar,
                'standing_phone' => AmmaCarrying.phone,
                _ => AmmaCarrying.nothing,
              },
            ),
          ),
        ];
    }
  }
}
