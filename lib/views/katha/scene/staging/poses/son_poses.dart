import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/son.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/sets/home_dining.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// Kiran, the landlady's son, drawn in each pose the stories use.
extension SonPoses on KathaStaging {
  List<Component> placeSon(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case 'floor_meal':
        return [
          register(
            buildSon(
              id: placement.id,
              feet: Vector2(x, 268),
              facing: facing(placement),
              seated: true,
            ),
          ),
          FloorMeal(
            x: x,
            trousers: Color.lerp(KathaInk.ink, KathaInk.paper, 0.32),
            skin: Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.2)!,
          ),
        ];
      case final pose:
        return [
          register(
            buildSon(
              id: placement.id,
              feet: Vector2(x, ground),
              facing: facing(placement),
              carrying: switch (pose) {
                'standing_suitcase' => SonCarrying.suitcase,
                'standing_phone' => SonCarrying.phone,
                'standing_sweets' => SonCarrying.sweets,
                _ => SonCarrying.nothing,
              },
            ),
          ),
        ];
    }
  }
}
