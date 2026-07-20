// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/courses/alphabets/alphabets.dart';

/// Every letter of the script, in teaching order.
Map<String, String> getLanguageSounds(TargetLanguage language) =>
    switch (language) {
      TargetLanguage.assamese => assameseSounds,
      TargetLanguage.bengali => bengaliSounds,
      TargetLanguage.hindi => hindiSounds,
      TargetLanguage.kannada => kannadaSounds,
      TargetLanguage.malayalam => malayalamSounds,
      TargetLanguage.nepali => nepaliSounds,
      TargetLanguage.odia => odiaSounds,
      TargetLanguage.tamil => tamilSounds,
      TargetLanguage.telugu => teluguSounds,
    };

Map<String, String> getLanguageVowels(TargetLanguage language) =>
    switch (language) {
      TargetLanguage.assamese => assameseVowels,
      TargetLanguage.bengali => bengaliVowels,
      TargetLanguage.hindi => hindiVowels,
      TargetLanguage.kannada => kannadaVowels,
      TargetLanguage.malayalam => malayalamVowels,
      TargetLanguage.nepali => nepaliVowels,
      TargetLanguage.odia => odiaVowels,
      TargetLanguage.tamil => tamilVowels,
      TargetLanguage.telugu => teluguVowels,
    };

Map<String, String> getLanguageConsonants(TargetLanguage language) =>
    switch (language) {
      TargetLanguage.assamese => assameseConsonants,
      TargetLanguage.bengali => bengaliConsonants,
      TargetLanguage.hindi => hindiConsonants,
      TargetLanguage.kannada => kannadaConsonants,
      TargetLanguage.malayalam => malayalamConsonants,
      TargetLanguage.nepali => nepaliConsonants,
      TargetLanguage.odia => odiaConsonants,
      TargetLanguage.tamil => tamilConsonants,
      TargetLanguage.telugu => teluguConsonants,
    };
