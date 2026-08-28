import 'package:flutter/material.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_choice_tile.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_source_card.dart';
import 'package:words625/views/theme.dart';

class FillBlankChoiceExerciseView extends StatefulWidget {
  const FillBlankChoiceExerciseView({
    required this.exercise,
    required this.onChanged,
    super.key,
  });

  final FillBlankChoiceExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;

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
        ),
        const SizedBox(height: 24),
        for (final option in widget.exercise.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExerciseChoiceTile(
              text: option.text,
              selected: selectedId == option.id,
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
    super.key,
  });

  final String before;
  final String after;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          before,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 92, minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: answer == null
                ? context.appElevatedSurface
                : context.appInfo.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
            border: Border.all(
              color: answer == null ? context.appBorder : context.appInfo,
              width: 2,
            ),
          ),
          child: Text(
            answer ?? '________',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: answer == null
                      ? context.appTextSecondary
                      : context.appInfo,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          after,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
