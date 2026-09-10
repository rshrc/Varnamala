// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/core/answer_similarity.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/courses/concept_catalogue.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/domain/course/course.dart';

/// Content checks the Ruby validator cannot make, because they depend on the
/// Dart matcher a learner's typing is judged by.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Concept> concepts;
  late Map<TargetLanguage, Course> wordCourses;

  setUpAll(() async {
    concepts = await ConceptCatalogue().load();
    wordCourses = {};
    for (final language in TargetLanguage.values) {
      final groups =
          await CourseRepository().courses(language, firstName: 'Rishi');
      final course = groups
          .expand((group) => group)
          .where((course) => course.levels!.first.isVocabulary)
          .firstOrNull;
      if (course != null) wordCourses[language] = course;
    }
  });

  test('every language has a word course', () {
    expect(
      wordCourses.keys.toSet(),
      TargetLanguage.values.toSet(),
      reason: 'First words is missing for some languages',
    );
  });

  test('no two words in a level fold to the same spelling', () {
    // This is the sharp one. judgeTypedAnswer accepts anything whose
    // romanizationKey matches the answer's, so two words in one level sharing
    // a key would mean typing "milk" is marked correct when the picture is
    // water. The whole level is one exercise pool, so the clash has to be
    // ruled out per level rather than per exercise.
    final clashes = <String>[];

    for (final entry in wordCourses.entries) {
      for (final level in entry.value.levels!) {
        final byKey = <String, List<String>>{};
        for (final word in level.words!) {
          byKey
              .putIfAbsent(romanizationKey(word.word), () => [])
              .add(word.word);
        }
        byKey.forEach((key, words) {
          if (words.length > 1) {
            clashes.add(
              '${entry.key.name} L${level.level}: ${words.join(" / ")} '
              'all fold to "$key"',
            );
          }
        });
      }
    }

    expect(clashes, isEmpty, reason: clashes.join('\n'));
  });

  test('every word course teaches all sixty concepts exactly once', () {
    for (final entry in wordCourses.entries) {
      final taught = <String>[];
      for (final level in entry.value.levels!) {
        taught.addAll(level.words!.map((word) => word.concept));
      }
      expect(taught, hasLength(60), reason: '${entry.key.name} word count');
      expect(
        taught.toSet(),
        concepts.keys.toSet(),
        reason: '${entry.key.name} does not cover the concept list exactly',
      );
    }
  });

  test('every language teaches a different word for a given concept', () {
    // Not a hard rule - Hindi and Urdu genuinely share most of this
    // vocabulary - but a concept whose word is identical in *every* language
    // is a sign the placeholder was never replaced.
    final byConcept = <String, Set<String>>{};
    for (final course in wordCourses.values) {
      for (final level in course.levels!) {
        for (final word in level.words!) {
          byConcept
              .putIfAbsent(word.concept, () => <String>{})
              .add(romanizationKey(word.word));
        }
      }
    }

    final identical = byConcept.entries
        .where((entry) => entry.value.length == 1)
        .map((entry) => '${entry.key} = ${entry.value.single}')
        .toList();

    expect(
      identical,
      isEmpty,
      reason: 'the same word in all 13 languages:\n${identical.join("\n")}',
    );
  });

  test('no word is left as its own English label', () {
    // A word that is just the English concept back again teaches nothing -
    // the same rule glossTeachesNothing enforces for sentence courses.
    final untranslated = <String>[];
    for (final entry in wordCourses.entries) {
      for (final level in entry.value.levels!) {
        for (final word in level.words!) {
          final label = concepts[word.concept]!.label;
          if (romanizationKey(word.word) == romanizationKey(label)) {
            untranslated
                .add('${entry.key.name}: ${word.concept} = ${word.word}');
          }
        }
      }
    }

    expect(untranslated, isEmpty, reason: untranslated.join('\n'));
  });
}
