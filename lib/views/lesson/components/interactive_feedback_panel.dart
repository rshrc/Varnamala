import 'package:flutter/material.dart';
import 'package:words625/application/interactive_lesson_engine.dart';
import 'package:words625/views/theme.dart';

class InteractiveFeedbackPanel extends StatelessWidget {
  const InteractiveFeedbackPanel({
    required this.engine,
    super.key,
  });

  final InteractiveLessonEngine engine;

  @override
  Widget build(BuildContext context) {
    final correct = engine.lastAttempt!.correct;
    final color = correct ? context.appSuccess : context.appDanger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      color: color.withValues(alpha: 0.11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? 'Correct!' : 'Not quite',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 7),
            Text(
              'Correct answer: ${engine.currentExercise.correctAnswerLabel}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (engine.currentExercise.explanation.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(engine.currentExercise.explanation),
          ],
        ],
      ),
    );
  }
}
