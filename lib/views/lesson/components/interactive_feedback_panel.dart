import 'package:flutter/material.dart';
import 'package:words625/application/interactive_lesson_engine.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/core/stable_hash.dart';
import 'package:words625/gen/assets.gen.dart';
import 'package:words625/views/theme.dart';

/// Praise is rotated so a lesson does not say the same word nine times.
///
/// The pick is derived from the exercise id rather than a `Random`, so the
/// wording is stable across the rebuilds a feedback frame triggers instead of
/// flickering between words while the panel animates in.
const List<String> _praise = [
  'Nice!',
  'Excellent!',
  'You got it!',
  'Perfect!',
  'Well done!',
  'That is right!',
  'Exactly!',
  'Beautiful!',
  'Very good!',
  'Brilliant!',
  'Yes, that is it!',
  'Lovely!',
];

const List<String> _consolation = [
  'Not quite',
  'Almost there',
  'Close one',
  'Nearly',
  'Not this time',
];

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
    final words = correct ? _praise : _consolation;
    final headline =
        words[stableHash32(engine.currentExercise.id) % words.length];

    final tint = color.withValues(alpha: 0.18);

    // A full-bleed band is right on a phone, where edge to edge is barely
    // wider than the text and the fill genuinely colours the bottom of the
    // screen. Stretched across a desktop it becomes a metre of green with one
    // sentence adrift in the middle of it, so above a phone the verdict
    // becomes a card the width of the button underneath it.
    if (context.breakpoint != Breakpoint.compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: ContentBounds(
          gutter: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
              border: Border.all(color: color, width: 2),
            ),
            child: _Verdict(
              correct: correct,
              color: color,
              headline: headline,
              engine: engine,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        // A verdict that only whispers gets read as decoration. The fill is
        // heavy enough to change the colour of the whole bottom of the screen,
        // and the rule on top separates it from the exercise above.
        color: tint,
        border: Border(top: BorderSide(color: color, width: 2)),
      ),
      child: _Verdict(
        correct: correct,
        color: color,
        headline: headline,
        engine: engine,
      ),
    );
  }
}

/// Mala, the verdict, the answer, and the note - the part that is the same
/// whether it is drawn as a band or as a card.
class _Verdict extends StatelessWidget {
  const _Verdict({
    required this.correct,
    required this.color,
    required this.headline,
    required this.engine,
  });

  final bool correct;
  final Color color;
  final String headline;
  final InteractiveLessonEngine engine;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mala is all over the course tree and then vanishes at the one
        // moment a learner most wants somebody to react to them.
        Image.asset(
          correct
              ? Assets.images.mala.malaExcited.path
              : Assets.images.mala.malaDoubtful.path,
          width: 54,
          height: 54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      headline,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              if (!correct) ...[
                const SizedBox(height: 7),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Correct answer: '),
                      TextSpan(
                        text: engine.currentExercise.correctAnswerLabel,
                        // Green, not the panel's red: this is the right
                        // answer, and it is the same string that just went
                        // green in the list above. Painting it red said
                        // "wrong" about the one thing on screen that is
                        // not.
                        style: TextStyle(color: context.appSuccess),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
              if (engine.currentExercise.explanation.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  engine.currentExercise.explanation,
                  style: TextStyle(color: context.appTextSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
