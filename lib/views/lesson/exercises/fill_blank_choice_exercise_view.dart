import 'package:flutter/material.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_choice_tile.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_source_card.dart';
import 'package:words625/views/lesson/exercises/widgets/tappable_gloss_text.dart';
import 'package:words625/views/theme.dart';

class FillBlankChoiceExerciseView extends StatefulWidget {
  const FillBlankChoiceExerciseView({
    required this.exercise,
    required this.onChanged,
    this.evaluation,
    super.key,
  });

  final FillBlankChoiceExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;
  final ExerciseEvaluation? evaluation;

  @override
  State<FillBlankChoiceExerciseView> createState() =>
      FillBlankChoiceExerciseViewState();
}

class FillBlankChoiceExerciseViewState
    extends State<FillBlankChoiceExerciseView> {
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    final answer = selectedId == null
        ? null
        : widget.exercise.options
            .firstWhere((option) => option.id == selectedId)
            .text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseSourceCard(label: 'CLUE', text: widget.exercise.clue),
        const SizedBox(height: 24),
        FillBlankSentence(
          before: widget.exercise.beforeBlank,
          after: widget.exercise.afterBlank,
          answer: answer,
          mark: widget.evaluation?.verdict ?? AnswerMark.none,
        ),
        const SizedBox(height: 24),
        for (final option in widget.exercise.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExerciseChoiceTile(
              text: option.text,
              selected: selectedId == option.id,
              mark: widget.evaluation?.markForOption(
                    option.id,
                    widget.exercise.correctOptionId,
                  ) ??
                  AnswerMark.none,
              onTap: () {
                setState(() => selectedId = option.id);
                widget.onChanged(ChoiceExerciseResponse(option.id));
              },
            ),
          ),
      ],
    );
  }
}

class FillBlankSentence extends StatelessWidget {
  const FillBlankSentence({
    required this.before,
    required this.after,
    required this.answer,
    this.mark = AnswerMark.none,
    super.key,
  });

  final String before;
  final String after;
  final String? answer;
  final AnswerMark mark;

  @override
  Widget build(BuildContext context) {
    // Unfilled blank, filled blank, and checked blank are three states, so the
    // colour is resolved once rather than re-derived at every use.
    final filled =
        mark.color(context) ?? (answer == null ? null : context.appInfo);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TappableGlossText(
          text: before,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 92, minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: filled == null
                ? context.appElevatedSurface
                : filled.withValues(alpha: mark.isMarked ? 0.20 : 0.12),
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
            border: Border.all(
              color: filled ?? context.appBorder,
              width: 2,
            ),
          ),
          child: Text(
            answer ?? '________',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: filled ?? context.appTextSecondary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        TappableGlossText(
          text: after,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
