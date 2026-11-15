import 'package:freezed_annotation/freezed_annotation.dart';

part 'katha_sentence.freezed.dart';

/// One sentence of a line: token indices [first] to [last], and its native
/// text to speak.
@freezed
abstract class KathaSentence with _$KathaSentence {
  const factory KathaSentence({
    required int first,
    required int last,
    required String native,
  }) = _KathaSentence;
}
