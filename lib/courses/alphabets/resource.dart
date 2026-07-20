// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/courses/alphabets/alphabets.dart';

/// Every letter of the script, in teaching order.
Map<String, String> getLanguageSounds(TargetLanguage language) =>
    switch (language) {
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
    };

Map<String, String> getLanguageVowels(TargetLanguage language) =>
    switch (language) {
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
    };

Map<String, String> getLanguageConsonants(TargetLanguage language) =>
    switch (language) {
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
    };
