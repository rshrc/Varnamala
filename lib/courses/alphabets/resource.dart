// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/courses/alphabets/alphabets.dart';

/// Every letter of the script, in teaching order.
///
/// The three getters below all return an **unmodifiable copy**. The letter
/// maps are ordinary top-level `Map`s, so handing the instance itself to a
/// caller let one screen permanently empty the alphabet for the whole session:
/// the practice screen removed each letter as it was learned, and "Learn
/// Vowels" worked exactly once per app launch.
Map<String, String> getLanguageSounds(TargetLanguage language) =>
    Map.unmodifiable(switch (language) {
      TargetLanguage.assamese => assameseSounds,
      TargetLanguage.bengali => bengaliSounds,
      TargetLanguage.gujarati => gujaratiSounds,
      TargetLanguage.hindi => hindiSounds,
      TargetLanguage.kannada => kannadaSounds,
      TargetLanguage.malayalam => malayalamSounds,
      TargetLanguage.marathi => marathiSounds,
      TargetLanguage.nepali => nepaliSounds,
      TargetLanguage.odia => odiaSounds,
      TargetLanguage.sanskrit => sanskritSounds,
      TargetLanguage.tamil => tamilSounds,
      TargetLanguage.telugu => teluguSounds,
      TargetLanguage.urdu => urduSounds,
    });

Map<String, String> getLanguageVowels(TargetLanguage language) =>
    Map.unmodifiable(switch (language) {
      TargetLanguage.assamese => assameseVowels,
      TargetLanguage.bengali => bengaliVowels,
      TargetLanguage.gujarati => gujaratiVowels,
      TargetLanguage.hindi => hindiVowels,
      TargetLanguage.kannada => kannadaVowels,
      TargetLanguage.malayalam => malayalamVowels,
      TargetLanguage.marathi => marathiVowels,
      TargetLanguage.nepali => nepaliVowels,
      TargetLanguage.odia => odiaVowels,
      TargetLanguage.sanskrit => sanskritVowels,
      TargetLanguage.tamil => tamilVowels,
      TargetLanguage.telugu => teluguVowels,
      TargetLanguage.urdu => urduVowels,
    });

Map<String, String> getLanguageConsonants(TargetLanguage language) =>
    Map.unmodifiable(switch (language) {
      TargetLanguage.assamese => assameseConsonants,
      TargetLanguage.bengali => bengaliConsonants,
      TargetLanguage.gujarati => gujaratiConsonants,
      TargetLanguage.hindi => hindiConsonants,
      TargetLanguage.kannada => kannadaConsonants,
      TargetLanguage.malayalam => malayalamConsonants,
      TargetLanguage.marathi => marathiConsonants,
      TargetLanguage.nepali => nepaliConsonants,
      TargetLanguage.odia => odiaConsonants,
      TargetLanguage.sanskrit => sanskritConsonants,
      TargetLanguage.tamil => tamilConsonants,
      TargetLanguage.telugu => teluguConsonants,
      TargetLanguage.urdu => urduConsonants,
    });
