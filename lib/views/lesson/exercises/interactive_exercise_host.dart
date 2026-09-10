import 'package:flutter/material.dart';
import 'package:words625/core/stable_hash.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/choice_exercise_view.dart';
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
import 'package:words625/views/lesson/exercises/fill_blank_choice_exercise_view.dart';
import 'package:words625/views/lesson/exercises/fill_blank_text_exercise_view.dart';
import 'package:words625/views/lesson/exercises/picture_choice_exercise_view.dart';
import 'package:words625/views/lesson/exercises/sentence_order_exercise_view.dart';
import 'package:words625/views/lesson/exercises/token_bank_exercise_view.dart';

class InteractiveExerciseHost extends StatelessWidget {
  const InteractiveExerciseHost({
    required this.exercise,
    required this.onResponseChanged,
    this.evaluation,
    super.key,
  });

  final InteractiveExercise exercise;
  final ValueChanged<ExerciseResponse?> onResponseChanged;

  /// Null while the learner is answering; the verdict once they have checked.
  final ExerciseEvaluation? evaluation;

  @override
  Widget build(BuildContext context) => switch (exercise) {
        final ChoiceExercise item => ChoiceExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
            evaluation: evaluation,
          ),
        final WordBankExercise item => TokenBankExerciseView(
            sourceText: item.sourceText,
            tokens: item.tokens,
            acceptedOrders: item.acceptedOrders,
            shuffleSeed: stableHash32(item.id),
            onChanged: onResponseChanged,
            evaluation: evaluation,
          ),
        final SentenceOrderExercise item => SentenceOrderExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
            evaluation: evaluation,
          ),
        final FillBlankChoiceExercise item => FillBlankChoiceExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
            evaluation: evaluation,
          ),
        final FillBlankTextExercise item => FillBlankTextExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
            evaluation: evaluation,
          ),
        final PictureChoiceExercise item => PictureChoiceExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
            evaluation: evaluation,
          ),
      };
}
