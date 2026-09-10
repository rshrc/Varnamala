// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/components/list_lesson.dart';
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_choice_tile.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_picture_tile.dart';

/// Teaches one word against one picture.
///
/// Renders all three directions of [PictureChoiceExercise]: picture to word,
/// word to picture, and sound to picture. They share a view because they share
/// a shape, and splitting them would mean three copies of the verdict painting.
class PictureChoiceExerciseView extends StatefulWidget {
  const PictureChoiceExerciseView({
    required this.exercise,
    required this.onChanged,
    this.evaluation,
    super.key,
  });

  final PictureChoiceExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;
  final ExerciseEvaluation? evaluation;

  @override
  State<PictureChoiceExerciseView> createState() =>
      PictureChoiceExerciseViewState();
}

class PictureChoiceExerciseViewState extends State<PictureChoiceExerciseView> {
  String? selectedId;

  void select(String optionId) {
    setState(() => selectedId = optionId);
    widget.onChanged(ChoiceExerciseResponse(optionId));
  }

  AnswerMark markFor(String optionId) =>
      widget.evaluation?.markForOption(
        optionId,
        widget.exercise.correctOptionId,
      ) ??
      AnswerMark.none;

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Prompt(exercise: exercise),
        const SizedBox(height: 24),
        if (exercise.optionsArePictures)
          _PictureOptions(
            options: exercise.options,
            selectedId: selectedId,
            markFor: markFor,
            onSelect: select,
          )
        else
          for (final option in exercise.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExerciseChoiceTile(
                text: option.text,
                selected: selectedId == option.id,
                mark: markFor(option.id),
                onTap: () => select(option.id),
              ),
            ),
      ],
    );
  }
}

/// The picture, the word, or the speaker on its own.
class _Prompt extends StatelessWidget {
  const _Prompt({required this.exercise});

  final PictureChoiceExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (exercise.promptArt case final art?) ...[
          SizedBox(
            height: 132,
            child: Semantics(
              image: true,
              label: exercise.promptLabel,
              child: SvgPicture.asset(
                art,
                excludeFromSemantics: true,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (exercise.promptWord case final word?)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  word,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              SpeakButton(sentence: word),
            ],
          )
        else if (exercise.promptLabel case final label?)
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
      ],
    );
  }
}

/// The options as a grid of drawings.
///
/// A max-extent delegate rather than a fixed column count, so the grid gains a
/// column on a tablet instead of inflating four tiles to the size of a hand.
class _PictureOptions extends StatelessWidget {
  const _PictureOptions({
    required this.options,
    required this.selectedId,
    required this.markFor,
    required this.onSelect,
  });

  final List<ExerciseOption> options;
  final String? selectedId;
  final AnswerMark Function(String optionId) markFor;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        return ExercisePictureTile(
          art: option.art!,
          label: option.text,
          selected: selectedId == option.id,
          mark: markFor(option.id),
          onTap: () => onSelect(option.id),
        );
      },
    );
  }
}
