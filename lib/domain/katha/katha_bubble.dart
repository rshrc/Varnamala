import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_bubble.freezed.dart';
part 'katha_bubble.g.dart';

/// A speech bubble made of pictures, for the mute test: someone who reads none
/// of the language must still follow the scene. Icons and digits only, never
/// words, so one bubble serves every language.
@Freezed(toJson: false)
abstract class KathaBubble with _$KathaBubble {
  const factory KathaBubble({@Default([]) List<String> icons, String? digits}) =
      _KathaBubble;

  factory KathaBubble.fromJson(Map<String, dynamic> json) =>
      _$KathaBubbleFromJson(json);
}
