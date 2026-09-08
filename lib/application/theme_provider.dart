// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/theme.dart';

@injectable
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    final storedMode = getIt<AppPrefs>()
        .preferences
        .getString(PrefsConstants.themeMode, defaultValue: 'system')
        .getValue();
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == storedMode,
      orElse: () => ThemeMode.system,
    );
    _palette = paletteById(
      getIt<AppPrefs>()
          .preferences
          .getString(PrefsConstants.themePalette,
              defaultValue: appPalettes.first.id)
          .getValue(),
    );
  }

  ThemeMode _themeMode = ThemeMode.system;
  AppPalette _palette = appPalettes.first;

  ThemeMode get themeMode => _themeMode;

  /// The colour scheme the learner picked. Independent of [themeMode]: every
  /// palette ships a light and a dark build, so choosing "Marigold" does not
  /// also decide whether it is day or night.
  AppPalette get palette => _palette;

  ThemeData get lightTheme => buildAppTheme(_palette, Brightness.light);

  ThemeData get darkTheme => buildAppTheme(_palette, Brightness.dark);

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeData get currentTheme =>
      _themeMode == ThemeMode.dark ? darkTheme : lightTheme;

  void setPalette(AppPalette palette) {
    if (_palette.id == palette.id) return;
    _palette = palette;
    getIt<AppPrefs>().setString(PrefsConstants.themePalette, palette.id);
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    getIt<AppPrefs>().setString(PrefsConstants.themeMode, mode.name);
    notifyListeners();
  }

  void setLightMode() {
    setThemeMode(ThemeMode.light);
  }

  void setDarkMode() {
    setThemeMode(ThemeMode.dark);
  }
}
