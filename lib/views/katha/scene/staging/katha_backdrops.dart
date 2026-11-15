import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/effects/night_tint.dart';
import 'package:words625/views/katha/scene/effects/weather.dart';
import 'package:words625/views/katha/scene/props/festival.dart';
import 'package:words625/views/katha/scene/sets/chai_stall.dart';
import 'package:words625/views/katha/scene/sets/cricket_lane.dart';
import 'package:words625/views/katha/scene/sets/fair.dart';
import 'package:words625/views/katha/scene/sets/hall.dart';
import 'package:words625/views/katha/scene/sets/home_dining.dart';
import 'package:words625/views/katha/scene/sets/kitchen.dart';
import 'package:words625/views/katha/scene/sets/lake.dart';
import 'package:words625/views/katha/scene/sets/meeting_room.dart';
import 'package:words625/views/katha/scene/sets/office.dart';
import 'package:words625/views/katha/scene/sets/pg_door.dart';
import 'package:words625/views/katha/scene/sets/pg_room.dart';
import 'package:words625/views/katha/scene/sets/signal.dart';
import 'package:words625/views/katha/scene/sets/street.dart';
import 'package:words625/views/katha/scene/sets/terrace.dart';
import 'package:words625/views/katha/scene/sets/ward_meeting.dart';

/// Backdrops that have been drawn. A panel set somewhere not yet drawn (the
/// bus stand) is skipped by the reader rather than shown blank.
const Set<String> kathaDrawnBackdrops = {
  'bg.street_auto',
  'bg.signal',
  'bg.pg_door',
  'bg.pg_door_night',
  'bg.pg_room',
  'bg.pg_room_night',
  'bg.home_dining',
  'bg.chai_stall',
  'bg.office',
  'bg.cricket_lane',
  'bg.flood',
  'bg.pg_door_rain',
  'bg.terrace',
  'bg.terrace_night',
  'bg.terrace_festival',
  'bg.kitchen',
  'bg.meeting_room',
  'bg.pg_door_festival',
  'bg.ward_meeting',
  'bg.lake_dawn',
  'bg.lake_night',
  'bg.fair',
  'bg.hall',
};

/// Actors a backdrop brings with it, which a cue can name like a prop: the
/// crane over the terrace, the lights on the house at Deepavali.
const Map<String, Set<String>> kathaBackdropActors = {
  'bg.terrace': {'crane'},
  'bg.terrace_night': {'crane'},
  'bg.terrace_festival': {'crane'},
  'bg.pg_door_festival': {'lights'},
  'bg.flood': {'flood', 'rain'},
  'bg.pg_door_rain': {'rain'},
  'bg.lake_dawn': {'foam'},
  'bg.lake_night': {'foam'},
};

/// A backdrop and the small lives going on in it.
List<Component> kathaBackground(String id) => switch (id) {
  'bg.signal' => [SignalBackdrop(), BanyanMonkey()],
  'bg.pg_door' => [PgDoorBackdrop(), WallSquirrel()],
  'bg.pg_door_night' => [PgDoorBackdrop(night: true), NightTint()],
  'bg.pg_room' => [PgRoomBackdrop()],
  'bg.pg_room_night' => [PgRoomBackdrop(), NightWindow(), NightTint()],
  'bg.home_dining' => [HomeDiningBackdrop(), HoardingLight()],
  'bg.chai_stall' => [ChaiStallBackdrop(), KettleSteam(at: Vector2(168, 136))],
  'bg.office' => [OfficeBackdrop()],
  'bg.terrace' => [TerraceBackdrop(), Crane(actorId: 'crane')],
  'bg.terrace_night' => [
    TerraceBackdrop(night: true),
    Crane(actorId: 'crane', night: true),
  ],
  // Deepavali night on the roof: a lamp on every few feet of parapet.
  'bg.terrace_festival' => [
    TerraceBackdrop(night: true),
    Crane(actorId: 'crane', night: true),
    TerraceLamps(),
  ],
  'bg.kitchen' => [KitchenBackdrop()],
  'bg.meeting_room' => [MeetingRoomBackdrop()],
  // The landlady's door on Deepavali: the lights sit over the night tint.
  'bg.pg_door_festival' => [
    PgDoorBackdrop(night: true),
    FestiveHouse(),
    NightTint(),
    FestiveGlow(actorId: 'lights'),
  ],
  'bg.ward_meeting' => [WardMeetingBackdrop(), StageFront()],
  'bg.lake_dawn' => [LakeBackdrop(), LakeFoam(actorId: 'foam')],
  'bg.fair' => [FairBackdrop()],
  'bg.hall' => [HallBackdrop(), Podium()],
  'bg.lake_night' => [
    LakeBackdrop(),
    LakeNight(),
    LakeFoam(actorId: 'foam'),
    NightTint(),
  ],
  'bg.cricket_lane' => [
    CricketLaneBackdrop(),
    ChalkPitch(),
    StreetDog(at: Vector2(28, 232)),
  ],
  // The street from the first episode, under water: same poster, same
  // pothole, somewhere under there.
  'bg.flood' => [
    StreetBackdrop(overcast: true),
    FloodWater(actorId: 'flood', level: 34),
    RainOverlay(actorId: 'rain'),
  ],
  'bg.pg_door_rain' => [
    PgDoorBackdrop(night: true),
    NightTint(),
    RainOverlay(actorId: 'rain'),
  ],
  _ => [
    StreetBackdrop(),
    StreetDog(),
    PosterCrow(),
    PosterFlap(),
    RoofCat(),
    KettleSteam(),
  ],
};
