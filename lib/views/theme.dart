// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/views/theme_palette.dart';

export 'package:words625/views/theme_palette.dart';

/// Varnamala Peacock Theme
/// A vibrant theme inspired by peacock feathers with teal, cyan, and emerald tones
class VarnamalaTheme {
  VarnamalaTheme._();

  // PRIMARY PEACOCK COLORS
  static const Color peacockDeep = Color(0xFF1A0285);
  static const Color peacockTeal = Color(0xFF1F727E);
  static const Color peacockCyan = Color(0xFF359CBB);
  static const Color peacockTurquoise = Color(0xFF46D1BF);
  static const Color peacockMint = Color(0xFF00FFC6);

  // SEMANTIC COLORS
  static const Color primary = peacockTeal;
  static const Color primaryLight = peacockCyan;
  static const Color primaryDark = Color(0xFF145A64);
  static const Color secondary = peacockTurquoise;
  static const Color secondaryLight = peacockMint;
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color errorDark = Color(0xFFC0392B);
  static const Color success = Color(0xFFFFD93D);
  static const Color successLight = Color(0xFFFFE066);
  static const Color successDark = Color(0xFFE5C235);
  static const Color warning = Color(0xFFFF9F43);
  static const Color warningLight = Color(0xFFFFBE76);
  static const Color info = peacockCyan;

  // BACKGROUND COLORS
  static const Color background = Color(0xFFF8FFFE);
  static const Color surface = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF5FDFB);
  static const Color cardBackground = Colors.white;
  static const Color elevatedSurface = Color(0xFFFFFFFF);

  // DARK SURFACES
  static const Color darkBackground = Color(0xFF0B1517);
  static const Color darkSurface = Color(0xFF14272B);
  static const Color darkElevatedSurface = Color(0xFF1B3338);
  static const Color darkTextPrimary = Color(0xFFF3FCFA);
  static const Color darkTextSecondary = Color(0xFFBDD0CC);
  static const Color darkTextHint = Color(0xFF91AAA5);

  // VIBRANT DARK-MODE ACCENTS
  static const Color darkMint = Color(0xFF65E6D5);
  static const Color darkSky = Color(0xFF72C8FF);
  static const Color darkGold = Color(0xFFFFD166);
  static const Color darkCoral = Color(0xFFFF8A84);
  static const Color darkViolet = Color(0xFFC4A7FF);

  // TEXT COLORS
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // LEAGUE COLORS (Jewel Tones)
  static const Color leagueBronze = Color(0xFFCD7F32);
  static const Color leagueSilver = Color(0xFFC0C0C0);
  static const Color leagueGold = Color(0xFFFFD700);
  static const Color leagueAmethyst = Color(0xFF9B59B6);
  static const Color leaguePearl = Color(0xFFF5F5F5);
  static const Color leagueRuby = Color(0xFFE74C3C);
  static const Color leagueEmerald = Color(0xFF27AE60);
  static const Color leagueDiamond = Color(0xFF3498DB);

  // GRADIENTS
  static const LinearGradient peacockGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [peacockDeep, peacockTeal, peacockCyan],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FFFE), Color(0xFFE8F8F5)],
  );

  static const LinearGradient courseTreeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0FFFC),
      Color(0xFFE8F8F5),
      Color(0xFFE0F5F1),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkCourseTreeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0E1C1E),
      Color(0xFF102225),
      Color(0xFF13282A),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [peacockCyan, peacockTurquoise],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successLight],
  );

  static const RadialGradient nodeGlowGradient = RadialGradient(
    colors: [
      Color(0x4046D1BF),
      Color(0x2046D1BF),
      Color(0x0046D1BF),
    ],
  );

  // SHADOWS
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: peacockTeal.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: peacockTeal.withValues(alpha: 0.1),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: peacockMint.withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: peacockTeal.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // BORDER RADIUS
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0;

  /// Keeps catalogue/course accent colors lively and legible on dark cards.
  static Color adaptiveAccent(BuildContext context, Color color) {
    if (Theme.of(context).brightness != Brightness.dark) return color;
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation(hsl.saturation < 0.62 ? 0.62 : hsl.saturation)
        .withLightness(hsl.lightness < 0.68 ? 0.68 : hsl.lightness)
        .toColor();
  }

  // MATERIAL THEME DATA
  //
  // Both are the default palette; every palette's themes come from
  // [buildAppTheme] in `theme_palette.dart`. These stay so that code and tests
  // that just want "the app's light theme" keep working.
  static ThemeData get lightTheme =>
      buildAppTheme(appPalettes.first, Brightness.light);

  static ThemeData get darkTheme =>
      buildAppTheme(appPalettes.first, Brightness.dark);
}

// LEGACY SUPPORT
const primaryColor = VarnamalaTheme.primary;

/// Used only if a widget is built under a bare [ThemeData] that carries no
/// palette, which happens in isolated widget tests.
const VarnamalaColors _fallbackColors = VarnamalaColors(
  info: Color(0xFF359CBB),
  success: Color(0xFF1F727E),
  warning: Color(0xFFFF9F43),
  danger: Color(0xFFE74C3C),
  violet: Color(0xFF9B59B6),
  shadowTint: Color(0xFF1F727E),
  coursePalette: [
    Color(0xFF1D998D),
    Color(0xFF4E8ADD),
    Color(0xFFC060E1),
  ],
  pathGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0FFFC), Color(0xFFE0F5F1)],
  ),
);

extension VarnamalaThemeContext on BuildContext {
  /// The palette's own colours, for the roles Material has no slot for.
  VarnamalaColors get appColors =>
      Theme.of(this).extension<VarnamalaColors>() ?? _fallbackColors;

  Color get appSurface => Theme.of(this).colorScheme.surface;
  Color get appElevatedSurface => Theme.of(this).colorScheme.surfaceContainer;
  Color get appBorder => Theme.of(this).colorScheme.outlineVariant;
  Color get appTextPrimary => Theme.of(this).colorScheme.onSurface;
  Color get appTextSecondary => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get appAccent => Theme.of(this).colorScheme.primary;
  Color get appInfo => appColors.info;
  Color get appSuccess => appColors.success;
  Color get appWarning => appColors.warning;
  Color get appDanger => appColors.danger;
  Color get appViolet => appColors.violet;
  Color get appShadowTint => appColors.shadowTint;
  LinearGradient get appPathGradient => appColors.pathGradient;
}
