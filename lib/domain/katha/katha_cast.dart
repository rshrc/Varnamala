import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_cast.freezed.dart';
part 'katha_cast.g.dart';

/// A character's voice, as far as a device voice can be cast: who they are
/// ([gender]), and where they sit relative to the plain voice.
@Freezed(toJson: false)
abstract class KathaCast with _$KathaCast {
  const factory KathaCast({
    /// `male` or `female`.
    required String gender,
    @Default(1.0) double pitch,
    @Default(1.0) double rate,
  }) = _KathaCast;

  factory KathaCast.fromJson(Map<String, dynamic> json) =>
      _$KathaCastFromJson(json);
}
