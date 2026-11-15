import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_placement.freezed.dart';
part 'katha_placement.g.dart';

/// A character standing somewhere in a panel.
@Freezed(toJson: false)
abstract class KathaPlacement with _$KathaPlacement {
  const factory KathaPlacement({
    required String id,
    required String rig,

    /// How they stand: `standing`, `in_auto`, `arms_crossed` ...
    required String pose,

    /// Horizontal position as a fraction of the panel's width.
    required double x,
  }) = _KathaPlacement;

  factory KathaPlacement.fromJson(Map<String, dynamic> json) =>
      _$KathaPlacementFromJson(json);
}
