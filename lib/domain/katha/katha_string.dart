import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_string.freezed.dart';
part 'katha_string.g.dart';

/// A short piece of text in a telling: a title, a tease, a name.
@Freezed(toJson: false)
abstract class KathaString with _$KathaString {
  const factory KathaString({
    @JsonKey(name: 'n') required String native,
    @JsonKey(name: 'r') required String roman,

    /// In English.
    @JsonKey(name: 'g') String? gloss,
  }) = _KathaString;

  factory KathaString.fromJson(Map<String, dynamic> json) =>
      _$KathaStringFromJson(json);
}
