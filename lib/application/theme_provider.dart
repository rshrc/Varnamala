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
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeData get currentTheme => _themeMode == ThemeMode.dark
      ? VarnamalaTheme.darkTheme
      : VarnamalaTheme.lightTheme;

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
