import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/model/exercise_response.dart';

part 'ordered_exercise_response.freezed.dart';

@freezed
abstract class OrderedExerciseResponse
    with _$OrderedExerciseResponse
    implements ExerciseResponse {
  const factory OrderedExerciseResponse(List<String> tokenIds) =
      _OrderedExerciseResponse;
}
