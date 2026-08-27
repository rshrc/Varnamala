// Flutter imports:
import 'package:flutter/material.dart';

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
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primary,
        scaffoldBackgroundColor: scaffoldBackground,
        colorScheme: const ColorScheme.light(
          primary: primary,
          primaryContainer: primaryLight,
          secondary: secondary,
          secondaryContainer: secondaryLight,
          surface: surface,
          error: error,
          onPrimary: textOnPrimary,
          onSecondary: textOnSecondary,
          onSurface: textPrimary,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: textPrimary,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: peacockTeal),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textOnPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F8F7),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: error, width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: peacockTeal,
          unselectedItemColor: textHint,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: peacockTurquoise,
          linearTrackColor: Color(0xFFE0E0E0),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: peacockTurquoise,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEEF2F1),
          thickness: 1,
        ),
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(
            inherit: false,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        tooltipTheme: const TooltipThemeData(
          textStyle: TextStyle(
            inherit: false,
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          waitDuration: Duration(milliseconds: 650),
        ),
        chipTheme: const ChipThemeData(
          labelStyle: TextStyle(
            inherit: false,
            color: textPrimary,
            fontSize: 14,
          ),
          secondaryLabelStyle: TextStyle(
            inherit: false,
            color: textPrimary,
            fontSize: 14,
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: peacockTeal,
          textColor: textPrimary,
          titleTextStyle: TextStyle(
            inherit: false,
            color: textPrimary,
            fontSize: 16,
          ),
          subtitleTextStyle: TextStyle(
            inherit: false,
            color: textSecondary,
            fontSize: 14,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          displayMedium:
              TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          displaySmall:
              TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          headlineLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineMedium:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineSmall:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          titleSmall:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textHint),
          labelLarge:
              TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: textSecondary),
          labelSmall: TextStyle(color: textHint),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: darkMint,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: darkMint,
          onPrimary: Color(0xFF003733),
          primaryContainer: Color(0xFF165A5F),
          onPrimaryContainer: Color(0xFFE5FFFB),
          secondary: darkSky,
          onSecondary: Color(0xFF002F48),
          secondaryContainer: Color(0xFF16486A),
          onSecondaryContainer: Color(0xFFE8F6FF),
          tertiary: darkGold,
          onTertiary: Color(0xFF3C2B00),
          tertiaryContainer: Color(0xFF5A4312),
          onTertiaryContainer: Color(0xFFFFF5D6),
          surface: darkSurface,
          onSurface: darkTextPrimary,
          surfaceContainerLowest: darkBackground,
          surfaceContainerLow: Color(0xFF102326),
          surfaceContainer: darkElevatedSurface,
          surfaceContainerHigh: Color(0xFF233D42),
          surfaceContainerHighest: Color(0xFF2A484D),
          onSurfaceVariant: darkTextSecondary,
          error: darkCoral,
          onError: Color(0xFF4B0808),
          errorContainer: Color(0xFF682522),
          onErrorContainer: Color(0xFFFFE4E1),
          outline: Color(0xFF6A8783),
          outlineVariant: Color(0xFF3B5957),
          inverseSurface: darkTextPrimary,
          onInverseSurface: Color(0xFF17302F),
          inversePrimary: primaryDark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: darkSurface,
          foregroundColor: darkTextPrimary,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: darkTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: darkMint),
        ),
        iconTheme: const IconThemeData(color: darkSky),
        primaryIconTheme: const IconThemeData(color: darkMint),
        cardTheme: CardThemeData(
          elevation: 0,
          color: darkSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkMint,
            foregroundColor: const Color(0xFF003733),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkMint,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: darkMint,
            side: const BorderSide(color: darkMint, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkElevatedSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: Color(0xFF263B3D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: darkMint, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: errorLight, width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkSurface,
          selectedItemColor: darkMint,
          unselectedItemColor: darkTextSecondary,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: darkMint,
          linearTrackColor: Color(0xFF3B5957),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: darkMint,
          foregroundColor: Color(0xFF003733),
          elevation: 4,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF3B5957),
          thickness: 1,
        ),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
          displayMedium:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
          displaySmall:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
          headlineLarge:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
          headlineMedium:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
          headlineSmall:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
          titleLarge:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
          titleSmall:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: darkTextPrimary),
          bodyMedium: TextStyle(color: darkTextSecondary),
          bodySmall: TextStyle(color: darkTextHint),
          labelLarge:
              TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: darkTextSecondary),
          labelSmall: TextStyle(color: darkTextHint),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: darkElevatedSurface,
          contentTextStyle: TextStyle(
            inherit: false,
            color: darkTextPrimary,
            fontSize: 14,
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: darkSurface,
          surfaceTintColor: Colors.transparent,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: darkSurface,
          surfaceTintColor: Colors.transparent,
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(0xFF2A484D),
            borderRadius: BorderRadius.circular(radiusSmall),
            border: Border.all(color: const Color(0xFF6A8783)),
          ),
          textStyle: const TextStyle(
            inherit: false,
            color: darkTextPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          waitDuration: const Duration(milliseconds: 650),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: darkElevatedSurface,
          selectedColor: Color(0xFF165A5F),
          disabledColor: Color(0xFF233D42),
          labelStyle: TextStyle(
            inherit: false,
            color: darkTextPrimary,
            fontSize: 14,
          ),
          secondaryLabelStyle: TextStyle(
            inherit: false,
            color: Color(0xFFE5FFFB),
            fontSize: 14,
          ),
          side: BorderSide(color: Color(0xFF3B5957)),
          iconTheme: IconThemeData(color: darkSky),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: darkSky,
          textColor: darkTextPrimary,
          titleTextStyle: TextStyle(
            inherit: false,
            color: darkTextPrimary,
            fontSize: 16,
          ),
          subtitleTextStyle: TextStyle(
            inherit: false,
            color: darkTextSecondary,
            fontSize: 14,
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: darkMint,
          selectionColor: Color(0x6639CDBA),
          selectionHandleColor: darkMint,
        ),
      );
}

// LEGACY SUPPORT
const primaryColor = VarnamalaTheme.primary;

extension VarnamalaThemeContext on BuildContext {
  Color get appSurface => Theme.of(this).colorScheme.surface;
  Color get appElevatedSurface => Theme.of(this).colorScheme.surfaceContainer;
  Color get appBorder => Theme.of(this).colorScheme.outlineVariant;
  Color get appTextPrimary => Theme.of(this).colorScheme.onSurface;
  Color get appTextSecondary => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get appAccent => Theme.of(this).colorScheme.primary;
  Color get appInfo => Theme.of(this).brightness == Brightness.dark
      ? VarnamalaTheme.darkSky
      : VarnamalaTheme.peacockCyan;
  Color get appSuccess => Theme.of(this).brightness == Brightness.dark
      ? VarnamalaTheme.darkMint
      : VarnamalaTheme.peacockTeal;
  Color get appWarning => Theme.of(this).brightness == Brightness.dark
      ? VarnamalaTheme.darkGold
      : VarnamalaTheme.warning;
  Color get appDanger => Theme.of(this).brightness == Brightness.dark
      ? VarnamalaTheme.darkCoral
      : VarnamalaTheme.error;
  Color get appViolet => Theme.of(this).brightness == Brightness.dark
      ? VarnamalaTheme.darkViolet
      : VarnamalaTheme.leagueAmethyst;
}
