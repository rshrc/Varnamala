// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/audio_controller.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/lesson/exercises/widgets/exercise_picture_tile.dart';
import 'package:words625/views/lesson/lesson_screen.dart';
import 'package:words625/views/theme.dart';

void main() {
  setUpAll(() {
    // Checking an answer cues a sound. One controller for the whole file:
    // building an AudioPlayer per test leaves live players behind and later
    // pumpAndSettle calls never settle.
    if (!getIt.isRegistered<AudioController>()) {
      getIt.registerSingleton<AudioController>(_SilentAudioController());
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    debugResetStreamingSharedPreferencesInstance();
    final preferences = await StreamingSharedPreferences.instance;
    if (getIt.isRegistered<AppPrefs>()) {
      await getIt.unregister<AppPrefs>();
    }
    getIt.registerSingleton<AppPrefs>(AppPrefs(preferences));
  });

  tearDown(() async {
    if (getIt.isRegistered<AppPrefs>()) {
      await getIt.unregister<AppPrefs>();
    }
  });

  Future<void> openLesson(WidgetTester tester, {int? stageIndex}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: VarnamalaTheme.lightTheme,
        home: LessonPage(course: _course, stageIndex: stageIndex),
      ),
    );
    // The concept catalogue is read from the bundle, so the first frame is a
    // spinner and the exercises arrive on the next one.
    await tester.pumpAndSettle();
  }

  testWidgets('a word course opens on a picture, not a sentence',
      (tester) async {
    await openLesson(tester);

    expect(find.text('UNIT 1 · DISCOVER'), findsOneWidget);
    expect(find.text('Which word is this?'), findsOneWidget);
    // Four target-language words to choose between, and the picture above.
    expect(find.text('CHECK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking the right word is checked and praised', (tester) async {
    await openLesson(tester);

    // The prompt names the concept, and one of the tiles is its word.
    await tester.tap(find.text('neeru'));
    await tester.pump();

    await tester.tap(find.text('CHECK'));
    await tester.pumpAndSettle();

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.textContaining('neeru'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the build stage asks for the picture instead', (tester) async {
    await openLesson(tester, stageIndex: 1);

    expect(find.text('UNIT 1 · BUILD'), findsOneWidget);
    expect(find.byType(ExercisePictureTile), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  /// Types [answer] into the recall stage's first exercise and checks it.
  Future<void> answerRecall(WidgetTester tester, String answer) async {
    await openLesson(tester, stageIndex: 2);
    expect(find.text('UNIT 1 · RECALL'), findsOneWidget);
    expect(find.text('Type the word'), findsOneWidget);
    // The picture is the prompt; "hello" is the clue under it.
    expect(find.text('hello'), findsOneWidget);

    await tester.enterText(find.byType(TextField), answer);
    await tester.pump();
    await tester.tap(find.text('CHECK'));
    await tester.pumpAndSettle();
  }

  testWidgets('typing the word exactly is simply correct', (tester) async {
    await answerRecall(tester, 'namaskara');

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.textContaining('Correct answer'), findsNothing);
    expect(
      find.text('Almost!'),
      findsNothing,
      reason: 'the authored spelling must not be corrected',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('an equally valid romanization is accepted in silence',
      (tester) async {
    // namaskaara: the same word, the same sound, a longer a. Romanized Indic
    // has no single correct spelling, so this is not a mistake to point out.
    await answerRecall(tester, 'namaskaara');

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.textContaining('Correct answer'), findsNothing);
    expect(find.text('Almost!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a typo is forgiven but the spelling is shown', (tester) async {
    // One letter dropped. A learner who wrote this knows the word.
    await answerRecall(tester, 'namaskra');

    expect(find.text('Almost!'), findsOneWidget);
    expect(find.textContaining('namaskara'), findsWidgets);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a different word is still wrong', (tester) async {
    await answerRecall(tester, 'neeru');

    expect(find.text('Almost!'), findsNothing);
    expect(find.textContaining('Correct answer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Keeps the verdict cue on the code path without reaching for the audio
/// plugin, which has no implementation under `flutter test`.
class _SilentAudioController implements AudioController {
  @override
  Future<void> playRandomErrorSound() async {}

  @override
  Future<void> playRandomLevelUpSound() async {}
}

/// A single word level, shaped exactly like `assets/courses/kannada/words.json`.
const _course = Course(
  courseName: 'First words',
  courseId: 'words',
  language: 'kannada',
  levels: [
    Level(
      level: 1,
      words: [
        VocabularyWord(concept: 'water', word: 'neeru'),
        VocabularyWord(concept: 'milk', word: 'haalu'),
        VocabularyWord(concept: 'tea', word: 'chahaa'),
        VocabularyWord(concept: 'rice', word: 'akki'),
        VocabularyWord(concept: 'egg', word: 'motte'),
        // Index 5 is where the recall stage starts on an eight-word level, so
        // this is the word the typing tests below are answering.
        VocabularyWord(concept: 'hello', word: 'namaskara'),
        VocabularyWord(concept: 'fish', word: 'meenu'),
        VocabularyWord(concept: 'house', word: 'mane'),
      ],
    ),
  ],
);
