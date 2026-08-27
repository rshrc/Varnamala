// Dart imports:
import 'dart:convert';
import 'dart:math';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:words625/core/language_info.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';

class DemoQuestion {
  const DemoQuestion({
    required this.language,
    required this.nativeLanguage,
    required this.level,
    required this.prompt,
    required this.sentence,
    required this.options,
    required this.correctAnswer,
    this.translation,
  });

  final String language;
  final String nativeLanguage;
  final int level;
  final String prompt;
  final String sentence;
  final List<String> options;
  final String correctAnswer;
  final String? translation;
}

/// Reads one beginner question from the bundled course JSON.
///
/// It deliberately does not use [CourseRepository], because that repository
/// may read an active Firestore release. Splash demos must remain local-only.
class DemoLessonService {
  DemoLessonService({AssetBundle? bundle, Random? random})
      : _bundle = bundle ?? rootBundle,
        _random = random ?? Random();

  final AssetBundle _bundle;
  final Random _random;

  int get count => getIt<AppPrefs>()
      .preferences
      .getInt(PrefsConstants.demoCount, defaultValue: 0)
      .getValue();

  Future<int> recordStart() async {
    final nextCount = count + 1;
    await getIt<AppPrefs>().setInt(PrefsConstants.demoCount, nextCount);
    return nextCount;
  }

  Future<DemoQuestion> loadRandomQuestion() async {
    final info = supportedLanguages[_random.nextInt(supportedLanguages.length)];
    final path = 'assets/courses/${info.language.name}/basics.json';
    final json = jsonDecode(await _bundle.loadString(path)) as Map;
    final levels = (json['levels'] as List).cast<Map>();
    final basicLevel = levels.first;
    final questions = (basicLevel['questions'] as List).cast<Map>();
    final raw = questions[_random.nextInt(questions.length)];
    final rawTranslation = raw['translatedSentence'] as String?;
    final options = (raw['options'] as List)
        .cast<String>()
        .map(_personalise)
        .toList()
      ..shuffle(_random);

    return DemoQuestion(
      language: info.englishName,
      nativeLanguage: info.nativeName,
      level: (basicLevel['level'] as num?)?.toInt() ?? 1,
      prompt: raw['prompt'] as String? ?? 'Choose the correct answer',
      sentence: _personalise(raw['sentence'] as String? ?? ''),
      options: options,
      correctAnswer: _personalise(raw['correctAnswer'] as String? ?? ''),
      translation: rawTranslation == null ? null : _personalise(rawTranslation),
    );
  }

  String _personalise(String value) => value.replaceAll('{name}', 'Mala');
}
