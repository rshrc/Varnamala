import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/characters/dev.dart';
import 'package:words625/views/katha/scene/engine/face.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/props/auto_rickshaw.dart';
import 'package:words625/views/katha/scene/sets/home_dining.dart';
import 'package:words625/views/katha/scene/sets/pg_room.dart';
import 'package:words625/views/katha/scene/sets/ward_meeting.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// Dev, drawn in each pose the stories use.
extension DevPoses on KathaStaging {
  List<Component> placeDev(KathaPlacement placement) {
    final x = placement.x * kathaWorldWidth;
    switch (placement.pose) {
      case 'in_auto_back':
        // In the back seat, inside the auto that Raju's pose has drawn: only
        // his upper body shows above the side. The auto's front layer goes on
        // after him so it hides the rest.
        final driver = panel.characters
            .where((c) => c.rig == 'char.raju')
            .firstOrNull;
        final dx = driver == null ? 0.0 : driver.x * kathaWorldWidth - 260;
        return [
          register(
            buildDev(
              id: placement.id,
              feet: Vector2(x, 262),
              facing: -1,
              seated: true,
            ),
          ),
          AutoRickshawFront(dx: dx),
          AutoCharm(dx: dx),
        ];
      case 'batting':
        // In his stance at the stumps, side on to the bowler, bat grounded.
        return [
          register(
            buildDev(
              id: placement.id,
              feet: Vector2(x, ground),
              facing: -1,
              carrying: DevCarrying.bat,
              batting: true,
            ),
          ),
        ];
      case 'in_bed' || 'asleep':
        // Lying down, head on the pillow, under the quilt. The rig lies on its
        // side; the head turns back upright so the face still reads.
        final left = x - 40;
        final rig = buildDev(
          id: placement.id,
          feet: Vector2(left + 144, 179 + BedBack.drop),
          carrying: DevCarrying.nothing,
        )..angle = -math.pi / 2;
        // The head turns most of the way back up so the face still reads, but
        // not all the way: it rests tilted into the pillow, as a lying head
        // does, rather than standing bolt upright on a body lying flat.
        rig.head.angle = math.pi / 2 - 0.55;
        // The near arm would otherwise lift out of the quilt: lay it along
        // his side.
        rig.rightArm.angle = 0.25;
        // Settle, not just rest: rest is only what the face returns to, so on
        // its own the eyes stayed open until some move ended.
        if (placement.pose == 'asleep') rig.face.settle(FaceExpression.asleep);
        return [BedBack(left: left), register(rig), Blanket(left: left)];
      case final pose when pose.startsWith('on_bed'):
        // Sitting up on the edge of the bed: the mattress hides his legs.
        final left = x - 70;
        return [
          BedBack(left: left),
          register(
            buildDev(
              id: placement.id,
              feet: Vector2(x, BedBack.mattressTop + BedBack.drop + 50),
              facing: facing(placement),
              seated: true,
              carrying: switch (pose) {
                'on_bed_phone' => DevCarrying.phone,
                'on_bed_biscuits' => DevCarrying.biscuits,
                _ => DevCarrying.nothing,
              },
            ),
          ),
          BedFront(left: left, legsAt: x),
        ];
      case 'on_stage':
        // At the microphone, facing the crowd.
        return [
          register(
            buildDev(
              id: placement.id,
              feet: Vector2(x, WardMeetingBackdrop.stageTop),
              facing: facing(placement),
              carrying: DevCarrying.nothing,
            ),
          ),
        ];
      case 'floor_meal':
        // Cross-legged on the mat, a plate in front of him.
        return [
          register(
            buildDev(
              id: placement.id,
              feet: Vector2(x, 266),
              facing: facing(placement),
              seated: true,
              carrying: DevCarrying.nothing,
            ),
          ),
          FloorMeal(x: x),
        ];
      case final pose:
        return [
          register(
            buildDev(
              id: placement.id,
              feet: Vector2(x, ground),
              facing: facing(placement),
              carrying: switch (pose) {
                'standing_tea' => DevCarrying.tea,
                'standing_plate' => DevCarrying.plate,
                'standing_corn' => DevCarrying.corn,
                'standing_phone' => DevCarrying.phone,
                'standing_cylinder' => DevCarrying.cylinder,
                'standing' => DevCarrying.nothing,
                _ => DevCarrying.bag,
              },
            ),
          ),
        ];
    }
  }
}
