import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_option.freezed.dart';

@freezed
abstract class ExerciseOption with _$ExerciseOption {
  const factory ExerciseOption({
    required String id,
    required String text,
    String? art,
  }) = _ExerciseOption;
}
