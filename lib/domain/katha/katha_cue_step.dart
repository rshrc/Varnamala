import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_cue_step.freezed.dart';
part 'katha_cue_step.g.dart';

/// A cue set off by another, [after] milliseconds later.
@Freezed(toJson: false)
abstract class KathaCueStep with _$KathaCueStep {
  const factory KathaCueStep({required String cue, required int after}) =
      _KathaCueStep;

  factory KathaCueStep.fromJson(Map<String, dynamic> json) =>
      _$KathaCueStepFromJson(json);
}
