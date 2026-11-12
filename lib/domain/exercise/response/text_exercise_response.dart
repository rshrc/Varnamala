import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/model/exercise_response.dart';

part 'text_exercise_response.freezed.dart';

@freezed
abstract class TextExerciseResponse
    with _$TextExerciseResponse
    implements ExerciseResponse {
  const factory TextExerciseResponse(String text) = _TextExerciseResponse;
}
