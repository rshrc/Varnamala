import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

/// One word in a vocabulary level.
///
/// [concept] names a shared, language-independent idea from
/// `assets/courses/concepts.json` - it carries the English label and the
/// picture, so an apple is drawn the same way in all thirteen languages.
/// [word] is the romanized target-language word, and is the only part that
/// changes between them.
@freezed
abstract class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String concept,
    required String word,

    /// Overrides the concept's English label where a language needs a narrower
    /// one, such as an elder brother having its own word.
    String? gloss,
  }) = _VocabularyWord;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) =>
      _$VocabularyWordFromJson(json);
}
