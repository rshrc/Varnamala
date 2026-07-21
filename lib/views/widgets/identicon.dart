// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/core/identity.dart';

/// A GitHub-style identicon: a 5x5 grid, mirrored down the middle, derived
/// entirely from a seed string.
///
/// Drawn rather than fetched, so a learner's avatar never involves a request to
/// Google's photo CDN — which would leak both their account and their IP to a
/// third party every time someone opened the leaderboard.
class Identicon extends StatelessWidget {
  const Identicon({
    super.key,
    required this.seed,
    this.size = 44,
  });

  /// Anything stable and per-user — the handle, or the user id.
  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: CustomPaint(
        size: Size.square(size),
        painter: _IdenticonPainter(identiconSeed(seed)),
      ),
    );
  }
}

class _IdenticonPainter extends CustomPainter {
  _IdenticonPainter(this.seed);

  final int seed;

  static const int _grid = 5;
  static const int _half = 3; // columns 0..2 are drawn, 3..4 are mirrored

  @override
  void paint(Canvas canvas, Size size) {
    // Hue from the seed, but fixed saturation and lightness so every avatar
    // sits at the same visual weight — the same reasoning as the course
    // palette. Nobody's avatar glares next to anyone else's.
    final hue = (seed % 360).toDouble();
    final foreground = HSLColor.fromAHSL(1, hue, 0.55, 0.48).toColor();
    final background = HSLColor.fromAHSL(1, hue, 0.32, 0.94).toColor();

    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final cell = Size(size.width / _grid, size.height / _grid);
    final paint = Paint()..color = foreground;

    for (var column = 0; column < _half; column++) {
      for (var row = 0; row < _grid; row++) {
        // One bit per cell of the left half, taken from the seed.
        final bit = (seed >> ((column * _grid + row) % 30)) & 1;
        if (bit == 0) continue;

        for (final x in {column, _grid - 1 - column}) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * cell.width,
              row * cell.height,
              cell.width + 0.5, // overlap a hair to avoid seams
              cell.height + 0.5,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_IdenticonPainter old) => old.seed != seed;
}
