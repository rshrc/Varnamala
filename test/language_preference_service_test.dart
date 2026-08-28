import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/service/language_preference_service.dart';
import 'package:words625/service/locator.dart';

void main() {
  late AppPrefs appPrefs;
  late LanguagePreferenceService service;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    debugResetStreamingSharedPreferencesInstance();
    final preferences = await StreamingSharedPreferences.instance;
    appPrefs = AppPrefs(preferences);
    service = LanguagePreferenceService(appPrefs);
  });

  setUp(() => appPrefs.preferences.clear());

  test('a fresh install has no language selection', () {
    expect(service.readLocalSelection(), isNull);
  });

  test('an older explicit selection migrates without asking again', () async {
    await appPrefs.setString(
      PrefsConstants.currentLanguage,
      TargetLanguage.tamil.name,
    );

    expect(service.readLocalSelection(), TargetLanguage.tamil);
    expect(
      await service.restoreForUser('returning-user'),
      TargetLanguage.tamil,
    );
    expect(appPrefs.languageSelectionComplete.getValue(), isTrue);
  });

  test('an explicitly selected Kannada is distinct from the default', () async {
    await appPrefs.setString(
      PrefsConstants.currentLanguage,
      TargetLanguage.kannada.name,
    );
    await appPrefs.setBool(
      PrefsConstants.languageSelectionComplete,
      value: true,
    );

    expect(service.readLocalSelection(), TargetLanguage.kannada);
  });

  test('invalid stored language is not accepted', () async {
    await appPrefs.setString(
      PrefsConstants.currentLanguage,
      'klingon',
    );
    await appPrefs.setBool(
      PrefsConstants.languageSelectionComplete,
      value: true,
    );

    expect(service.readLocalSelection(), isNull);
  });
}
