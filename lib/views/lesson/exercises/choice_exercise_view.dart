import 'package:flutter/material.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_choice_tile.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_source_card.dart';

class ChoiceExerciseView extends StatefulWidget {
  const ChoiceExerciseView({
    required this.exercise,
    required this.onChanged,
    super.key,
  });

  final ChoiceExercise exercise;
  final ValueChanged<ExerciseResponse?> onChanged;

  @override
  State<ChoiceExerciseView> createState() => ChoiceExerciseViewState();
}

class ChoiceExerciseViewState extends State<ChoiceExerciseView> {
  String? selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseSourceCard(label: 'QUESTION', text: widget.exercise.sentence),
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
