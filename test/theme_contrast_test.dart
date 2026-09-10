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

  // A widget that picks its own fill has to pick its own foreground. The
  // regression this guards: SpeakButton filled with `appInfo` and labelled
  // with `colorScheme.onSecondary`, which measured 2.87:1 on Emerald and
  // Crimson light - a black icon on a dark blue button.
  //
  // Asserting it here rather than at each call site means `context.appOn` is
  // always a safe answer, whatever palette is added next.
  test('appOn is readable on every semantic fill in every palette', () {
    for (final palette in appPalettes) {
      for (final brightness in Brightness.values) {
        final theme = buildAppTheme(palette, brightness);
        final extras = theme.extension<VarnamalaColors>()!;
        final label = '${palette.name} (${brightness.name})';

        // These carry labels, so they answer to the body-text minimum.
        <String, Color>{
          'info': extras.info,
          'success': extras.success,
          'warning': extras.warning,
          'danger': extras.danger,
          'violet': extras.violet,
          'primary': theme.colorScheme.primary,
          'secondary': theme.colorScheme.secondary,
        }.forEach((role, fill) {
          _expectReadable(onColorFor(fill), fill, where: '$label appOn($role)');
        });

        // A course node carries one 32px glyph and nothing else. WCAG asks
        // 3:1 of a graphical object rather than the 4.5:1 it asks of body
        // text, and holding the nodes to the stricter figure would flatten
        // the palette they exist to show off.
        for (var index = 0; index < extras.coursePalette.length; index++) {
          final fill = extras.courseColor(index);
          _expectReadable(onColorFor(fill), fill,
              minimum: 3, where: '$label appOn(course $index)');
        }
      }
    }
  });

  test('palette ids are unique and stable', () {
    final ids = appPalettes.map((palette) => palette.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(appPalettes.length, greaterThanOrEqualTo(5));
    // The default must stay first: it is what existing learners already see.
    expect(appPalettes.first.id, 'peacock');
  });
}
