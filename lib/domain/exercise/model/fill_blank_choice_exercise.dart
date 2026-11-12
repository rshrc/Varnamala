import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/model/exercise_option.dart';
import 'package:words625/domain/exercise/model/exercise_response.dart';
import 'package:words625/domain/exercise/model/interactive_exercise.dart';
import 'package:words625/domain/exercise/response/choice_exercise_response.dart';

part 'fill_blank_choice_exercise.freezed.dart';

@freezed
abstract class FillBlankChoiceExercise
    with _$FillBlankChoiceExercise
    implements InteractiveExercise {
  const factory FillBlankChoiceExercise({
    required String id,
    required String prompt,
    required String explanation,
    required String beforeBlank,
    required String afterBlank,
    required String clue,
    required List<ExerciseOption> options,
    required String correctOptionId,
    InteractiveExercise? adaptiveRetry,
  }) = _FillBlankChoiceExercise;

  const FillBlankChoiceExercise._();

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is ChoiceExerciseResponse &&
      response.optionId == correctOptionId;

  @override
  String? spellingCorrection(ExerciseResponse response) => null;

  @override
  String get correctAnswerLabel =>
      options.firstWhere((option) => option.id == correctOptionId).text;
}
