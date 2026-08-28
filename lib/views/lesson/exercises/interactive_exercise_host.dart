import 'package:flutter/material.dart';
import 'package:words625/core/stable_hash.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/choice_exercise_view.dart';
import 'package:words625/views/lesson/exercises/fill_blank_choice_exercise_view.dart';
import 'package:words625/views/lesson/exercises/fill_blank_text_exercise_view.dart';
import 'package:words625/views/lesson/exercises/sentence_order_exercise_view.dart';
import 'package:words625/views/lesson/exercises/token_bank_exercise_view.dart';

class InteractiveExerciseHost extends StatelessWidget {
  const InteractiveExerciseHost({
    required this.exercise,
    required this.onResponseChanged,
    super.key,
  });

  final InteractiveExercise exercise;
  final ValueChanged<ExerciseResponse?> onResponseChanged;

  @override
  Widget build(BuildContext context) => switch (exercise) {
        final ChoiceExercise item => ChoiceExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
          ),
        final WordBankExercise item => TokenBankExerciseView(
            sourceLabel: 'TRANSLATE',
            sourceText: item.sourceText,
            tokens: item.tokens,
            acceptedOrders: item.acceptedOrders,
            shuffleSeed: stableHash32(item.id),
            joinWithoutSpaces: false,
            onChanged: onResponseChanged,
          ),
        final SentenceOrderExercise item => SentenceOrderExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
          ),
        final FillBlankChoiceExercise item => FillBlankChoiceExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
          ),
        final FillBlankTextExercise item => FillBlankTextExerciseView(
            exercise: item,
            onChanged: onResponseChanged,
          ),
        final GuessWordExercise item => TokenBankExerciseView(
            sourceLabel: 'CLUE',
            sourceText: item.clue,
            tokens: item.tokens,
            acceptedOrders: item.acceptedOrders,
            shuffleSeed: stableHash32(item.id),
            joinWithoutSpaces: true,
            onChanged: onResponseChanged,
          ),
      };
}
