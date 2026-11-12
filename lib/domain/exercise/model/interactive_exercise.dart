import 'package:words625/domain/exercise/model/exercise_response.dart';

abstract interface class InteractiveExercise {
  String get id;
  String get prompt;
  String get explanation;
  InteractiveExercise? get adaptiveRetry;

  bool isCorrect(ExerciseResponse response);

  String? spellingCorrection(ExerciseResponse response);

  String get correctAnswerLabel;
}
