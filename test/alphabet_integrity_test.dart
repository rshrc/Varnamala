import 'package:flutter_test/flutter_test.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/courses/alphabets/resource.dart';

void main() {
  // The bug this guards: the getters used to hand out the shared letter map
  // itself. The practice screen removes each letter as it is learned, so one
  // run of "Learn Vowels" emptied the alphabet for the rest of the session and
  // only Random Practice - which copies - still worked.
  test('a caller cannot empty the alphabet for everyone else', () {
    for (final language in TargetLanguage.values) {
      final before = getLanguageVowels(language).length;
      expect(before, greaterThan(0), reason: '${language.name} has no vowels');

      expect(
        () => getLanguageVowels(language).clear(),
        throwsUnsupportedError,
        reason: '${language.name} vowels are mutable by callers',
      );

      expect(getLanguageVowels(language).length, before,
          reason: '${language.name} vowels changed underneath us');
    }
  });

  test('every script exposes vowels, consonants and a full sound list', () {
    for (final language in TargetLanguage.values) {
      expect(getLanguageSounds(language), isNotEmpty, reason: language.name);
      expect(getLanguageConsonants(language), isNotEmpty,
          reason: language.name);
      expect(() => getLanguageSounds(language).clear(), throwsUnsupportedError);
      expect(() => getLanguageConsonants(language).clear(),
          throwsUnsupportedError);
    }
  });

  test('repeated reads are identical, so practice can be replayed', () {
    // Two sessions in a row must see the same letters.
    final first = getLanguageVowels(TargetLanguage.hindi);
    final second = getLanguageVowels(TargetLanguage.hindi);
    expect(first, equals(second));
  });
}
