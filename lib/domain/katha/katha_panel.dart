import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/katha/katha_placement.dart';
import 'package:words625/domain/katha/katha_prop.dart';

part 'katha_panel.freezed.dart';
part 'katha_panel.g.dart';

/// One picture of an episode: a set, who stands in it, and what is in it.
@Freezed(toJson: false)
abstract class KathaPanel with _$KathaPanel {
  const factory KathaPanel({
    required String id,

    /// The set, such as `bg.street_auto`.
    required String background,
    @Default([]) List<KathaPlacement> characters,
    @Default([]) List<KathaProp> props,
  }) = _KathaPanel;

  factory KathaPanel.fromJson(Map<String, dynamic> json) =>
      _$KathaPanelFromJson(json);
}
