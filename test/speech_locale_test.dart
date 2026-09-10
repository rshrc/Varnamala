// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/core/enums.dart';

void main() {
  test('every language names a speech locale of its own', () {
    final locales = <String>{};
    for (final language in TargetLanguage.values) {
      final locale = language.speechLocale;
      expect(
        locale,
        matches(RegExp(r'^[a-z]{2}-[A-Z]{2}$')),
        reason: '${language.name} has a malformed locale: $locale',
      );
      locales.add(locale);
    }

    // The bug this guards: one voice was chosen once for the whole app, so a
    // Tamil learner and a Hindi learner were read to by the same reader.
    expect(
      locales,
      hasLength(TargetLanguage.values.length),
      reason: 'two languages share a speech locale',
    );
  });

  test('no language is read by an English voice by default', () {
    for (final language in TargetLanguage.values) {
      expect(
        language.speechLocale.startsWith('en'),
        isFalse,
        reason: '${language.name} would be read in English',
      );
    }
  });

  test('fallbacks start with the real locale and stay in the family', () {
    for (final language in TargetLanguage.values) {
      final fallbacks = language.speechLocaleFallbacks;
      expect(fallbacks, isNotEmpty);
      expect(
        fallbacks.first,
        language.speechLocale,
        reason: '${language.name} does not try its own voice first',
      );
      // A fallback to English would defeat the point; that decision belongs to
      // SpeechService, after every native option has been tried.
      for (final locale in fallbacks) {
        expect(locale.startsWith('en'), isFalse);
      }
    }
  });

  test('the scripts that share a reader say so', () {
    // Sanskrit and Nepali are written in Devanagari, and voices for them are
    // rare, so Hindi is a far better reader than English.
    expect(TargetLanguage.sanskrit.speechLocaleFallbacks, contains('hi-IN'));
    expect(TargetLanguage.nepali.speechLocaleFallbacks, contains('hi-IN'));
    // Assamese is written in the Bengali script.
    expect(TargetLanguage.assamese.speechLocaleFallbacks, contains('bn-IN'));
  });
}
