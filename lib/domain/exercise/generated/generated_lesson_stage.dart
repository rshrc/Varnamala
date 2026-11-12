import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/generated/generated_exercise.dart';
import 'package:words625/domain/exercise/generated/lesson_stage_kind.dart';

part 'generated_lesson_stage.freezed.dart';

@freezed
abstract class GeneratedLessonStage with _$GeneratedLessonStage {
  const factory GeneratedLessonStage({
    required String id,
    required LessonStageKind kind,
    required int unitNumber,
    required List<GeneratedExercise> exercises,
  }) = _GeneratedLessonStage;
}
