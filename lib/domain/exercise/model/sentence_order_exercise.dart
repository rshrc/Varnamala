import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/exercise/model/exercise_response.dart';
import 'package:words625/domain/exercise/model/exercise_token.dart';
import 'package:words625/domain/exercise/model/interactive_exercise.dart';
import 'package:words625/domain/exercise/response/ordered_exercise_response.dart';
import 'package:words625/domain/exercise/support/exercise_answer_helpers.dart';

part 'sentence_order_exercise.freezed.dart';

@freezed
abstract class SentenceOrderExercise
    with _$SentenceOrderExercise
    implements InteractiveExercise {
  const factory SentenceOrderExercise({
    required String id,
    required String prompt,
    required String explanation,
    required String translation,
    required List<ExerciseToken> tokens,
    required List<List<String>> acceptedOrders,
    InteractiveExercise? adaptiveRetry,
  }) = _SentenceOrderExercise;

  const SentenceOrderExercise._();

  @override
  bool isCorrect(ExerciseResponse response) =>
      response is OrderedExerciseResponse &&
      matchesAnyTokenOrder(response.tokenIds, acceptedOrders, tokens);

  @override
  String? spellingCorrection(ExerciseResponse response) => null;

  @override
  String get correctAnswerLabel =>
      tokensForOrder(tokens, acceptedOrders.first).join(' ');
}
