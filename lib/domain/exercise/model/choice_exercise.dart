import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/model/exercise_option.dart';
import 'package:words625/domain/exercise/model/exercise_response.dart';
import 'package:words625/domain/exercise/model/interactive_exercise.dart';
import 'package:words625/domain/exercise/response/choice_exercise_response.dart';

part 'choice_exercise.freezed.dart';

@freezed
abstract class ChoiceExercise
    with _$ChoiceExercise
    implements InteractiveExercise {
  const factory ChoiceExercise({
    required String id,
    required String prompt,
    required String explanation,
    required String sentence,
    required List<ExerciseOption> options,
    required String correctOptionId,
    @Default(true) bool sentenceIsTargetLanguage,
    InteractiveExercise? adaptiveRetry,
  }) = _ChoiceExercise;

  const ChoiceExercise._();

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
