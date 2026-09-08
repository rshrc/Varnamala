import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:words625/views/theme.dart';

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void _expectReadable(
  Color foreground,
  Color background, {
  double minimum = 4.5,
  String where = '',
}) {
  expect(
    _contrastRatio(foreground, background),
    greaterThanOrEqualTo(minimum),
    reason: '$where: ${foreground.toARGB32().toRadixString(16)} on '
        '${background.toARGB32().toRadixString(16)} is below $minimum:1',
  );
}

void main() {
  // Every palette is generated from hue anchors rather than hand-picked, so
  // the guarantee that they are all legible has to come from here.
  for (final palette in appPalettes) {
    for (final brightness in Brightness.values) {
      final label = '${palette.name} (${brightness.name})';
      final theme = buildAppTheme(palette, brightness);
      final scheme = theme.colorScheme;
      final extras = theme.extension<VarnamalaColors>()!;

      group(label, () {
        test('text and component roles are readable', () {
          _expectReadable(scheme.onSurface, scheme.surface, where: label);
          _expectReadable(scheme.onSurfaceVariant, scheme.surface,
              where: label);
          _expectReadable(scheme.onSurface, theme.scaffoldBackgroundColor,
              where: label);
          _expectReadable(scheme.onPrimary, scheme.primary, where: label);
          _expectReadable(scheme.onPrimaryContainer, scheme.primaryContainer,
              where: label);
          _expectReadable(scheme.onSecondary, scheme.secondary, where: label);
          _expectReadable(
              scheme.onSecondaryContainer, scheme.secondaryContainer,
              where: label);
          _expectReadable(scheme.onTertiary, scheme.tertiary, where: label);
          _expectReadable(scheme.onTertiaryContainer, scheme.tertiaryContainer,
              where: label);
          _expectReadable(scheme.onError, scheme.error, where: label);
          _expectReadable(scheme.onErrorContainer, scheme.errorContainer,
              where: label);
        });

        test('semantic accents stand out from cards', () {
          for (final accent in [
            extras.info,
            extras.success,
            extras.warning,
            extras.danger,
            extras.violet,
          ]) {
            _expectReadable(accent, scheme.surface, minimum: 3, where: label);
            _expectReadable(accent, theme.scaffoldBackgroundColor,
                minimum: 3, where: label);
          }
        });

        test('borders separate from the surfaces they divide', () {
          _expectReadable(scheme.outlineVariant, scheme.surface,
              minimum: 1.2, where: label);
        });

        test('right and wrong never rely on hue alone', () {
          // Around 1 in 12 men cannot separate red from green by hue. The two
          // feedback colours must therefore also differ in lightness, so the
          // verdict survives colour blindness and a bad screen.
          final gap = (extras.success.computeLuminance() -
                  extras.danger.computeLuminance())
              .abs();
          expect(gap, greaterThan(0.06),
              reason: '$label: success and danger are too close in lightness');
          // And they must stay in their own hue families, so a change of
          // palette never turns "correct" red.
          final success = HSLColor.fromColor(extras.success).hue;
          final danger = HSLColor.fromColor(extras.danger).hue;
          expect(success, inInclusiveRange(90, 190), reason: '$label success');
          expect(danger < 25 || danger > 340, isTrue, reason: '$label danger');
        });
      });
    }
  }

  test('palette ids are unique and stable', () {
    final ids = appPalettes.map((palette) => palette.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(appPalettes.length, greaterThanOrEqualTo(5));
    // The default must stay first: it is what existing learners already see.
    expect(appPalettes.first.id, 'peacock');
  });
}
