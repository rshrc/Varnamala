// Project imports:
import 'package:words625/core/enums.dart';

/// Everything the UI needs to present a language in one place: how to name it,
/// how it writes itself, where it lives, and the emblem on its card.
///
/// The picker and the home app bar both read from here, so a new language is
/// added once rather than in every widget that happens to show a flag.
class LanguageInfo {
  const LanguageInfo({
    required this.language,
    required this.englishName,
    required this.nativeName,
    required this.region,
  });

  final TargetLanguage language;
  final String englishName;

  /// The language's name in its own script.
  final String nativeName;

  /// Where it is spoken — the subtitle on the card.
  final String region;

  /// Card art, drawn as one visual set in `tool/generate_emblems.py`.
  String get emblem => 'assets/emblems/${language.name}.svg';
}

/// Every language the app teaches, in alphabetical order — the order the
/// picker shows them in.
const List<LanguageInfo> supportedLanguages = [
  LanguageInfo(
    language: TargetLanguage.assamese,
    englishName: 'Assamese',
    nativeName: 'অসমীয়া',
    region: 'Assam',
  ),
  LanguageInfo(
    language: TargetLanguage.bengali,
    englishName: 'Bengali',
    nativeName: 'বাংলা',
    region: 'West Bengal',
  ),
  LanguageInfo(
    language: TargetLanguage.gujarati,
    englishName: 'Gujarati',
    nativeName: 'ગુજરાતી',
    region: 'Gujarat',
  ),
  LanguageInfo(
    language: TargetLanguage.hindi,
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    region: 'North India',
  ),
  LanguageInfo(
    language: TargetLanguage.kannada,
    englishName: 'Kannada',
    nativeName: 'ಕನ್ನಡ',
    region: 'Karnataka',
  ),
  LanguageInfo(
    language: TargetLanguage.malayalam,
    englishName: 'Malayalam',
    nativeName: 'മലയാളം',
    region: 'Kerala',
  ),
  LanguageInfo(
    language: TargetLanguage.marathi,
    englishName: 'Marathi',
    nativeName: 'मराठी',
    region: 'Maharashtra',
  ),
  LanguageInfo(
    language: TargetLanguage.nepali,
    englishName: 'Nepali',
    nativeName: 'नेपाली',
    region: 'Nepal',
  ),
  LanguageInfo(
    language: TargetLanguage.odia,
    englishName: 'Odia',
    nativeName: 'ଓଡ଼ିଆ',
    region: 'Odisha',
  ),
  LanguageInfo(
    language: TargetLanguage.sanskrit,
    englishName: 'Sanskrit',
    nativeName: 'संस्कृतम्',
    region: 'Classical',
  ),
  LanguageInfo(
    language: TargetLanguage.tamil,
    englishName: 'Tamil',
    nativeName: 'தமிழ்',
    region: 'Tamil Nadu',
  ),
  LanguageInfo(
    language: TargetLanguage.telugu,
    englishName: 'Telugu',
    nativeName: 'తెలుగు',
    region: 'Andhra & Telangana',
  ),
  LanguageInfo(
    language: TargetLanguage.urdu,
    englishName: 'Urdu',
    nativeName: 'اردو',
    region: 'South Asia',
  ),
];

final Map<TargetLanguage, LanguageInfo> _byLanguage = {
  for (final info in supportedLanguages) info.language: info,
};

LanguageInfo languageInfo(TargetLanguage language) =>
    _byLanguage[language] ?? _byLanguage[TargetLanguage.kannada]!;

/// Looks up by the string [AppPrefs] stores, falling back to Kannada.
LanguageInfo languageInfoByName(String name) => supportedLanguages.firstWhere(
      (info) => info.language.name == name.toLowerCase(),
      orElse: () => _byLanguage[TargetLanguage.kannada]!,
    );
