enum TargetLanguage {
  kannada,
  tamil,
  telugu,
  malayalam,
  hindi,
  bengali,
  odia,
  nepali,
  assamese,
  gujarati,
  marathi,
  urdu,
  sanskrit,
}

/// The BCP-47 locale a language should be *spoken* in.
///
/// Lesson text is romanized, so for a long time everything was read by an
/// Indian English voice. That is a stopgap, not a language: "akki" through an
/// English voice comes out with English vowels. Naming the real locale lets
/// [SpeechService] reach for a native voice first and fall back only when the
/// device has not got one.
extension TargetLanguageSpeech on TargetLanguage {
  String get speechLocale => switch (this) {
        TargetLanguage.kannada => 'kn-IN',
        TargetLanguage.tamil => 'ta-IN',
        TargetLanguage.telugu => 'te-IN',
        TargetLanguage.malayalam => 'ml-IN',
        TargetLanguage.hindi => 'hi-IN',
        TargetLanguage.bengali => 'bn-IN',
        TargetLanguage.odia => 'or-IN',
        TargetLanguage.nepali => 'ne-NP',
        TargetLanguage.assamese => 'as-IN',
        TargetLanguage.gujarati => 'gu-IN',
        TargetLanguage.marathi => 'mr-IN',
        TargetLanguage.urdu => 'ur-PK',
        // Sanskrit voices barely exist. Hindi shares its script and most of
        // its sounds, so it is a far better reader than English is.
        TargetLanguage.sanskrit => 'sa-IN',
      };

  /// Locales to try, in order, before giving up on a native voice.
  List<String> get speechLocaleFallbacks => switch (this) {
        TargetLanguage.sanskrit => const ['sa-IN', 'hi-IN'],
        TargetLanguage.assamese => const ['as-IN', 'bn-IN'],
        TargetLanguage.nepali => const ['ne-NP', 'ne-IN', 'hi-IN'],
        TargetLanguage.urdu => const ['ur-PK', 'ur-IN', 'hi-IN'],
        TargetLanguage.odia => const ['or-IN', 'od-IN'],
        _ => [speechLocale],
      };
}

/// The [TargetLanguage] for a stored language name, or null when it is absent
/// or unrecognised - content predating the field, or a name we no longer ship.
TargetLanguage? targetLanguageNamed(String? name) {
  if (name == null) return null;
  for (final language in TargetLanguage.values) {
    if (language.name == name) return language;
  }
  return null;
}
