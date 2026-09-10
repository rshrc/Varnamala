// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:words625/courses/concept_catalogue.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
import 'package:words625/views/lesson/exercises/picture_choice_exercise_view.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_picture_tile.dart';
import 'package:words625/views/theme.dart';

/// Word courses are the one place the app teaches through a drawing rather
/// than through text, so "the widget is on screen" is not enough - the picture
/// has to have actually decoded and painted, in both themes and on a narrow
/// phone.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Concept> concepts;

  setUpAll(() async {
    concepts = await ConceptCatalogue().load();
  });

  Widget host(Widget child, {required Brightness brightness}) => MaterialApp(
        theme: brightness == Brightness.light
            ? VarnamalaTheme.lightTheme
            : VarnamalaTheme.darkTheme,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  PictureChoiceExercise pictureOptions() => PictureChoiceExercise(
        id: 'art-check',
        prompt: 'Which picture is this?',
        explanation: 'neeru - water',
        promptWord: 'neeru',
        optionsArePictures: true,
        correctOptionId: 'o0',
        options: [
          for (final id in ['water', 'milk', 'apple', 'house'])
            ExerciseOption(
              id: 'o${['water', 'milk', 'apple', 'house'].indexOf(id)}',
              text: concepts[id]!.label,
              art: concepts[id]!.art,
            ),
        ],
      );

  for (final brightness in Brightness.values) {
    testWidgets('picture options decode and paint in ${brightness.name} mode',
        (tester) async {
      await tester.pumpWidget(
        host(
          PictureChoiceExerciseView(
            exercise: pictureOptions(),
            onChanged: (_) {},
          ),
          brightness: brightness,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExercisePictureTile), findsNWidgets(4));

      final pictures = tester.widgetList<SvgPicture>(find.byType(SvgPicture));
      expect(pictures, hasLength(4));

      // A RenderBox with no size means the drawing never arrived, which is
      // exactly what an unregistered asset directory looks like.
      for (final element in find.byType(SvgPicture).evaluate()) {
        final box = element.renderObject! as RenderBox;
        expect(box.hasSize, isTrue);
        expect(box.size.width, greaterThan(0));
        expect(box.size.height, greaterThan(0));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the picture grid does not overflow a 320px phone',
      (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(
        PictureChoiceExerciseView(
          exercise: pictureOptions(),
          onChanged: (_) {},
        ),
        brightness: Brightness.light,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the word prompt and both speaker buttons fit a 320px phone',
      (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(
        PictureChoiceExerciseView(
          exercise: pictureOptions(),
          onChanged: (_) {},
        ),
        brightness: Brightness.light,
      ),
    );
    await tester.pumpAndSettle();

    // Listen and Listen slowly, beside a word, on the narrowest phone.
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.slow_motion_video_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a missed picture shows both the wrong pick and the right one',
      (tester) async {
    final exercise = pictureOptions();
    await tester.pumpWidget(
      host(
        PictureChoiceExerciseView(
          exercise: exercise,
          onChanged: (_) {},
          // The learner picked the second tile; the answer is the first.
          evaluation: const ExerciseEvaluation(
            correct: false,
            response: ChoiceExerciseResponse('o1'),
          ),
        ),
        brightness: Brightness.light,
      ),
    );
    await tester.pumpAndSettle();

    final marks = tester
        .widgetList<ExercisePictureTile>(find.byType(ExercisePictureTile))
        .map((tile) => tile.mark)
        .toList();

    expect(marks[0], AnswerMark.revealed, reason: 'the answer must light up');
    expect(marks[1], AnswerMark.wrong, reason: 'the tile they tapped');
    expect(marks[2], AnswerMark.none);
    expect(marks[3], AnswerMark.none);
    expect(tester.takeException(), isNull);
  });
}
