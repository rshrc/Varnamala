import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/course/level.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

@freezed
abstract class Course with _$Course {
  const factory Course({
    required String courseName,
    String? courseId,
    String? language,
    List<Level>? levels,
    String? image,
    int? color,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}
