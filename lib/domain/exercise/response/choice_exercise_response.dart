import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/model/exercise_response.dart';

part 'choice_exercise_response.freezed.dart';

@freezed
abstract class ChoiceExerciseResponse
    with _$ChoiceExerciseResponse
    implements ExerciseResponse {
  const factory ChoiceExerciseResponse(String optionId) =
      _ChoiceExerciseResponse;
}
