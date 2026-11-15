import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_word_time.freezed.dart';

/// When a word is spoken in its line's recording, in milliseconds.
@freezed
abstract class KathaWordTime with _$KathaWordTime {
  const factory KathaWordTime({required int start, required int end}) =
      _KathaWordTime;
}

/// Reads a word time as the content stores it: `[start, end]`.
class KathaWordTimeConverter
    implements JsonConverter<KathaWordTime?, List<dynamic>?> {
  const KathaWordTimeConverter();

  @override
  KathaWordTime? fromJson(List<dynamic>? json) => switch (json) {
    [final int start, final int end] => KathaWordTime(start: start, end: end),
    _ => null,
  };

  @override
  List<int>? toJson(KathaWordTime? time) =>
      time == null ? null : [time.start, time.end];
}
