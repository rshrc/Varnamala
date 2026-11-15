import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_morpheme.freezed.dart';
part 'katha_morpheme.g.dart';

/// A meaningful part of a word: `uur` (town), `ige` (to).
@Freezed(toJson: false)
abstract class KathaMorpheme with _$KathaMorpheme {
  const factory KathaMorpheme({
    @JsonKey(name: 'r') required String roman,

    /// Shared grammar code: `DIR`, `NEG`, `Q` ...
    @JsonKey(name: 'fn') String? function,
  }) = _KathaMorpheme;

  factory KathaMorpheme.fromJson(Map<String, dynamic> json) =>
      _$KathaMorphemeFromJson(json);
}
