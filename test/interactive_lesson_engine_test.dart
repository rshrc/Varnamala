import 'package:flutter_test/flutter_test.dart';
import 'package:words625/application/interactive_lesson_engine.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';

void main() {
  group('interactive exercise validation', () {
    test('ordered exercises compare visible values and order', () {
      const exercise = WordBankExercise(
        id: 'order',
        prompt: 'Build it',
        explanation: 'Explanation',
        sourceText: 'My house',
        tokens: [
          ExerciseToken(id: 'a', text: 'nanna'),
          ExerciseToken(id: 'b', text: 'mane'),
          ExerciseToken(id: 'x', text: 'nimma'),
        ],
        acceptedOrders: [
          ['a', 'b'],
        ],
      );

      expect(
        exercise.isCorrect(OrderedExerciseResponse(['a', 'b'])),
        isTrue,
      );
      expect(
        exercise.isCorrect(OrderedExerciseResponse(['b', 'a'])),
        isFalse,
      );
      expect(
        exercise.isCorrect(OrderedExerciseResponse(['a', 'b', 'x'])),
        isFalse,
      );
    });

    test('identical repeated letters are interchangeable', () {
      for (final word in [
        'amar',
        'nanage',
        'pustaka',
        'masala',
        'dhonnobad',
      ]) {
        final letters = word.split('');
        final tokens = [
          for (var index = 0; index < letters.length; index++)
            ExerciseToken(id: 'letter-$index', text: letters[index]),
        ];
        final accepted = tokens.map((token) => token.id).toList();
        final repeatedLetter = letters.firstWhere(
          (letter) => letters.where((item) => item == letter).length > 1,
        );
        final repeatedPositions = [
          for (var index = 0; index < letters.length; index++)
            if (letters[index] == repeatedLetter) index,
        ];
        final visuallyIdenticalAnswer = List<String>.from(accepted);
        final first = repeatedPositions.first;
        final second = repeatedPositions[1];
        visuallyIdenticalAnswer[first] = accepted[second];
        visuallyIdenticalAnswer[second] = accepted[first];
        final exercise = GuessWordExercise(
          id: word,
          prompt: 'Guess it',
          explanation: word,
          clue: word,
          tokens: tokens,
          acceptedOrders: [accepted],
        );

        expect(
          exercise.isCorrect(OrderedExerciseResponse(visuallyIdenticalAnswer)),
          isTrue,
          reason: '$word must not depend on which identical tile was used',
        );
      }
    });

    test('typed blanks normalize case, whitespace, and terminal punctuation',
        () {
      const exercise = FillBlankTextExercise(
        id: 'text',
        prompt: 'Type it',
        explanation: 'Explanation',
        beforeBlank: 'Nanna',
        afterBlank: '.',
        clue: 'My house',
        acceptedAnswers: ['Mane'],
      );

      expect(
        exercise.isCorrect(const TextExerciseResponse('  MANE.  ')),
        isTrue,
      );
      expect(
        exercise.isCorrect(const TextExerciseResponse('mAnE')),
        isTrue,
      );
      expect(
        exercise.isCorrect(const TextExerciseResponse('manege')),
        isFalse,
      );
    });
  });

  test('a mistake inserts its alternate retry after two other exercises', () {
    const retry = FillBlankTextExercise(
      id: 'first-retry',
      prompt: 'Retry',
      explanation: 'Explanation',
      beforeBlank: 'Nanna',
      afterBlank: '.',
      clue: 'My house',
      acceptedAnswers: ['mane'],
    );
    const first = FillBlankChoiceExercise(
      id: 'first',
      prompt: 'First',
      explanation: 'Explanation',
      beforeBlank: 'Nanna',
      afterBlank: '.',
      clue: 'My house',
      options: [
        ExerciseOption(id: 'right', text: 'mane'),
        ExerciseOption(id: 'wrong', text: 'hesaru'),
      ],
      correctOptionId: 'right',
      adaptiveRetry: retry,
    );
    final engine = InteractiveLessonEngine(
      exercises: [
        first,
        _choice('second'),
        _choice('third'),
        _choice('fourth'),
      ],
    );

    engine.setResponse(const ChoiceExerciseResponse('wrong'));
    expect(engine.submit(), isFalse);
    expect(engine.retryScheduledForLastAttempt, isTrue);
    expect(engine.totalSteps, 5);

    engine.continueLesson();
    expect(engine.currentExercise.id, 'second');
    _answerChoiceCorrectly(engine);

    engine.continueLesson();
    expect(engine.currentExercise.id, 'third');
    _answerChoiceCorrectly(engine);

    engine.continueLesson();
    expect(engine.currentExercise.id, 'first-retry');
    expect(engine.currentStep.isAdaptiveRetry, isTrue);
  });

  test('restart removes adaptive queue changes and lesson attempts', () {
    final engine = InteractiveLessonEngine(exercises: [_choice('only')]);
    _answerChoiceCorrectly(engine);
    engine.continueLesson();

    expect(engine.phase, InteractiveLessonPhase.complete);
    expect(engine.attempts, hasLength(1));

    engine.restart();

    expect(engine.phase, InteractiveLessonPhase.answering);
    expect(engine.attempts, isEmpty);
    expect(engine.currentNumber, 1);
    expect(engine.totalSteps, 1);
  });
}

FillBlankChoiceExercise _choice(String id) => FillBlankChoiceExercise(
      id: id,
      prompt: id,
      explanation: 'Explanation',
      beforeBlank: 'before',
      afterBlank: 'after',
      clue: 'clue',
      options: const [
        ExerciseOption(id: 'right', text: 'right'),
        ExerciseOption(id: 'wrong', text: 'wrong'),
      ],
      correctOptionId: 'right',
    );

void _answerChoiceCorrectly(InteractiveLessonEngine engine) {
  engine.setResponse(const ChoiceExerciseResponse('right'));
  expect(engine.submit(), isTrue);
}
