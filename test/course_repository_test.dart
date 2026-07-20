// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/courses/course_repository.dart';

/// Guards the JSON-to-Dart boundary. Content correctness (counts, answers,
/// dictionary coverage) is checked by `tool/validate_courses.py`; this asserts
/// that whatever ships in `assets/courses/` actually parses into the models the
/// UI renders.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CourseRepository', () {
    for (final language in TargetLanguage.values) {
      test('loads every ${language.name} course', () async {
        final courses = await CourseRepository()
            .courses(language, firstName: 'Rishi');

        expect(courses, isNotEmpty, reason: '${language.name} has no courses');
        for (final group in courses) {
          expect(group.length, inInclusiveRange(1, 3),
              reason: 'a tree row of ${group.length} renders nothing');
        }

        final flat = courses.expand((group) => group).toList();
        expect(flat.length, 15);

        for (final course in flat) {
          expect(course.levels, isNotNull);
          expect(course.levels!.length, inInclusiveRange(5, 6),
              reason: '${course.courseName} has ${course.levels!.length} levels');
          expect(course.image, startsWith('assets/images/'));
          expect(course.color, isNotNull);

          for (final level in course.levels!) {
            expect(level.questions!.length, inInclusiveRange(8, 10));
            for (final question in level.questions!) {
              expect(question.options, hasLength(3));
              expect(question.options, contains(question.correctAnswer),
                  reason: '${course.courseName} L${level.level}: '
                      'correctAnswer is not among the options');
            }
          }
        }
      });
    }

    test('splices the learner name in and leaves no placeholder behind',
        () async {
      final courses =
          await CourseRepository().courses(TargetLanguage.tamil, firstName: 'Asha');
      final everything = courses
          .expand((group) => group)
          .expand((course) => course.levels!)
          .expand((level) => level.questions!)
          .expand((q) => [q.sentence, q.correctAnswer, ...?q.options])
          .join(' ');

      expect(everything, isNot(contains('{name}')));
      expect(everything, contains('Asha'));
    });

    test('glosses every word of a real lesson sentence', () async {
      // The tap-a-word hint silently disappears if the dictionary is looked up
      // against a different language than the lesson came from, so assert the
      // two travel together for every language.
      for (final language in TargetLanguage.values) {
        final repository = CourseRepository();
        final courses = await repository.courses(language, firstName: 'Rishi');
        final question = courses.first.first.levels!.first.questions!.first;

        for (final word in question.sentence!.split(' ')) {
          expect(
            repository.activeDictionary?[normalizeWord(word)],
            isNotNull,
            reason: '${language.name}: "$word" in "${question.sentence}" '
                'has no gloss, so it would render without an underline',
          );
        }
      }
    });

    test('caches parsed content across reads', () async {
      final repository = CourseRepository();
      expect(repository.cachedDictionary(TargetLanguage.kannada), isNull);
      await repository.courses(TargetLanguage.kannada, firstName: 'Rishi');
      expect(repository.cachedDictionary(TargetLanguage.kannada), isNotEmpty);
    });

    test('missing assets fail loudly rather than rendering an empty tree',
        () async {
      final repository = CourseRepository(bundle: _EmptyBundle());
      expect(
        () => repository.courses(TargetLanguage.tamil, firstName: 'Rishi'),
        throwsA(isA<FlutterError>()),
      );
    });
  });

  group('normalizeWord', () {
    test('strips punctuation and case so sentence words find their gloss', () {
      expect(normalizeWord('Enna?'), 'enna');
      expect(normalizeWord('"varuven,"'), 'varuven');
      expect(normalizeWord('Naan.'), 'naan');
      expect(normalizeWord('...'), '');
    });
  });
}

class _EmptyBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      throw FlutterError('Unable to load asset: $key');
}
