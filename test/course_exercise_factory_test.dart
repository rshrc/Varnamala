// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/text_normalization.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const factory = CourseExerciseFactory();
  const context = CourseExerciseContext(
    language: TargetLanguage.hindi,
    courseId: 'basics',
    levelNumber: 1,
    dictionary: {
      'main': 'I',
      'ghar': 'house',
      'jaata': 'go',
      'hoon': 'am',
    },
  );

  const translationQuestion = Question(
    type: 'translate',
    prompt: 'Translate the sentence',
    sentence: 'Main ghar jaata hoon.',
    sentenceIsTargetLanguage: true,
    options: ['I go home.', 'I am at home.', 'I left home.'],
    correctAnswer: 'I go home.',
  );

  const conversationQuestion = Question(
    type: 'multiple_choice',
    prompt: 'Choose an appropriate response',
    sentence: 'Aap kahan jaate hain?',
    sentenceIsTargetLanguage: true,
    options: [
      'Main ghar jaata hoon.',
      'Main school jaata hoon.',
      'Main bazaar jaata hoon.',
    ],
    correctAnswer: 'Main ghar jaata hoon.',
    translatedSentence: 'I go home.',
  );

  group('CourseExerciseFactory', () {
    test('constructs the target language for a translation question', () {
      final generated = factory.generate(
        context: context,
        question: translationQuestion,
        preferredKind: GeneratedExerciseKind.sentenceOrder,
      );

      expect(generated.kind, GeneratedExerciseKind.sentenceOrder);
      final exercise = generated.exercise as SentenceOrderExercise;
      expect(exercise.correctAnswerLabel, 'Main ghar jaata hoon');
      expect(exercise.translation, 'I go home.');
      expect(exercise.tokens.last.text, 'hoon');
    });

    test('word tiles do not reveal position with boundary punctuation', () {
      const punctuated = Question(
        type: 'translate',
        prompt: 'Translate the sentence',
        sentence: 'No, this is Ravi.',
        sentenceIsTargetLanguage: true,
        options: ['No, this is Ravi.', 'This is Ravi.', 'No.'],
        correctAnswer: 'No, this is Ravi.',
      );
      final generated = factory.generate(
        context: context,
        question: punctuated,
        preferredKind: GeneratedExerciseKind.wordBank,
      );
      final exercise = generated.exercise as WordBankExercise;

      expect(exercise.tokens.map((token) => token.text), [
        'No',
        'this',
        'is',
        'Ravi',
      ]);
      expect(exercise.correctAnswerLabel, 'No this is Ravi');
    });

    test('creates a safe fill choice only from a shared reviewed frame', () {
      final generated = factory.generate(
        context: context,
        question: conversationQuestion,
        preferredKind: GeneratedExerciseKind.fillBlankChoice,
      );

      expect(generated.usedFallback, isFalse);
      final exercise = generated.exercise as FillBlankChoiceExercise;
      expect(exercise.beforeBlank, 'Main');
      expect(exercise.afterBlank, 'jaata hoon.');
      expect(
        exercise.options.map((option) => option.text).toSet(),
        {'ghar', 'school', 'bazaar'},
      );
      expect(exercise.correctAnswerLabel, 'ghar');
    });

    test('falls back instead of inventing unsafe choice distractors', () {
      final generated = factory.generate(
        context: context,
        question: translationQuestion,
        preferredKind: GeneratedExerciseKind.fillBlankChoice,
      );

      expect(generated.usedFallback, isTrue);
      expect(generated.kind, GeneratedExerciseKind.fillBlankText);
      expect(generated.fallbackReason, 'fillBlankChoice_ineligible');
    });

    test('stable IDs survive question reordering', () {
      final first = factory.generate(
        context: context,
        question: translationQuestion,
        preferredKind: GeneratedExerciseKind.wordBank,
      );
      final afterReorder = factory.generate(
        context: context,
        question: translationQuestion,
        preferredKind: GeneratedExerciseKind.wordBank,
      );

      expect(afterReorder.sourceQuestionId, first.sourceQuestionId);
      expect(afterReorder.exercise.id, first.exercise.id);
    });

    test('does not mutate source options', () {
      final before = List<String>.from(conversationQuestion.options!);
      factory.buildStages(
        context: context,
        questions: List.filled(9, conversationQuestion),
      );
      expect(conversationQuestion.options, before);
    });

    test('one authored unit becomes Discover, Build, and Recall', () {
      final stages = factory.buildStages(
        context: context,
        questions: List.filled(9, translationQuestion),
      );

      expect(stages.map((stage) => stage.kind), LessonStageKind.values);
      expect(stages.map((stage) => stage.exercises.length), [6, 8, 6]);
      expect(stages.map((stage) => stage.id).toSet(), hasLength(3));
    });
  });

  test('all bundled questions generate across all 13 languages', () async {
    var questionCount = 0;
    var courseCount = 0;
    var authoredLevelCount = 0;
    var playableLessonCount = 0;

    for (final language in TargetLanguage.values) {
      final repository = CourseRepository();
      final groups = await repository.courses(language, firstName: 'Rishi');
      final dictionary = repository.cachedDictionary(language)!;
      for (final course in groups.expand((group) => group)) {
        courseCount += 1;
        for (final level in course.levels!) {
          authoredLevelCount += 1;
          questionCount += level.questions!.length;
          final stages = factory.buildStages(
            context: CourseExerciseContext(
              language: language,
              courseId: course.courseName,
              levelNumber: level.level!,
              dictionary: dictionary,
            ),
            questions: level.questions!,
          );
          playableLessonCount += stages.length;
          expect(stages, hasLength(3));
          for (final stage in stages) {
            expect(stage.exercises, isNotEmpty);
            expect(
              stage.exercises.map((item) => item.kind).toSet().length,
              greaterThanOrEqualTo(3),
              reason: '${language.name} ${course.courseName} '
                  'unit ${level.level} ${stage.kind.label} collapsed to '
                  'fewer than three interaction types',
            );
            expect(
              stage.exercises.map((item) => item.sourceQuestionId).toSet(),
              hasLength(stage.exercises.length),
            );
            for (final generated in stage.exercises) {
              final exercise = generated.exercise;
              if (exercise case final WordBankExercise ordered) {
                expect(
                  ordered.isCorrect(
                    OrderedExerciseResponse(ordered.acceptedOrders.first),
                  ),
                  isTrue,
                );
                expect(
                  ordered.tokens.every(
                    (token) => exerciseTokenText(token.text) == token.text,
                  ),
                  isTrue,
                  reason: '${language.name} ${exercise.id} leaked punctuation',
                );
              } else if (exercise case final SentenceOrderExercise ordered) {
                expect(
                  ordered.isCorrect(
                    OrderedExerciseResponse(ordered.acceptedOrders.first),
                  ),
                  isTrue,
                );
                expect(
                  ordered.tokens.every(
                    (token) => exerciseTokenText(token.text) == token.text,
                  ),
                  isTrue,
                  reason: '${language.name} ${exercise.id} leaked punctuation',
                );
              } else if (exercise case final GuessWordExercise guess) {
                expect(
                  guess.isCorrect(
                    OrderedExerciseResponse(guess.acceptedOrders.first),
                  ),
                  isTrue,
                );
              } else if (exercise case final FillBlankTextExercise text) {
                final alternatingCase = _alternatingCase(
                  text.acceptedAnswers.first,
                );
                expect(
                  text.isCorrect(TextExerciseResponse(alternatingCase)),
                  isTrue,
                  reason: '${language.name} ${exercise.id} was case-sensitive',
                );
              }
            }
          }
        }
      }
    }

    expect(courseCount, 195);
    expect(questionCount, 10530);
    expect(playableLessonCount, authoredLevelCount * 3);
  });
}

String _alternatingCase(String value) {
  var uppercase = true;
  return value.split('').map((character) {
    final result =
        uppercase ? character.toUpperCase() : character.toLowerCase();
    uppercase = !uppercase;
    return result;
  }).join();
}
