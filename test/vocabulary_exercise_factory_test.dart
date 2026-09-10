// Flutter imports:
import 'package:flutter/services.dart' show rootBundle;

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/application/lesson/vocabulary_exercise_factory.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/courses/concept_catalogue.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';

const factory = VocabularyExerciseFactory();

CourseExerciseContext contextFor(int levelNumber) => CourseExerciseContext(
      language: TargetLanguage.kannada,
      courseId: 'words',
      levelNumber: levelNumber,
      dictionary: const {},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Concept> concepts;

  setUpAll(() async {
    concepts = await ConceptCatalogue().load();
  });

  test('every concept has a picture bundled with the app', () async {
    for (final concept in concepts.values) {
      // rootBundle throws rather than returning null for a missing asset, so
      // reaching the next line is the assertion.
      final data = await rootBundle.load(concept.art);
      expect(data.lengthInBytes, greaterThan(0),
          reason: '${concept.id} has an empty picture');
    }
  });

  test('every bundled word course plays', () async {
    var wordCourses = 0;

    for (final language in TargetLanguage.values) {
      final groups =
          await CourseRepository().courses(language, firstName: 'Rishi');
      final courses = groups
          .expand((group) => group)
          .where((course) => course.levels!.first.isVocabulary);

      for (final course in courses) {
        wordCourses += 1;
        for (final level in course.levels!) {
          final words = level.words!;
          expect(words, hasLength(12));

          for (final stage in LessonStageKind.values) {
            final built = factory.buildStage(
              context: contextFor(level.level!),
              words: words,
              concepts: concepts,
              stage: stage,
            );

            expect(built.exercises, isNotEmpty);
            expect(
              built.exercises.map((item) => item.exercise.id).toSet(),
              hasLength(built.exercises.length),
              reason: 'exercise ids must be unique within a stage',
            );

            for (final generated in built.exercises) {
              final exercise = generated.exercise;

              // A learner cannot be right if the answer is not on screen.
              switch (exercise) {
                case final PictureChoiceExercise choice:
                  expect(choice.options, hasLength(4));
                  expect(
                    choice.options.map((option) => option.id),
                    contains(choice.correctOptionId),
                  );
                  expect(
                    choice.options.map((option) => option.text).toSet(),
                    hasLength(4),
                    reason: '${exercise.id} shows the same option twice',
                  );
                  expect(
                    choice.isCorrect(
                      ChoiceExerciseResponse(choice.correctOptionId),
                    ),
                    isTrue,
                  );
                  if (choice.optionsArePictures) {
                    for (final option in choice.options) {
                      expect(option.art, isNotNull);
                    }
                  }
                case final FillBlankTextExercise typed:
                  expect(typed.clueArt, isNotNull);
                  expect(
                    typed.isCorrect(
                      TextExerciseResponse(typed.acceptedAnswers.first),
                    ),
                    isTrue,
                  );
                  expect(
                    typed.spellingCorrection(
                      TextExerciseResponse(typed.acceptedAnswers.first),
                    ),
                    isNull,
                    reason: '${exercise.id} corrected its own answer',
                  );
                default:
                  fail('${exercise.id} is not a word-course exercise');
              }

              // A miss must have somewhere gentler to land.
              expect(exercise.adaptiveRetry, isNotNull);
            }
          }
        }
      }
    }

    expect(wordCourses, greaterThan(0),
        reason: 'no language has a word course yet');
  });

  test('a wrong pick is always another word from the same level', () async {
    final groups = await CourseRepository()
        .courses(TargetLanguage.kannada, firstName: 'Rishi');
    final course = groups
        .expand((group) => group)
        .firstWhere((course) => course.levels!.first.isVocabulary);
    final level = course.levels!.first;
    final levelWords = level.words!.map((word) => word.word).toSet();
    final levelLabels = level.words!
        .map((word) => word.gloss ?? concepts[word.concept]!.label)
        .toSet();

    for (final stage in LessonStageKind.values) {
      final built = factory.buildStage(
        context: contextFor(1),
        words: level.words!,
        concepts: concepts,
        stage: stage,
      );
      for (final generated in built.exercises) {
        if (generated.exercise case final PictureChoiceExercise choice) {
          for (final option in choice.options) {
            // Distractors drawn from outside the level would be words the
            // learner has never met, which teaches nothing when they miss.
            expect(
              choice.optionsArePictures
                  ? levelLabels.contains(option.text)
                  : levelWords.contains(option.text),
              isTrue,
              reason: '${option.text} is not taught in this level',
            );
          }
        }
      }
    }
  });

  test('the same word always builds the same exercise', () async {
    final groups = await CourseRepository()
        .courses(TargetLanguage.kannada, firstName: 'Rishi');
    final course = groups
        .expand((group) => group)
        .firstWhere((course) => course.levels!.first.isVocabulary);
    final words = course.levels!.first.words!;

    List<String> optionOrder() => factory
        .buildStage(
          context: contextFor(1),
          words: words,
          concepts: concepts,
          stage: LessonStageKind.discover,
        )
        .exercises
        .expand(
          (generated) => switch (generated.exercise) {
            final PictureChoiceExercise choice =>
              choice.options.map((option) => option.text),
            _ => const <String>[],
          },
        )
        .toList();

    // Seeded from the exercise id, so a rebuild mid-answer must not reshuffle
    // the tiles under the learner's thumb.
    expect(optionOrder(), optionOrder());
  });
}
