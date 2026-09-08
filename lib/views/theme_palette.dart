// Flutter imports:
import 'package:flutter/material.dart';

/// The app's semantic colours that Material's [ColorScheme] has no slot for.
///
/// Carried on [ThemeData.extensions] so every `context.appSuccess`-style
/// lookup resolves against the palette the learner picked, instead of being
/// hardcoded per brightness. Flutter lerps this during a theme change, so
/// switching palettes animates rather than snapping.
@immutable
class VarnamalaColors extends ThemeExtension<VarnamalaColors> {
  const VarnamalaColors({
    required this.info,
    required this.success,
    required this.warning,
    required this.danger,
    required this.violet,
    required this.shadowTint,
    required this.pathGradient,
    required this.coursePalette,
  });

  final Color info;

  /// Reserved for "you got it right". Stays in the green family in every
  /// palette so the meaning survives a change of theme.
  final Color success;
  final Color warning;

  /// Reserved for "that was wrong". Stays in the red family for the same
  /// reason as [success].
  final Color danger;
  final Color violet;

  /// Tints the soft shadows under bars and cards so they belong to the palette
  /// rather than being a grey smudge.
  final Color shadowTint;

  /// The wash behind the course path.
  final LinearGradient pathGradient;

  /// Colours for the course nodes on the path, in order.
  ///
  /// The path is the screen people actually spend their time on, so it has to
  /// belong to the palette. These are spread around the palette's own hue
  /// rather than taken from the course JSON, which is what previously left the
  /// tree stuck on the same teal no matter which theme was chosen.
  final List<Color> coursePalette;

  /// The colour for the course at [index] on the path.
  Color courseColor(int index) =>
      coursePalette[index.abs() % coursePalette.length];

  @override
  VarnamalaColors copyWith({
    Color? info,
    Color? success,
    Color? warning,
    Color? danger,
    Color? violet,
    Color? shadowTint,
    LinearGradient? pathGradient,
    List<Color>? coursePalette,
  }) =>
      VarnamalaColors(
        info: info ?? this.info,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        violet: violet ?? this.violet,
        shadowTint: shadowTint ?? this.shadowTint,
        pathGradient: pathGradient ?? this.pathGradient,
        coursePalette: coursePalette ?? this.coursePalette,
      );

  @override
  VarnamalaColors lerp(VarnamalaColors? other, double t) {
    if (other == null) return this;
    return VarnamalaColors(
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      shadowTint: Color.lerp(shadowTint, other.shadowTint, t)!,
      pathGradient: LinearGradient.lerp(pathGradient, other.pathGradient, t)!,
      coursePalette: [
        for (var i = 0; i < coursePalette.length; i++)
          Color.lerp(coursePalette[i],
              other.coursePalette[i % other.coursePalette.length], t)!,
      ],
    );
  }
}

/// A recipe for one theme, described by hue relationships rather than a list
/// of hand-picked hex codes.
///
/// Every colour the app uses is derived from these few anchors at fixed
/// lightness targets, so a new palette is a handful of numbers and the
/// contrast guarantees come along automatically (see
/// `test/theme_contrast_test.dart`, which checks every palette in both modes).
@immutable
class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryHue,
    required this.secondaryHue,
    required this.neutralHue,
    this.chroma = 1.0,
    this.neutralChroma = 1.0,
    this.infoHue = 205,
    this.warningHue = 38,
    this.violetHue = 280,
    this.successHue = 150,
    this.dangerHue = 6,
    this.highContrast = false,
  });

  /// Stored in preferences; never change one once it has shipped.
  final String id;
  final String name;
  final String description;

  final double primaryHue;
  final double secondaryHue;

  /// Hue that tints the greys, backgrounds and borders. Tinted neutrals are
  /// what make a palette read as one family rather than colours on grey.
  final double neutralHue;

  /// Overall saturation multiplier, so a palette can be muted without
  /// redefining every tone.
  final double chroma;
  final double neutralChroma;

  final double infoHue;
  final double warningHue;
  final double violetHue;
  final double successHue;
  final double dangerHue;

  /// Pushes text and borders further from the background, for learners who
  /// need more separation than a decorative palette gives.
  final bool highContrast;
}

/// True for hues that only look like themselves when they are light.
///
/// Amber, saffron and gold have their character at high lightness; dragged
/// down far enough for white text to sit on them they simply become brown.
/// Those hues stay bright and take dark text instead (see [_onColor]).
bool _isLuminousHue(double hue) {
  final h = hue % 360;
  return h >= 25 && h <= 100;
}

Color _tone(double hue, double saturation, double lightness) =>
    HSLColor.fromAHSL(
            1, hue % 360, saturation.clamp(0.0, 1.0), lightness.clamp(0.0, 1.0))
        .toColor();

/// Near-black or white, whichever actually contrasts more with [background].
///
/// Picking by measured contrast rather than a lightness threshold matters for
/// mid-tone fills like gold or violet, where a guess lands on the wrong side
/// and quietly ships unreadable text.
Color _onColor(Color background) {
  const dark = Color(0xFF0B0E12);
  final backgroundLuminance = background.computeLuminance();
  final onWhite = 1.05 / (backgroundLuminance + 0.05);
  final onDark =
      (backgroundLuminance + 0.05) / (dark.computeLuminance() + 0.05);
  return onWhite >= onDark ? Colors.white : dark;
}

/// The palettes offered in Settings.
///
/// Each one is built on a named colour relationship rather than a mood board:
/// analogous palettes (neighbouring hues) feel calm, complementary ones
/// (opposite hues) feel energetic, and the neutrals are always tinted towards
/// the primary so nothing reads as "colour sitting on grey".
///
/// The set deliberately spans warm and cool, saturated and muted, because the
/// audience is international and colour taste is not universal: a scheme that
/// reads as festive in one place reads as loud in another. For the same reason
/// no palette carries meaning on its own — `success` stays green and `danger`
/// stays red in all ten, so "right" and "wrong" never depend on which theme
/// someone happens to be using, or on telling two hues apart.
const List<AppPalette> appPalettes = [
  AppPalette(
    id: 'peacock',
    name: 'Peacock',
    description: 'Teal and cyan. The original Varnamala look.',
    // Analogous: teal into cyan.
    primaryHue: 184,
    secondaryHue: 200,
    neutralHue: 184,
  ),
  AppPalette(
    id: 'marigold',
    name: 'Marigold',
    description: 'Hot saffron and amber, cooled by a teal counterpoint.',
    // Complementary: a warm primary against its opposite.
    primaryHue: 36,
    secondaryHue: 196,
    neutralHue: 34,
  ),
  AppPalette(
    id: 'emerald',
    name: 'Emerald',
    description: 'Deep green with a gold second.',
    // Split-complementary: green with gold rather than magenta, which keeps
    // it fresh instead of clashing.
    primaryHue: 140,
    secondaryHue: 44,
    neutralHue: 144,
  ),
  AppPalette(
    id: 'amethyst',
    name: 'Amethyst',
    description: 'Electric violet running into magenta.',
    // Analogous: violet drifting towards rose.
    primaryHue: 282,
    secondaryHue: 322,
    neutralHue: 280,
  ),
  AppPalette(
    id: 'crimson',
    name: 'Crimson',
    description: 'Bold red balanced by sea green.',
    // Complementary: red against its exact opposite.
    primaryHue: 350,
    secondaryHue: 168,
    neutralHue: 350,
  ),
  AppPalette(
    id: 'high_contrast',
    name: 'High contrast',
    description: 'Maximum separation for text and borders.',
    // Not a taste option, which is why it survived the cull: this one is for
    // low vision, glare, and cheap screens. One strong hue, near-neutral
    // surfaces, and text pushed to the ends of the range.
    primaryHue: 220,
    secondaryHue: 205,
    neutralHue: 220,
    neutralChroma: 0.35,
    highContrast: true,
  ),
];

AppPalette paletteById(String id) => appPalettes.firstWhere(
      (palette) => palette.id == id,
      orElse: () => appPalettes.first,
    );

/// Border radii, shared by every palette.
abstract final class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xLarge = 24.0;
  static const double round = 100.0;
}

TextTheme _textTheme(Color primary, Color secondary, Color hint) => TextTheme(
      displayLarge: TextStyle(color: primary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: primary, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: primary, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: primary, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: primary, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: primary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: primary),
      bodyMedium: TextStyle(color: secondary),
      bodySmall: TextStyle(color: hint),
      labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: secondary),
      labelSmall: TextStyle(color: hint),
    );

/// Builds the full theme for one palette in one brightness.
ThemeData buildAppTheme(AppPalette palette, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final c = palette.chroma;
  final nc = palette.neutralChroma;
  final hc = palette.highContrast;

  // Accent hues are shared machinery; only their tone changes with brightness.
  // Light-mode accents sit darker than the palette's own colours because they
  // are small marks - icons and labels - on a near-white card, and amber and
  // green have to be dragged well down to clear 3:1 there. The big surfaces
  // below carry the palette's brightness instead.
  Color accent(double hue) => isDark
      ? _tone(hue, 0.80 * c, 0.68)
      : _tone(hue, 0.85 * c, _isLuminousHue(hue) ? 0.38 : 0.325);

  final Color primary = isDark
      ? _tone(palette.primaryHue, 0.82 * c, 0.66)
      : _tone(palette.primaryHue, 0.85 * c,
          _isLuminousHue(palette.primaryHue) ? 0.52 : 0.335);
  final Color secondary = isDark
      ? _tone(palette.secondaryHue, 0.78 * c, 0.68)
      : _tone(palette.secondaryHue, 0.80 * c,
          _isLuminousHue(palette.secondaryHue) ? 0.52 : 0.345);
  final Color tertiary = accent(palette.violetHue);

  final Color primaryContainer = isDark
      ? _tone(palette.primaryHue, 0.55 * c, 0.24)
      : _tone(palette.primaryHue, 0.72 * c, 0.88);
  final Color secondaryContainer = isDark
      ? _tone(palette.secondaryHue, 0.52 * c, 0.24)
      : _tone(palette.secondaryHue, 0.70 * c, 0.88);
  final Color tertiaryContainer = isDark
      ? _tone(palette.violetHue, 0.52 * c, 0.24)
      : _tone(palette.violetHue, 0.70 * c, 0.89);

  final Color danger = accent(palette.dangerHue);
  final Color dangerContainer = isDark
      ? _tone(palette.dangerHue, 0.42, 0.24)
      : _tone(palette.dangerHue, 0.48, 0.92);

  // Surfaces carry a trace of the primary hue, which is what stops a palette
  // from looking like colour dropped onto grey.
  final Color surface = isDark
      ? _tone(palette.neutralHue, 0.34 * nc, 0.115)
      : _tone(palette.neutralHue, 0.55 * nc, 0.99);
  final Color scaffold = isDark
      ? _tone(palette.neutralHue, 0.38 * nc, 0.07)
      : _tone(palette.neutralHue, 0.72 * nc, 0.965);
  final Color elevated = isDark
      ? _tone(palette.neutralHue, 0.30 * nc, 0.165)
      : _tone(palette.neutralHue, 0.50 * nc, 0.95);

  final Color onSurface = isDark
      ? _tone(palette.neutralHue, 0.10 * nc, hc ? 0.99 : 0.95)
      : _tone(palette.neutralHue, 0.28 * nc, hc ? 0.06 : 0.14);
  final Color onSurfaceVariant = isDark
      ? _tone(palette.neutralHue, 0.10 * nc, hc ? 0.88 : 0.76)
      : _tone(palette.neutralHue, 0.16 * nc, hc ? 0.24 : 0.36);
  final Color hint = isDark
      ? _tone(palette.neutralHue, 0.09 * nc, hc ? 0.78 : 0.64)
      : _tone(palette.neutralHue, 0.12 * nc, hc ? 0.34 : 0.48);

  final Color outlineVariant = isDark
      ? _tone(palette.neutralHue, 0.14 * nc, hc ? 0.48 : 0.30)
      : _tone(palette.neutralHue, 0.20 * nc, hc ? 0.68 : 0.87);
  final Color outline = isDark
      ? _tone(palette.neutralHue, 0.12 * nc, hc ? 0.62 : 0.44)
      : _tone(palette.neutralHue, 0.16 * nc, hc ? 0.44 : 0.62);

  final Color onContainer = isDark
      ? _tone(palette.neutralHue, 0.12, 0.92)
      : _tone(palette.neutralHue, 0.45, 0.16);

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: _onColor(primary),
    primaryContainer: primaryContainer,
    onPrimaryContainer: onContainer,
    secondary: secondary,
    onSecondary: _onColor(secondary),
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onContainer,
    tertiary: tertiary,
    onTertiary: _onColor(tertiary),
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onContainer,
    error: danger,
    onError: _onColor(danger),
    errorContainer: dangerContainer,
    onErrorContainer: onContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainer: elevated,
    surfaceContainerHighest: elevated,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
  );

  // Course nodes fan out around the palette's own hue. The golden-angle step
  // keeps neighbouring courses clearly different without any of them wandering
  // out of the family, so the whole path reads as one theme.
  const courseCount = 12;
  // Asymmetric on purpose: a span centred on the primary reaches equally far
  // into the hues on either side, which is how Marigold ended up with magenta
  // nodes. Leaning the window forwards keeps every node inside the palette's
  // own family while still separating neighbours.
  const span = 100.0;
  const skew = -32.0;
  final coursePalette = [
    for (var i = 0; i < courseCount; i++)
      () {
        final t = (i * 0.6180339887) % 1.0;
        final hue = palette.primaryHue + skew + t * span;
        return isDark
            ? _tone(hue, 0.78 * c, 0.64)
            : _tone(hue, 0.82 * c, _isLuminousHue(hue) ? 0.50 : 0.42);
      }(),
  ];

  final extras = VarnamalaColors(
    info: accent(palette.infoHue),
    success: accent(palette.successHue),
    warning: accent(palette.warningHue),
    danger: danger,
    violet: accent(palette.violetHue),
    shadowTint: primary,
    pathGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              _tone(palette.neutralHue, 0.24 * nc, 0.085),
              _tone(palette.neutralHue, 0.24 * nc, 0.10),
              _tone(palette.neutralHue, 0.24 * nc, 0.118),
            ]
          : [
              _tone(palette.neutralHue, 0.40 * nc, 0.985),
              _tone(palette.neutralHue, 0.42 * nc, 0.968),
              _tone(palette.neutralHue, 0.44 * nc, 0.952),
            ],
      stops: const [0.0, 0.5, 1.0],
    ),
    coursePalette: coursePalette,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    primaryColor: primary,
    scaffoldBackgroundColor: scaffold,
    colorScheme: colorScheme,
    extensions: [extras],
    textTheme: _textTheme(onSurface, onSurfaceVariant, hint),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: surface,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: primary),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: _onColor(primary),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: elevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(color: outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(color: danger, width: 2),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: outlineVariant,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: _onColor(primary),
      elevation: 4,
    ),
    dividerTheme: DividerThemeData(color: outlineVariant, thickness: 1),
    // The default desktop scrollbar is a hard grey slab. This one is a slim
    // rounded thumb in the palette's own ink, inset from the edge, that grows
    // and darkens under the pointer.
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.dragged),
      ),
      thickness: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.dragged)
            ? 9
            : 5,
      ),
      radius: const Radius.circular(AppRadius.round),
      crossAxisMargin: 3,
      mainAxisMargin: 6,
      interactive: true,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.dragged)) {
          return primary.withValues(alpha: 0.75);
        }
        if (states.contains(WidgetState.hovered)) {
          return primary.withValues(alpha: 0.55);
        }
        return onSurfaceVariant.withValues(alpha: 0.28);
      }),
      trackColor: const WidgetStatePropertyAll(Colors.transparent),
      trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: elevated,
      contentTextStyle:
          TextStyle(inherit: false, color: onSurface, fontSize: 14),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: elevated,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: outlineVariant),
      ),
      textStyle: TextStyle(
        inherit: false,
        color: onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      waitDuration: const Duration(milliseconds: 650),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: elevated,
      selectedColor: primaryContainer,
      labelStyle: TextStyle(inherit: false, color: onSurface, fontSize: 14),
      secondaryLabelStyle:
          TextStyle(inherit: false, color: onContainer, fontSize: 14),
      side: BorderSide(color: outlineVariant),
      iconTheme: IconThemeData(color: extras.info),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: extras.info,
      textColor: onSurface,
      titleTextStyle: TextStyle(inherit: false, color: onSurface, fontSize: 16),
      subtitleTextStyle:
          TextStyle(inherit: false, color: onSurfaceVariant, fontSize: 14),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: 0.35),
      selectionHandleColor: primary,
    ),
  );
}
