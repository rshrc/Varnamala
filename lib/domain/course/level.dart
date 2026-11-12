import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/course/question.dart';
import 'package:words625/domain/course/vocabulary_word.dart';

part 'level.freezed.dart';
part 'level.g.dart';

@freezed
abstract class Level with _$Level {
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
