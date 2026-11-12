import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_token.freezed.dart';

@freezed
abstract class ExerciseToken with _$ExerciseToken {
  const factory ExerciseToken({required String id, required String text}) =
      _ExerciseToken;
}
