import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/model/exercise_option.dart';
import 'package:words625/domain/exercise/model/exercise_response.dart';
import 'package:words625/domain/exercise/model/interactive_exercise.dart';
import 'package:words625/domain/exercise/response/choice_exercise_response.dart';

part 'picture_choice_exercise.freezed.dart';

@freezed
abstract class PictureChoiceExercise
    with _$PictureChoiceExercise
    implements InteractiveExercise {
  const factory PictureChoiceExercise({
    required String id,
    required String prompt,
    required String explanation,
    required List<ExerciseOption> options,
    required String correctOptionId,
    String? promptArt,
    String? promptWord,
    String? promptLanguage,
    String? promptLabel,
    @Default(false) bool optionsArePictures,
    InteractiveExercise? adaptiveRetry,
  }) = _PictureChoiceExercise;

  const PictureChoiceExercise._();

  bool get isListening => promptArt == null && promptWord == null;

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
