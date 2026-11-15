import 'package:flame/components.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/sets/fair.dart';
import 'package:words625/views/katha/scene/sets/hall.dart';
import 'package:words625/views/katha/scene/sets/lake.dart';
import 'package:words625/views/katha/scene/sets/pg_room.dart';
import 'package:words625/views/katha/scene/staging/poses/amma_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/boss_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/chaiwala_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/cow_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/daughter_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/dev_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/kid_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/landlady_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/neta_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/priya_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/raju_poses.dart';
import 'package:words625/views/katha/scene/staging/poses/son_poses.dart';

/// Turns a panel's cast and props into what is drawn: who stands where, in
/// which pose, and the things around them. Each character's poses are in
/// staging/poses/, the props in katha_props.dart.
class KathaStaging {
  KathaStaging({
    required this.panel,
    required this.register,
    required this.actors,
  });

  final KathaPanel panel;

  /// Records an actor, so cues can find it by id.
  final T Function<T extends KathaActor>(T actor) register;

  /// Every actor registered so far, by id.
  final Map<String, KathaActor> actors;

  /// [placement] drawn: the character in their pose, with anything the
  /// pose brings along (the auto Raju sits in, the bed Dev lies in).
  List<Component> place(KathaPlacement placement) => switch (placement.rig) {
    'char.raju' => placeRaju(placement),
    'char.dev' => placeDev(placement),
    'char.chaiwala' => placeChaiwala(placement),
    'char.priya' => placePriya(placement),
    'char.boss' => placeBoss(placement),
    'char.son' => placeSon(placement),
    'char.daughter' => placeDaughter(placement),
    'char.amma' => placeAmma(placement),
    'char.neta' => placeNeta(placement),
    'char.kid' => placeKid(placement),
    'char.landlady' => placeLandlady(placement),
    'char.cow' => placeCow(placement),
    _ => unplaced(placement),
  };

  /// A pose with no art yet: nothing is drawn, and the gap is logged.
  List<Component> unplaced(KathaPlacement placement) {
    logger.w('Katha: no art yet for ${placement.rig} / ${placement.pose}');
    return [];
  }

  /// Where feet meet the floor in this panel's backdrop.
  double get ground => switch (panel.background) {
    'bg.chai_stall' => 250,
    'bg.pg_room' || 'bg.pg_room_night' => 222,
    'bg.home_dining' => 228,
    'bg.office' => 226,
    'bg.kitchen' || 'bg.meeting_room' => 226,
    'bg.terrace' || 'bg.terrace_night' || 'bg.terrace_festival' => 230,
    'bg.ward_meeting' => 232,
    'bg.lake_dawn' || 'bg.lake_night' => LakeBackdrop.ground,
    'bg.fair' => FairBackdrop.ground,
    'bg.hall' => HallBackdrop.ground,
    _ => 216,
  };

  /// Characters face the middle of the picture, toward whoever they are
  /// talking to.
  double facing(KathaPlacement placement) => placement.x < 0.5 ? 1 : -1;

  /// Where [id] stands, across the picture.
  double xOf(String id) =>
      (panel.characters.where((c) => c.id == id).firstOrNull?.x ?? 0.5) *
      kathaWorldWidth;

  /// Where [id]'s head is in the picture, for props that hang round it.
  Vector2 headOf(String id) {
    final placement = panel.characters.where((c) => c.id == id).firstOrNull;
    if (placement == null) return Vector2(200, 120);
    final x = placement.x * kathaWorldWidth;
    return switch (placement.pose) {
      'in_bed' || 'asleep' => Vector2(x - 3, 177 + BedBack.drop),
      final pose when pose.startsWith('on_bed') => Vector2(
        x,
        BedBack.mattressTop + BedBack.drop + 50 - 107,
      ),
      _ => Vector2(x, ground - 107),
    };
  }
}
