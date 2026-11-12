import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/core/enums.dart';

part 'course_exercise_context.freezed.dart';

@freezed
abstract class CourseExerciseContext with _$CourseExerciseContext {
  const factory CourseExerciseContext({
    required TargetLanguage language,
    required String courseId,
    required int levelNumber,
    required Map<String, String> dictionary,
    @Default(1) int generationVersion,
  }) = _CourseExerciseContext;
}
