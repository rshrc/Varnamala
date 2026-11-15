import 'dart:ui';

const kathaNightSky = Color(0xFF1C2A44);

const kathaLampLight = Color(0xFFFFD27A);

const kathaFlameCore = Color(0xFFFFF2C4);

// =============================================================================
// The terrace
// =============================================================================

/// The Katha art palette: five colours plus paper, from `01-VISION.md` §10.
///
/// These colours belong to the *drawing* and are fixed the way pixels in a
/// picture are fixed, so they are not theme roles. The reader around the
/// picture - text, buttons, the spotlight band - takes its colours from the
/// app theme like every other screen.
abstract final class KathaInk {
  static const paper = Color(0xFFF6F1E7);
  static const ink = Color(0xFF22262A);
  static const teal = Color(0xFF1F727E);
  static const marigold = Color(0xFFE8A33D);
  static const brick = Color(0xFFB5523B);
  static const leaf = Color(0xFF6E8B4E);

  // The Nagara kit's additions. Skin is the one thing the five colours cannot
  // supply; everything else here is a mix of the palette with paper or ink.
  static const skinWarm = Color(0xFFC68A5E);
  static const skinDeep = Color(0xFF8E5B3C);

  static final khaki = Color.lerp(marigold, paper, 0.42)!;
  static final khakiShade = Color.lerp(khaki, ink, 0.18)!;
  static final denim = Color.lerp(ink, teal, 0.3)!;
  static final skyline = Color.lerp(paper, teal, 0.2)!;
  static final skylineWindow = Color.lerp(paper, teal, 0.08)!;
  static final footpath = Color.lerp(paper, ink, 0.1)!;
  static final road = Color.lerp(ink, paper, 0.14)!;
  static final shopWall = Color.lerp(paper, brick, 0.5)!;
  static final shutter = Color.lerp(paper, ink, 0.22)!;
  static final interior = Color.lerp(ink, paper, 0.28)!;
  static final windshield = Color.lerp(teal, paper, 0.55)!;
  static final marigoldShade = Color.lerp(marigold, ink, 0.2)!;
  static final brickShade = Color.lerp(brick, ink, 0.25)!;
  static final leafShade = Color.lerp(leaf, ink, 0.3)!;
}

/// The scene's fixed drawing space. The camera scales it to whatever room the
/// reader gives the picture, so art is authored once at this size.
const double kathaWorldWidth = 400;

const double kathaWorldHeight = 260;

const kathaDawnPink = Color(0xFFF2C6B0);

const kathaDawnGold = Color(0xFFF6DDA8);
