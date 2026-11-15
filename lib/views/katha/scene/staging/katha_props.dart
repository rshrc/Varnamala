import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/effects/power_cut.dart';
import 'package:words625/views/katha/scene/effects/sleep.dart';
import 'package:words625/views/katha/scene/effects/weather.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/props/alarm_clock.dart';
import 'package:words625/views/katha/scene/props/amma_tiffin.dart';
import 'package:words625/views/katha/scene/props/auto_rickshaw.dart';
import 'package:words625/views/katha/scene/props/festival.dart';
import 'package:words625/views/katha/scene/props/lake_cleanup.dart';
import 'package:words625/views/katha/scene/props/street_props.dart';
import 'package:words625/views/katha/scene/sets/cricket_lane.dart';
import 'package:words625/views/katha/scene/sets/kitchen.dart';
import 'package:words625/views/katha/scene/sets/lake.dart';
import 'package:words625/views/katha/scene/sets/meeting_room.dart';
import 'package:words625/views/katha/scene/sets/office.dart';
import 'package:words625/views/katha/scene/sets/pg_room.dart';
import 'package:words625/views/katha/scene/sets/signal.dart';
import 'package:words625/views/katha/scene/sets/ward_meeting.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// The props a panel names: things a cue can act on, and furniture that
/// just stands there.
extension KathaProps on KathaStaging {
  KathaActor? actorFor(KathaProp prop) {
    switch (prop.asset) {
      case 'prop.auto_meter':
        final driver = panel.characters
            .where((c) => '${c.id}.auto' == prop.attach)
            .firstOrNull;
        final dx = driver == null ? 0.0 : driver.x * kathaWorldWidth - 260;
        return AutoMeter(actorId: prop.id, position: Vector2(212 + dx, 150));
      case 'prop.traffic_signal':
        return TrafficSignal(actorId: prop.id);
      case 'prop.ceiling_fan':
        return CeilingFan(actorId: prop.id);
      case 'prop.alarm_clock':
        return AlarmClock(actorId: prop.id);
      case 'prop.ball':
        return CricketBall(actorId: prop.id);
      case 'prop.wicket':
        return Wicket(actorId: prop.id);
      case 'prop.rain':
        return RainOverlay(actorId: prop.id);
      case 'prop.rain_coming':
        return RainOverlay(actorId: prop.id, falling: false);
      case 'prop.flood_rising':
        return FloodWater(actorId: prop.id, level: 48, rises: true);
      case 'prop.mosquito':
        return Mosquito(
          actorId: prop.id,
          home: headOf('dev') + Vector2(18, -14),
        );
      case 'prop.sleep_zs':
        return SleepZs(actorId: prop.id, at: headOf('dev') + Vector2(10, -16));
      case 'prop.candle':
        return Candle(actorId: prop.id, at: Vector2(196, 238));
      case 'prop.power_cut':
        return PowerCut(actorId: prop.id);
      case 'prop.stove_flame':
        return StoveFlame(actorId: prop.id);
      case 'prop.stove_out':
        return StoveFlame(actorId: prop.id, lit: false);
      case 'prop.cooker':
        return PressureCooker(actorId: prop.id);
      case 'prop.pothole':
        return Pothole(actorId: prop.id, at: Vector2(118, 248));
      case 'prop.screen':
        return MeetingScreen(actorId: prop.id);
      case 'prop.diya':
        return Diya(actorId: prop.id, at: Vector2(200, 232));
      case 'prop.sparkler':
        final kid = actors['kid'];
        return kid is CutoutRig
            ? Sparkler(actorId: prop.id, holder: kid)
            : null;
      case 'prop.fireworks':
        return Fireworks(
          actorId: prop.id,
          sky: panel.background.startsWith('bg.terrace')
              ? const Rect.fromLTRB(20, 8, 380, 84)
              : const Rect.fromLTRB(10, 6, 170, 48),
        );
      case 'prop.mic':
        final speaker = panel.characters
            .where((c) => c.pose == 'on_stage' && c.rig != 'char.neta')
            .firstOrNull;
        final x = (speaker?.x ?? 0.6) * kathaWorldWidth;
        return MicStand(
          actorId: prop.id,
          at: Vector2(x - 26, WardMeetingBackdrop.stageTop),
        );
      case 'prop.crowd':
        return Crowd(actorId: prop.id);
      case 'prop.flash':
        return CameraFlash(actorId: prop.id);
      case 'prop.new_poster':
        return NewPoster(actorId: prop.id);
      case 'prop.dev_poster':
        return NewPoster(actorId: prop.id, startShown: true);
      case 'prop.test_bottle':
        return TestBottle(
          actorId: prop.id,
          at: Vector2(xOf('daughter') + 22, LakeBackdrop.ground - 2),
        );
      case 'prop.outfall':
        return OutfallPipe(actorId: prop.id);
      case 'prop.birds':
        return BirdFlock(actorId: prop.id);
      case 'prop.notice':
        return LakeNotice(actorId: prop.id);
      case 'prop.lake_fire':
        return LakeFireGlow(actorId: prop.id);
      case 'prop.marigolds':
        // From the hand of whoever is laying them: the landlady.
        return MarigoldOffering(
          actorId: prop.id,
          from: Vector2(xOf('landlady') - 14, LakeBackdrop.ground - 50),
        );
      case 'prop.tiffin':
        final amma = actors['amma'];
        return amma is CutoutRig
            ? AmmaTiffin(actorId: prop.id, holder: amma)
            : null;
      case 'prop.loudspeaker':
        return Loudspeaker(
          actorId: prop.id,
          at: Vector2(xOf('raju') + 36, 112),
        );
      default:
        logger.w('Katha: no art yet for ${prop.asset}');
        return null;
    }
  }

  /// Furniture and scenery that a prop names but no cue acts on.
  Component? setPieceFor(KathaProp prop) => switch (prop.asset) {
    'prop.lunch_table' => LunchTable(),
    'prop.water_tanker' => WaterTanker(),
    'prop.corn_cart' => CornCart(x: 56),
    'prop.spare_cylinder' => SpareCylinder(at: Vector2(124, 250)),
    'prop.cylinder_passenger' => CylinderPassenger(x: xOf('dev') - 32),
    'prop.ash' => LakeAsh(),
    'prop.cleanup' => CleanupSacks(),
    'prop.vessels' => FoodVessels(),
    'prop.meeting_table' => MeetingTable(
      laptops: [
        for (final c in panel.characters)
          if (c.id != 'boss') c.x * kathaWorldWidth,
      ],
    ),
    _ => null,
  };
}
