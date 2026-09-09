// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/application/interactive_lesson_engine.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/components/interactive_feedback_panel.dart';
import 'package:words625/views/lesson/exercises/choice_exercise_view.dart';
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
import 'package:words625/views/theme.dart';

const ChoiceExercise _exercise = ChoiceExercise(
  id: 'greeting-1',
  prompt: 'Which reply fits?',
  explanation: '',
  sentence: 'namaskara',
  // Kept off so the card renders plain text rather than reaching for the
  // dictionary through the service locator.
  sentenceIsTargetLanguage: false,
  options: [
    ExerciseOption(id: 'a', text: 'namaskara'),
    ExerciseOption(id: 'b', text: 'dhanyavada'),
    ExerciseOption(id: 'c', text: 'shubodaya'),
  ],
  correctOptionId: 'a',
);

/// The border colour the tile holding [text] settled on.
Color borderColorOf(WidgetTester tester, String text) {
  final container = tester.widget<AnimatedContainer>(
    find
        .ancestor(
          of: find.text(text),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  );
  return ((container.decoration! as BoxDecoration).border! as Border).top.color;
}

Future<BuildContext> pumpChoices(
  WidgetTester tester, {
  ExerciseEvaluation? evaluation,
}) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      theme: VarnamalaTheme.lightTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            captured = context;
            return SingleChildScrollView(
              child: ChoiceExerciseView(
                exercise: _exercise,
                onChanged: (_) {},
                evaluation: evaluation,
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return captured;
}

void main() {
  group('ExerciseEvaluation', () {
    test('a right answer marks only the option the learner picked', () {
      const evaluation = ExerciseEvaluation(
        correct: true,
        response: ChoiceExerciseResponse('a'),
      );

      expect(evaluation.markForOption('a', 'a'), AnswerMark.correct);
      expect(evaluation.markForOption('b', 'a'), AnswerMark.none);
    });

    test('a wrong answer marks the miss and still reveals the answer', () {
      const evaluation = ExerciseEvaluation(
        correct: false,
        response: ChoiceExerciseResponse('b'),
      );

      // Being shown the right answer is the point of getting one wrong.
      expect(evaluation.markForOption('a', 'a'), AnswerMark.revealed);
      expect(evaluation.markForOption('b', 'a'), AnswerMark.wrong);
      // An option nobody touched stays out of it.
      expect(evaluation.markForOption('c', 'a'), AnswerMark.none);
    });

    test('an answer that is not a choice marks nothing as chosen', () {
      final evaluation = ExerciseEvaluation(
        correct: false,
        response: OrderedExerciseResponse(const ['x', 'y']),
      );

      expect(evaluation.chosenOptionId, isNull);
    });
  });

  group('choice feedback', () {
    testWidgets('tiles stay neutral until the answer is checked',
        (tester) async {
      final context = await pumpChoices(tester);

      for (final text in ['namaskara', 'dhanyavada', 'shubodaya']) {
        expect(
          borderColorOf(tester, text),
          isNot(anyOf(context.appSuccess, context.appDanger)),
          reason: '$text should carry no verdict while answering',
        );
      }
    });

    testWidgets('a wrong pick turns red while the answer turns green',
        (tester) async {
      final context = await pumpChoices(
        tester,
        evaluation: const ExerciseEvaluation(
          correct: false,
          response: ChoiceExerciseResponse('b'),
        ),
      );

      expect(borderColorOf(tester, 'dhanyavada'), context.appDanger);
      expect(borderColorOf(tester, 'namaskara'), context.appSuccess);
      expect(
        borderColorOf(tester, 'shubodaya'),
        isNot(anyOf(context.appSuccess, context.appDanger)),
      );
    });

    testWidgets('a right pick turns green', (tester) async {
      final context = await pumpChoices(
        tester,
        evaluation: const ExerciseEvaluation(
          correct: true,
          response: ChoiceExerciseResponse('a'),
        ),
      );

      expect(borderColorOf(tester, 'namaskara'), context.appSuccess);
    });
  });

  group('the verdict band', () {
    Future<double> panelWidth(WidgetTester tester, Size window) async {
      tester.view.physicalSize = window;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final engine = InteractiveLessonEngine(exercises: const [_exercise])
        ..setResponse(const ChoiceExerciseResponse('a'));
      engine.submit();

      await tester.pumpWidget(
        MaterialApp(
          theme: VarnamalaTheme.lightTheme,
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [InteractiveFeedbackPanel(engine: engine)],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      return tester
          .getSize(
            find
                .descendant(
                  of: find.byType(InteractiveFeedbackPanel),
                  matching: find.byType(Container),
                )
                .first,
          )
          .width;
    }

    testWidgets(
        'runs edge to edge on a phone, where that is barely wider '
        'than the text', (tester) async {
      expect(await panelWidth(tester, const Size(390, 800)), 390);
    });

    testWidgets('stops being a metre of colour on a desktop', (tester) async {
      // Same width as the CONTINUE button under it, not the whole window.
      expect(
          await panelWidth(tester, const Size(1600, 900)), ContentWidth.column);
    });
  });
}
