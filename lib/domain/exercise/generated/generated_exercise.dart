import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/generated/generated_exercise_kind.dart';
import 'package:words625/domain/exercise/model/interactive_exercise.dart';

part 'generated_exercise.freezed.dart';

@freezed
abstract class GeneratedExercise with _$GeneratedExercise {
  const factory GeneratedExercise({
    required InteractiveExercise exercise,
    required String sourceQuestionId,
    required String sourceSentence,
    required GeneratedExerciseKind kind,
    required bool usedFallback,
    String? fallbackReason,
  }) = _GeneratedExercise;
}
