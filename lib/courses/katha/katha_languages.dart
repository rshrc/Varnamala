import 'package:words625/core/enums.dart';

/// Which languages Katha is told in, and how a telling's language code maps
/// to the app's. The only place a BCP-47 code is tied to a [TargetLanguage];
/// nothing else in Katha names a language.
abstract final class KathaLanguages {
  /// Telling codes to the app's languages.
  static const byCode = <String, TargetLanguage>{
    'as': TargetLanguage.assamese,
    'bn': TargetLanguage.bengali,
    'gu': TargetLanguage.gujarati,
    'hi': TargetLanguage.hindi,
    'kn': TargetLanguage.kannada,
    'ml': TargetLanguage.malayalam,
    'mr': TargetLanguage.marathi,
    'ne': TargetLanguage.nepali,
    'or': TargetLanguage.odia,
    'sa': TargetLanguage.sanskrit,
    'ta': TargetLanguage.tamil,
    'te': TargetLanguage.telugu,
    'ur': TargetLanguage.urdu,
  };

  /// The languages the stories are told in so far.
  static const toldIn = ['kn', 'hi'];

  /// The telling code for [language], if Katha is told in it yet.
  static String? tellingFor(TargetLanguage language) =>
      toldIn.where((code) => byCode[code] == language).firstOrNull;
}
