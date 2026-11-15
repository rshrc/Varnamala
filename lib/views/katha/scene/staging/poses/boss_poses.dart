import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/boss.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/sets/home_dining.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// The boss, drawn in each pose the stories use.
extension BossPoses on KathaStaging {
  List<Component> placeBoss(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case 'floor_meal':
        // On the floor at his sister's, like everyone else.
        return [
          register(
            buildBoss(
              id: placement.id,
              feet: Vector2(x, 259),
              facing: facing(placement),
              seated: true,
            ),
          ),
          FloorMeal(
            x: x,
            trousers: Color.lerp(KathaInk.ink, KathaInk.paper, 0.18),
            skin: Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.5)!,
          ),
        ];
      case 'sitting':
        // Sitting on the lake steps, knees up, alone.
        return [
          register(
            buildBoss(
              id: placement.id,
              feet: Vector2(x, 252),
              facing: facing(placement),
              seated: true,
            ),
          ),
          FloorMeal(
            x: x,
            trousers: Color.lerp(KathaInk.ink, KathaInk.paper, 0.18),
            skin: Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.5)!,
            withPlate: false,
          ),
        ];
      case _:
        return [
          register(
            buildBoss(
              id: placement.id,
              feet: Vector2(x, ground),
              facing: facing(placement),
            ),
          ),
        ];
    }
  }
}
