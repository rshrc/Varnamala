import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/core/answer_similarity.dart';
import 'package:words625/domain/exercise/model/exercise_response.dart';
import 'package:words625/domain/exercise/model/interactive_exercise.dart';
import 'package:words625/domain/exercise/response/text_exercise_response.dart';

part 'fill_blank_text_exercise.freezed.dart';

@freezed
abstract class FillBlankTextExercise
    with _$FillBlankTextExercise
    implements InteractiveExercise {
  const factory FillBlankTextExercise({
    required String id,
    required String prompt,
    required String explanation,
    required String beforeBlank,
    required String afterBlank,
    required String clue,
    required List<String> acceptedAnswers,
    String? wordMeaning,
    @Default({}) Map<String, String> dictionary,
    String? clueArt,
    InteractiveExercise? adaptiveRetry,
  }) = _FillBlankTextExercise;

  const FillBlankTextExercise._();

  TypedAnswerVerdict _judge(ExerciseResponse response) =>
      response is! TextExerciseResponse
      ? TypedAnswerVerdict.wrong
      : judgeTypedAnswer(
          typed: response.text,
          accepted: acceptedAnswers,
          dictionary: dictionary,
        );

  @override
  bool isCorrect(ExerciseResponse response) =>
      _judge(response) != TypedAnswerVerdict.wrong;

  @override
  String? spellingCorrection(ExerciseResponse response) =>
      _judge(response) == TypedAnswerVerdict.nearMiss
      ? acceptedAnswers.first
      : null;

  @override
  String get correctAnswerLabel => acceptedAnswers.first;
}
