// Package imports:

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';
part 'course.g.dart';

@freezed
class Course with _$Course {
  const factory Course({
    required String courseName,
    String? courseId,
    String? language,
    List<Level>? levels,
    String? image,
    int? color,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

@freezed
class Level with _$Level {
  const factory Level({
    required int? level,
    List<Question>? questions,
    List<VocabularyWord>? words,
  }) = _Level;

  const Level._();

  factory Level.fromJson(Map<String, dynamic> json) => _$LevelFromJson(json);

  /// Whether this level teaches bare words rather than sentences.
  ///
  /// A level carries [questions] or [words], never both. The word courses come
  /// first on the path, because learners were being asked to assemble
  /// sentences out of vocabulary nobody had taught them.
  bool get isVocabulary => words != null && words!.isNotEmpty;
}

/// One word in a vocabulary level.
///
/// [concept] names a shared, language-independent idea from
/// `assets/courses/concepts.json` - it carries the English label and the
/// picture, so an apple is drawn the same way in all thirteen languages.
/// [word] is the romanized target-language word, and is the only part that
/// changes between them.
@freezed
class VocabularyWord with _$VocabularyWord {
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

@Freezed(makeCollectionsUnmodifiable: false)
class Question with _$Question {
  const factory Question({
    String? type,
    String? prompt,
    String? sentence,
    bool? sentenceIsTargetLanguage,
    List<String>? options,
    String? correctAnswer,
    String? translatedSentence,
  }) = _Question;

  // Empty constructor
  const Question._();

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  // getter which shuffles and returns the options
  List<String> get shuffledOptions {
    final List<String> options = List.from(this.options ?? []);
    options.shuffle();
    return options;
  }
}
