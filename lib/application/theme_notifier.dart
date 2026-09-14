// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/theme.dart';

/// Riverpod proof-of-concept counterpart to [ThemeProvider] (the legacy
/// `provider`/`ChangeNotifier` version, kept side by side for now).
///
/// Same behaviour, same `AppPrefs` keys — this is the strangler-migration
/// first step: `provider` and `riverpod` coexist in the app until every
/// `ThemeProvider` consumer has moved over, at which point the old class is
/// deleted.
///
/// Split across two providers ([themeModeProvider] for [ThemeMode],
/// [paletteProvider] for [AppPalette]) rather than one, because they are
/// independent axes — picking a palette doesn't decide light/dark, so a
/// widget that only cares about one shouldn't rebuild when the other
/// changes. `ThemeProvider` bundles both on one `ChangeNotifier`, which is
/// exactly the "everything rebuilds when anything changes" limitation this
/// migration is meant to fix.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storedMode = getIt<AppPrefs>()
        .preferences
        .getString(PrefsConstants.themeMode, defaultValue: 'system')
        .getValue();
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == storedMode,
      orElse: () => ThemeMode.system,
    );
  }

  bool get isDarkMode => state == ThemeMode.dark;

  /// The currently selected palette's light theme.
  ThemeData get lightTheme =>
      buildAppTheme(ref.read(paletteProvider), Brightness.light);

  /// The currently selected palette's dark theme.
  ThemeData get darkTheme =>
      buildAppTheme(ref.read(paletteProvider), Brightness.dark);

  ThemeData get currentTheme =>
      state == ThemeMode.dark ? darkTheme : lightTheme;

  /// The colour scheme the learner picked. Independent of [state]: every
  /// palette ships a light and a dark build, so choosing "Marigold" does not
  /// also decide whether it is day or night.
  AppPalette get palette => ref.read(paletteProvider);

  void setPalette(AppPalette newPalette) =>
      ref.read(paletteProvider.notifier).setPalette(newPalette);

  void toggleTheme() {
    setThemeMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemeMode(ThemeMode mode) {
    if (state == mode) return;
    state = mode;
    getIt<AppPrefs>().setString(PrefsConstants.themeMode, mode.name);
  }

  void setLightMode() => setThemeMode(ThemeMode.light);

  void setDarkMode() => setThemeMode(ThemeMode.dark);
}

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class PaletteNotifier extends Notifier<AppPalette> {
  @override
  AppPalette build() {
    return paletteById(
      getIt<AppPrefs>()
          .preferences
          .getString(PrefsConstants.themePalette,
              defaultValue: appPalettes.first.id)
          .getValue(),
    );
  }

  void setPalette(AppPalette palette) {
    if (state.id == palette.id) return;
    state = palette;
    getIt<AppPrefs>().setString(PrefsConstants.themePalette, palette.id);
  }
}

final paletteProvider = NotifierProvider<PaletteNotifier, AppPalette>(
  PaletteNotifier.new,
);
