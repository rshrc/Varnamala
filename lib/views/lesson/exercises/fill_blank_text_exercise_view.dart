import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_source_card.dart';
import 'package:words625/views/lesson/exercises/widgets/tappable_gloss_text.dart';
import 'package:words625/views/theme.dart';

class FillBlankTextExerciseView extends StatefulWidget {
  const FillBlankTextExerciseView({
    required this.exercise,
    required this.onChanged,
    this.evaluation,
    super.key,
  });

  final FillBlankTextExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;
  final ExerciseEvaluation? evaluation;

  @override
  State<FillBlankTextExerciseView> createState() =>
      FillBlankTextExerciseViewState();
}

class FillBlankTextExerciseViewState extends State<FillBlankTextExerciseView> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(handleFocus);
  }

  void handleFocus() {
    if (mounted) setState(() => hasFocus = focusNode.hasFocus);
  }

  @override
  void dispose() {
    focusNode
      ..removeListener(handleFocus)
      ..dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // What the learner typed turns green or red in place, so their own words
    // carry the verdict rather than a label somewhere else on the screen.
    final mark = widget.evaluation?.verdict ?? AnswerMark.none;
    final marked = mark.color(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseSourceCard(label: 'CLUE', text: widget.exercise.clue),
        if (widget.exercise.wordMeaning case final meaning?) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.appInfo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
              ),
              child: Text(
                'WORD MEANING · $meaning',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.appInfo,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.35,
                    ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TappableGlossText(
              text: widget.exercise.beforeBlank,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              width: math.min(180, MediaQuery.sizeOf(context).width * 0.42),
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 5),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: marked ??
                        (hasFocus ? context.appInfo : context.appBorder),
                    width: marked != null || hasFocus ? 2.25 : 1.75,
                  ),
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: marked ?? context.appInfo,
                      fontWeight: FontWeight.w800,
                    ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'type here',
                  hintStyle: TextStyle(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onChanged: (value) => widget.onChanged(
                  value.trim().isEmpty ? null : TextExerciseResponse(value),
                ),
              ),
            ),
            TappableGlossText(
              text: widget.exercise.afterBlank,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
