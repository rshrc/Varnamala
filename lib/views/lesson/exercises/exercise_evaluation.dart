import 'package:flutter/material.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/theme.dart';

/// How one answer slot should be painted once an answer has been checked.
enum AnswerMark {
  /// Still answering, or this slot had nothing to do with the verdict.
  none,

  /// The learner picked this, and it was right.
  correct,

  /// The learner picked this, and it was wrong.
  wrong,

  /// The learner missed this, and it is the answer they should have given.
  revealed,
}

/// The verdict on the answer the learner just submitted.
///
/// Exercise views receive `null` while answering and an evaluation once the
/// answer is checked. Without it a view has no way to know it was wrong, so the
/// only feedback the lesson could offer was fading the whole exercise out -
/// which reads as "disabled", not as "you got that one wrong". Duolingo's
/// verdict lands on the thing you actually tapped, and so should ours.
class ExerciseEvaluation {
  const ExerciseEvaluation({
    required this.correct,
    required this.response,
    this.spellingCorrection,
  });

  final bool correct;
  final ExerciseResponse response;

  /// The authored spelling, when a typed answer was accepted despite a slip.
  ///
  /// The verdict stays [AnswerMark.correct] - the learner knew the word. This
  /// only lets a view show them how it is written.
  final String? spellingCorrection;

  /// The option the learner chose, for exercises that are a list of choices.
  String? get chosenOptionId => switch (response) {
        final ChoiceExerciseResponse item => item.optionId,
        _ => null,
      };

  /// Marks one option of a multiple choice.
  ///
  /// The right answer lights up whether or not the learner found it: being
  /// shown the answer is the whole point of getting one wrong.
  AnswerMark markForOption(String optionId, String correctOptionId) {
    if (optionId == correctOptionId) {
      return correct ? AnswerMark.correct : AnswerMark.revealed;
    }
    return optionId == chosenOptionId ? AnswerMark.wrong : AnswerMark.none;
  }

  /// The mark for exercises with a single answer area rather than options.
  AnswerMark get verdict => correct ? AnswerMark.correct : AnswerMark.wrong;
}

extension AnswerMarkPainting on AnswerMark {
  bool get isMarked => this != AnswerMark.none;

  /// Null while unmarked, so callers can fall back to their resting colour.
  Color? color(BuildContext context) => switch (this) {
        AnswerMark.none => null,
        AnswerMark.correct || AnswerMark.revealed => context.appSuccess,
        AnswerMark.wrong => context.appDanger,
      };

  IconData? get icon => switch (this) {
        AnswerMark.none => null,
        AnswerMark.correct => Icons.check_circle_rounded,
        // Hollow rather than solid, and never an arrow: an arrow on a green
        // tile reads as "go here", and a solid tick would claim the learner
        // got this one.
        AnswerMark.revealed => Icons.check_circle_outline_rounded,
        AnswerMark.wrong => Icons.cancel_rounded,
      };

  /// Screen-reader wording, since colour alone is not feedback for everyone.
  String? get semanticLabel => switch (this) {
        AnswerMark.none => null,
        AnswerMark.correct => 'Correct',
        AnswerMark.revealed => 'The correct answer',
        AnswerMark.wrong => 'Wrong',
      };
}
