import 'dart:ui';

import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// The colour that ties a cue's words to its object: the target's link
/// colour. Known before the game loads, so the text can underline linked
/// words from the first frame.
Color? kathaLinkColor(KathaPanel panel, KathaCue? cue) {
  if (cue == null) return null;
  for (final character in panel.characters) {
    if (character.id == cue.target) {
      return switch (character.rig) {
        'char.dev' => KathaInk.teal,
        'char.raju' => KathaInk.brick,
        'char.landlady' => KathaInk.marigold,
        'char.cow' => KathaInk.brick,
        'char.chaiwala' => KathaInk.leaf,
        'char.priya' => KathaInk.marigoldShade,
        'char.boss' => KathaInk.ink,
        'char.kid' => KathaInk.brick,
        'char.son' => KathaInk.brick,
        'char.neta' => KathaInk.marigold,
        'char.amma' => KathaInk.brickShade,
        'char.daughter' => KathaInk.leafShade,
        _ => KathaInk.ink,
      };
    }
  }
  for (final prop in panel.props) {
    if (prop.id == cue.target) {
      return switch (prop.asset) {
        'prop.traffic_signal' => KathaInk.leaf,
        'prop.ceiling_fan' => KathaInk.teal,
        'prop.screen' ||
        'prop.stove_flame' ||
        'prop.stove_out' => KathaInk.teal,
        'prop.mic' || 'prop.crowd' || 'prop.pothole' => KathaInk.ink,
        'prop.ball' || 'prop.alarm_clock' => KathaInk.brick,
        'prop.rain' ||
        'prop.rain_coming' ||
        'prop.flood_rising' => KathaInk.teal,
        _ => KathaInk.marigold,
      };
    }
  }
  return null;
}
