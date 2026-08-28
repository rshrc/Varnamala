// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/lesson/lesson_screen.dart';
import 'package:words625/views/theme.dart';

void main() {
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

  testWidgets('a real course opens as a Discover interactive lesson',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: VarnamalaTheme.lightTheme,
        home: const LessonPage(course: _course),
      ),
    );
    await tester.pump();

    expect(find.text('UNIT 1 · DISCOVER'), findsOneWidget);
    expect(find.text('BETA'), findsOneWidget);
    expect(find.text('Choose the correct answer'), findsOneWidget);
    expect(find.text('Main ghar jaata hoon.'), findsWidgets);
    expect(find.text('CHECK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _question = Question(
  type: 'translate',
  prompt: 'Choose the correct answer',
  sentence: 'Main ghar jaata hoon.',
  sentenceIsTargetLanguage: true,
  options: ['I go home.', 'I stay home.', 'I left home.'],
  correctAnswer: 'I go home.',
);

const _course = Course(
  courseName: 'Basics',
  courseId: 'basics',
  language: 'hindi',
  levels: [
    Level(
      level: 1,
      questions: [
        _question,
        Question(
          type: 'translate',
          prompt: 'Translate the sentence',
          sentence: 'Yeh mera ghar hai.',
          sentenceIsTargetLanguage: true,
          options: [
            'This is my house.',
            'That is my house.',
            'This is my room.'
          ],
          correctAnswer: 'This is my house.',
        ),
        Question(
          type: 'translate',
          prompt: 'Translate the sentence',
          sentence: 'Mujhe chai pasand hai.',
          sentenceIsTargetLanguage: true,
          options: ['I like tea.', 'I want tea.', 'I made tea.'],
          correctAnswer: 'I like tea.',
        ),
        Question(
          type: 'translate',
          prompt: 'Translate the sentence',
          sentence: 'Woh school jaati hai.',
          sentenceIsTargetLanguage: true,
          options: ['She goes to school.', 'He goes home.', 'She left school.'],
          correctAnswer: 'She goes to school.',
        ),
        Question(
          type: 'translate',
          prompt: 'Translate the sentence',
          sentence: 'Aaj mausam achha hai.',
          sentenceIsTargetLanguage: true,
          options: [
            'The weather is nice today.',
            'It rained today.',
            'Today is cold.'
          ],
          correctAnswer: 'The weather is nice today.',
        ),
        Question(
          type: 'translate',
          prompt: 'Translate the sentence',
          sentence: 'Hum bazaar ja rahe hain.',
          sentenceIsTargetLanguage: true,
          options: [
            'We are going to the market.',
            'We left the market.',
            'They are at home.'
          ],
          correctAnswer: 'We are going to the market.',
        ),
        Question(
          type: 'translate',
          prompt: 'Translate the sentence',
          sentence: 'Mera naam Rishi hai.',
          sentenceIsTargetLanguage: true,
          options: [
            'My name is Rishi.',
            'His name is Rishi.',
            'Rishi is home.'
          ],
          correctAnswer: 'My name is Rishi.',
        ),
        Question(
          type: 'translate',
          prompt: 'Translate the sentence',
          sentence: 'Darwaza band kijiye.',
          sentenceIsTargetLanguage: true,
          options: [
            'Please close the door.',
            'Open the window.',
            'The door is open.'
          ],
          correctAnswer: 'Please close the door.',
        ),
      ],
    ),
  ],
);
