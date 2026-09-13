// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/theme_notifier.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/theme.dart';

/// Behaviour tests for [ThemeNotifier] and [PaletteNotifier], the Riverpod
/// counterparts to the legacy `ThemeProvider` (which bundles both theme mode
/// and palette on one `ChangeNotifier`). Written against observable
/// behaviour (what the UI would see: theme mode, palette, persisted
/// preferences) rather than internal state, so they stay valid once
/// ThemeProvider itself is retired.
void main() {
  late AppPrefs appPrefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    debugResetStreamingSharedPreferencesInstance();
    final preferences = await StreamingSharedPreferences.instance;
    appPrefs = AppPrefs(preferences);
    getIt.registerSingleton<AppPrefs>(appPrefs);
  });

  setUp(() => appPrefs.preferences.clear());

  tearDownAll(() async {
    if (getIt.isRegistered<AppPrefs>()) {
      await getIt.unregister<AppPrefs>();
    }
  });

  test('defaults to system mode on a fresh install', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('restores a previously saved mode on startup', () async {
    await getIt<AppPrefs>().setString(PrefsConstants.themeMode, 'dark');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('an unrecognised stored value falls back to system', () async {
    await getIt<AppPrefs>().setString(PrefsConstants.themeMode, 'sepia');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('setThemeMode updates state and persists the choice', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(
      getIt<AppPrefs>()
          .preferences
          .getString(PrefsConstants.themeMode, defaultValue: '')
          .getValue(),
      'dark',
    );
  });

  test('setting the same mode again does not notify listeners', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    var notifications = 0;
    container.listen(themeModeProvider, (_, __) => notifications++);

    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    expect(notifications, 0);
  });

  test('toggleTheme flips between light and dark', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(themeModeProvider.notifier);

    notifier.setThemeMode(ThemeMode.light);
    notifier.toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.dark);

    notifier.toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('toggleTheme from system mode moves to dark', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(themeModeProvider.notifier);

    expect(container.read(themeModeProvider), ThemeMode.system);
    notifier.toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('setLightMode and setDarkMode set the mode directly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(themeModeProvider.notifier);

    notifier.setDarkMode();
    expect(container.read(themeModeProvider), ThemeMode.dark);

    notifier.setLightMode();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('isDarkMode and currentTheme reflect the current mode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(themeModeProvider.notifier);

    notifier.setDarkMode();
    expect(notifier.isDarkMode, isTrue);
    expect(notifier.currentTheme.brightness, Brightness.dark);

    notifier.setLightMode();
    expect(notifier.isDarkMode, isFalse);
    expect(notifier.currentTheme.brightness, Brightness.light);
  });

  test('palette defaults to the first palette on a fresh install', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(paletteProvider).id, appPalettes.first.id);
  });

  test('restores a previously saved palette on startup', () async {
    final marigold = appPalettes.firstWhere((p) => p.id == 'marigold');
    await getIt<AppPrefs>().setString(PrefsConstants.themePalette, marigold.id);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(paletteProvider).id, 'marigold');
  });

  test('an unrecognised stored palette falls back to the first', () async {
    await getIt<AppPrefs>().setString(PrefsConstants.themePalette, 'does-not-exist');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(paletteProvider).id, appPalettes.first.id);
  });

  test('setPalette updates state and persists the choice', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final marigold = appPalettes.firstWhere((p) => p.id == 'marigold');

    container.read(paletteProvider.notifier).setPalette(marigold);

    expect(container.read(paletteProvider).id, 'marigold');
    expect(
      getIt<AppPrefs>()
          .preferences
          .getString(PrefsConstants.themePalette, defaultValue: '')
          .getValue(),
      'marigold',
    );
  });

  test('setting the same palette again does not notify listeners', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final marigold = appPalettes.firstWhere((p) => p.id == 'marigold');

    container.read(paletteProvider.notifier).setPalette(marigold);

    var notifications = 0;
    container.listen(paletteProvider, (_, __) => notifications++);

    container.read(paletteProvider.notifier).setPalette(marigold);

    expect(notifications, 0);
  });

  test('theme mode and palette are independent axes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final marigold = appPalettes.firstWhere((p) => p.id == 'marigold');

    container.read(themeModeProvider.notifier).setDarkMode();
    container.read(paletteProvider.notifier).setPalette(marigold);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(paletteProvider).id, 'marigold');
  });

  test('ThemeNotifier.palette and setPalette proxy to paletteProvider', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final marigold = appPalettes.firstWhere((p) => p.id == 'marigold');
    final notifier = container.read(themeModeProvider.notifier);

    notifier.setPalette(marigold);

    expect(notifier.palette.id, 'marigold');
    expect(container.read(paletteProvider).id, 'marigold');
  });
}
