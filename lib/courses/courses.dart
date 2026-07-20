// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/domain/course/course.dart';

/// Shared across the app so a language's JSON is parsed once per session.
final CourseRepository courseRepository = CourseRepository();

Future<List<List<Course>>> parseCourses({
  required String firstName,
  TargetLanguage targetLanguage = TargetLanguage.kannada,
}) async {
  logger.i('Loading course content for ${targetLanguage.name}');
  return courseRepository.courses(targetLanguage, firstName: firstName);
}
