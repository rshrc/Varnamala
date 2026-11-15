import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/katha/katha_morpheme.dart';
import 'package:words625/domain/katha/katha_word_time.dart';

part 'katha_token.freezed.dart';
part 'katha_token.g.dart';

/// One word of a line, with everything the reader can show about it.
@Freezed(toJson: false)
abstract class KathaToken with _$KathaToken {
  const factory KathaToken({
    /// Precise roman spelling: capitals for retroflexes, `~` for nasalisation.
    @JsonKey(name: 'r') required String roman,
    @JsonKey(name: 'n') required String native,

    /// The dictionary form.
    @JsonKey(name: 'l') required String lemma,

    /// What it means here, in English.
    @JsonKey(name: 'g') required String gloss,

    /// The scene cue this word fires and glows.
    String? cue,
    @JsonKey(name: 'loan') @Default(false) bool isLoan,
    @JsonKey(name: 'name') @Default(false) bool isName,

    /// The word's parts, for the grammar lens: `uur` + `ige` (to).
    @JsonKey(name: 'm') @Default([]) List<KathaMorpheme> morphemes,

    /// A grammar function for the whole word, such as Hindi `me~` (in).
    @JsonKey(name: 'fn') String? function,

    /// When the word is spoken in its line's recording.
    @JsonKey(name: 't') @KathaWordTimeConverter() KathaWordTime? time,
  }) = _KathaToken;

  factory KathaToken.fromJson(Map<String, dynamic> json) =>
      _$KathaTokenFromJson(json);
}
