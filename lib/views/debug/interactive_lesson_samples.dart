// Project imports:
import 'package:words625/domain/exercise/interactive_exercise.dart';

List<InteractiveExercise> buildInteractiveLessonSamples() => [
      const WordBankExercise(
        id: 'sample-word-bank',
        prompt: 'Build the Kannada sentence',
        sourceText: 'My name is Ravi.',
        tokens: [
          ExerciseToken(id: 'wb-1', text: 'Nanna'),
          ExerciseToken(id: 'wb-2', text: 'hesaru'),
          ExerciseToken(id: 'wb-3', text: 'Ravi.'),
          ExerciseToken(id: 'wb-d1', text: 'Nimma'),
        ],
        acceptedOrders: [
          ['wb-1', 'wb-2', 'wb-3'],
        ],
        explanation: 'Nanna means “my”; nimma means “your”.',
        adaptiveRetry: FillBlankChoiceExercise(
          id: 'sample-word-bank-retry',
          prompt: 'Let’s practise that phrase another way',
          beforeBlank: 'Nanna',
          afterBlank: 'Ravi.',
          clue: 'My name is Ravi.',
          options: [
            ExerciseOption(id: 'a', text: 'hesaru'),
            ExerciseOption(id: 'b', text: 'mane'),
            ExerciseOption(id: 'c', text: 'nimma'),
          ],
          correctOptionId: 'a',
          explanation: 'Hesaru means “name”.',
        ),
      ),
      const SentenceOrderExercise(
        id: 'sample-sentence-order',
        prompt: 'Put the words in the correct order',
        translation: 'This is my house.',
        tokens: [
          ExerciseToken(id: 'so-1', text: 'Idu'),
          ExerciseToken(id: 'so-2', text: 'nanna'),
          ExerciseToken(id: 'so-3', text: 'mane.'),
        ],
        acceptedOrders: [
          ['so-1', 'so-2', 'so-3'],
        ],
        explanation: 'The possessor nanna comes before mane.',
        adaptiveRetry: FillBlankTextExercise(
          id: 'sample-sentence-order-retry',
          prompt: 'Recall the final word',
          beforeBlank: 'Idu nanna',
          afterBlank: '.',
          clue: 'This is my house.',
          acceptedAnswers: ['mane'],
          explanation: 'Mane means “house”.',
        ),
      ),
      const FillBlankChoiceExercise(
        id: 'sample-fill-choice',
        prompt: 'Choose the missing word',
        beforeBlank: 'Naanu',
        afterBlank: 'hoguttene.',
        clue: 'I am going home.',
        options: [
          ExerciseOption(id: 'fc-a', text: 'manege'),
          ExerciseOption(id: 'fc-b', text: 'hesaru'),
          ExerciseOption(id: 'fc-c', text: 'kaapi'),
        ],
        correctOptionId: 'fc-a',
        explanation: 'Manege means “to home”.',
        adaptiveRetry: WordBankExercise(
          id: 'sample-fill-choice-retry',
          prompt: 'Build the phrase you just practised',
          sourceText: 'I am going home.',
          tokens: [
            ExerciseToken(id: 'fcr-1', text: 'Naanu'),
            ExerciseToken(id: 'fcr-2', text: 'manege'),
            ExerciseToken(id: 'fcr-3', text: 'hoguttene.'),
          ],
          acceptedOrders: [
            ['fcr-1', 'fcr-2', 'fcr-3'],
          ],
          explanation: 'Manege identifies the destination: home.',
        ),
      ),
      const FillBlankTextExercise(
        id: 'sample-fill-text',
        prompt: 'Type the missing word',
        beforeBlank: 'Nanage kaapi',
        afterBlank: '.',
        clue: 'I like coffee.',
        acceptedAnswers: ['ishta'],
        explanation: 'Ishta expresses liking.',
        adaptiveRetry: FillBlankChoiceExercise(
          id: 'sample-fill-text-retry',
          prompt: 'Choose the word for “like”',
          beforeBlank: 'Nanage kaapi',
          afterBlank: '.',
          clue: 'I like coffee.',
          options: [
            ExerciseOption(id: 'ftr-a', text: 'ishta'),
            ExerciseOption(id: 'ftr-b', text: 'beda'),
            ExerciseOption(id: 'ftr-c', text: 'mane'),
          ],
          correctOptionId: 'ftr-a',
          explanation: 'Ishta means “like”; beda means “do not want”.',
        ),
      ),
      const FillBlankTextExercise(
        id: 'sample-fill-blank-text-fuzzy',
        prompt: 'Type the missing word',
        beforeBlank: 'Naanu',
        afterBlank: '.',
        clue: 'I am well.',
        acceptedAnswers: ['chennagiddene'],
        wordMeaning: 'I am well',
        // Try chenagidene: an equally valid romanization, accepted in silence.
        // Then try chennagiddane: a slip, accepted with the spelling shown.
        dictionary: {
          'chennagiddene': 'I am well',
          'naanu': 'I',
        },
        explanation: 'Chennagiddene means "I am well".',
      ),
    ];
