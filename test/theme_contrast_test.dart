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
}) {
  expect(
    _contrastRatio(foreground, background),
    greaterThanOrEqualTo(minimum),
    reason: '${foreground.toARGB32().toRadixString(16)} on '
        '${background.toARGB32().toRadixString(16)} is below $minimum:1',
  );
}

void main() {
  final scheme = VarnamalaTheme.darkTheme.colorScheme;

  test('dark theme text and component roles remain readable', () {
    _expectReadable(scheme.onSurface, scheme.surface);
    _expectReadable(scheme.onSurfaceVariant, scheme.surface);
    _expectReadable(scheme.onPrimary, scheme.primary);
    _expectReadable(scheme.onPrimaryContainer, scheme.primaryContainer);
    _expectReadable(scheme.onSecondary, scheme.secondary);
    _expectReadable(scheme.onSecondaryContainer, scheme.secondaryContainer);
    _expectReadable(scheme.onTertiary, scheme.tertiary);
    _expectReadable(scheme.onTertiaryContainer, scheme.tertiaryContainer);
    _expectReadable(scheme.onError, scheme.error);
    _expectReadable(scheme.onErrorContainer, scheme.errorContainer);
  });

  test('dark theme semantic icon colors stand out from cards', () {
    for (final accent in [
      VarnamalaTheme.darkMint,
      VarnamalaTheme.darkSky,
      VarnamalaTheme.darkGold,
      VarnamalaTheme.darkCoral,
      VarnamalaTheme.darkViolet,
    ]) {
      _expectReadable(accent, scheme.surface, minimum: 3);
    }
  });
}
