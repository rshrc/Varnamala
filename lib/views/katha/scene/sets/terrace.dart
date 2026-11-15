import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// `bg.terrace`: the room on the roof. A shed with a blue door, the black
/// water tank every Bengaluru roof wears, washing on a line, and over the
/// parapet the city: cranes, towers, and a metro line that stops in mid-air.
class TerraceBackdrop extends PositionComponent {
  TerraceBackdrop({this.night = false}) : super(priority: -10);

  final bool night;

  late final Picture _picture = recordPicture(_paint);

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  void _paint(Canvas canvas) {
    // Sky.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      fillOf(
        night
            ? kathaNightSky
            : Color.lerp(KathaInk.paper, KathaInk.teal, 0.16)!,
      ),
    );
    if (night) {
      final star = fillOf(kathaFlameCore.withValues(alpha: 0.85));
      for (var i = 0; i < 22; i++) {
        canvas.drawCircle(
          Offset((i * 83 % 400).toDouble(), (i * 37 % 90).toDouble() + 6),
          i % 3 == 0 ? 1.2 : 0.8,
          star,
        );
      }
      canvas.drawCircle(const Offset(330, 34), 12, fillOf(kathaFlameCore));
      canvas.drawCircle(const Offset(336, 30), 11, fillOf(kathaNightSky));
    } else {
      // A haze along the horizon: dust from everything being built.
      canvas.drawRect(
        const Rect.fromLTRB(0, 96, kathaWorldWidth, 150),
        fillOf(Color.lerp(KathaInk.paper, KathaInk.marigold, 0.18)!),
      );
    }

    _skyline(canvas);
    _metro(canvas);
    _crane(canvas, 236, 30);

    // The neta's hoarding, far off, small, and lit even now.
    const board = Rect.fromLTRB(296, 90, 326, 108);
    canvas.drawRect(
      const Rect.fromLTRB(309.5, 108, 312.5, 150),
      fillOf(KathaInk.ink.withValues(alpha: 0.5)),
    );
    canvas.drawRect(board, fillOf(night ? kathaLampLight : KathaInk.paper));
    canvas.drawCircle(
      const Offset(306, 99),
      4.4,
      fillOf(Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.35)!),
    );
    canvas.drawArc(
      const Rect.fromLTRB(300, 99, 312, 107),
      0,
      math.pi,
      false,
      strokeOf(KathaInk.marigold, 1.6),
    );

    // The parapet: the wall the city is seen over.
    final parapet = Color.lerp(
      KathaInk.paper,
      KathaInk.ink,
      night ? 0.5 : 0.12,
    )!;
    canvas.drawRect(
      const Rect.fromLTRB(0, 150, kathaWorldWidth, 196),
      fillOf(parapet),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 146, kathaWorldWidth, 152),
      fillOf(Color.lerp(parapet, KathaInk.paper, 0.4)!),
    );
    // Monsoon streaks down the plaster.
    final streak = fillOf(KathaInk.ink.withValues(alpha: night ? 0.12 : 0.07));
    for (final x in [128.0, 204.0, 268.0, 352.0]) {
      canvas.drawRect(Rect.fromLTWH(x, 152, 5, 30 + x % 13), streak);
    }

    // The roof itself: cement, a drain, a chipped edge.
    canvas.drawRect(
      const Rect.fromLTRB(0, 196, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, night ? 0.55 : 0.2)!),
    );
    final seam = strokeOf(KathaInk.ink.withValues(alpha: 0.12), 1);
    for (var x = 30.0; x < 400; x += 64) {
      canvas.drawLine(Offset(x, 198), Offset(x - 18, 260), seam);
    }

    _shed(canvas);
    _tank(canvas);
    _washingLine(canvas);
    // Plants in paint buckets: the landlady's roof garden.
    for (final (x, color) in [
      (296.0, KathaInk.brick),
      (318.0, KathaInk.teal),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(x - 8, 180)
          ..lineTo(x + 8, 180)
          ..lineTo(x + 6, 198)
          ..lineTo(x - 6, 198)
          ..close(),
        fillOf(color),
      );
      for (var i = 0; i < 5; i++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x - 6 + i * 3.0, 172 - (i % 2) * 4.0),
            width: 6,
            height: 11,
          ),
          fillOf(night ? KathaInk.leafShade : KathaInk.leaf),
        );
      }
    }

    if (night) {
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
        fillOf(kathaNightSky.withValues(alpha: 0.18)),
      );
    }
  }

  void _skyline(Canvas canvas) {
    final tower = fillOf(
      night
          ? Color.lerp(kathaNightSky, KathaInk.ink, 0.4)!
          : Color.lerp(KathaInk.paper, KathaInk.teal, 0.3)!,
    );
    final window = fillOf(night ? kathaLampLight : KathaInk.skylineWindow);
    for (final (l, t, w) in [
      (0.0, 104.0, 30.0),
      (34.0, 86.0, 26.0),
      (64.0, 112.0, 40.0),
      (110.0, 70.0, 28.0),
      (190.0, 92.0, 34.0),
      (270.0, 80.0, 30.0),
      (306.0, 108.0, 44.0),
      (356.0, 74.0, 26.0),
      (384.0, 98.0, 16.0),
    ]) {
      canvas.drawRect(Rect.fromLTRB(l, t, l + w, 150), tower);
      for (var y = t + 6; y < 144; y += 9) {
        for (var x = l + 4; x < l + w - 4; x += 7) {
          if (((x * 7 + y * 3) ~/ 1) % (night ? 3 : 2) == 0) {
            canvas.drawRect(Rect.fromLTWH(x, y, 3, 4), window);
          }
        }
      }
    }
    // One tower still a concrete frame, a blue tarp flapping on it.
    final frame = strokeOf(
      night
          ? Color.lerp(kathaNightSky, KathaInk.paper, 0.3)!
          : KathaInk.shutter,
      1.6,
    );
    for (var y = 62.0; y <= 150; y += 14) {
      canvas.drawLine(Offset(140, y), Offset(178, y), frame);
    }
    for (final x in [140.0, 159.0, 178.0]) {
      canvas.drawLine(Offset(x, 62), Offset(x, 150), frame);
    }
    canvas.drawRect(
      const Rect.fromLTRB(142, 92, 160, 116),
      fillOf(KathaInk.teal.withValues(alpha: night ? 0.5 : 0.75)),
    );
  }

  /// The metro: four pillars, a deck on two of them, and then nothing.
  void _metro(Canvas canvas) {
    final concrete = fillOf(
      night
          ? Color.lerp(kathaNightSky, KathaInk.paper, 0.35)!
          : Color.lerp(KathaInk.paper, KathaInk.ink, 0.28)!,
    );
    for (final x in [206.0, 262.0, 318.0, 374.0]) {
      canvas.drawRect(Rect.fromLTRB(x - 4, 124, x + 4, 150), concrete);
      canvas.drawRect(Rect.fromLTRB(x - 9, 120, x + 9, 126), concrete);
    }
    canvas.drawRect(const Rect.fromLTRB(196, 113, 290, 121), concrete);
    // Rods sticking out of the end, waiting for the rest of it.
    final rod = strokeOf(
      night ? KathaInk.paper.withValues(alpha: 0.4) : KathaInk.brickShade,
      0.9,
    );
    for (final y in [114.0, 117.0, 120.0]) {
      canvas.drawLine(Offset(290, y), Offset(297, y - 1), rod);
    }
  }

  /// A tower crane, standing over the skyline. Its jib is drawn by [Crane]
  /// so that it can swing.
  void _crane(Canvas canvas, double x, double top) {
    final steel = strokeOf(
      night
          ? Color.lerp(kathaNightSky, KathaInk.marigold, 0.45)!
          : KathaInk.marigoldShade,
      1.4,
    );
    canvas.drawLine(Offset(x - 3, top), Offset(x - 3, 150), steel);
    canvas.drawLine(Offset(x + 3, top), Offset(x + 3, 150), steel);
    for (var y = top; y < 150; y += 8) {
      canvas.drawLine(
        Offset(x - 3, y),
        Offset(x + 3, y + 8),
        steel..strokeWidth = 0.8,
      );
    }
  }

  void _shed(Canvas canvas) {
    // The "room": four walls and a tin roof, pressed against the stairs.
    final wall = Color.lerp(
      KathaInk.paper,
      KathaInk.marigold,
      night ? 0.1 : 0.32,
    )!;
    final shade = night ? 0.45 : 0.0;
    canvas.drawRect(
      const Rect.fromLTRB(0, 92, 96, 200),
      fillOf(Color.lerp(wall, KathaInk.ink, shade)!),
    );
    final roof = Path()
      ..moveTo(-6, 96)
      ..lineTo(104, 86)
      ..lineTo(104, 92)
      ..lineTo(-6, 102)
      ..close();
    canvas.drawPath(
      roof,
      fillOf(Color.lerp(KathaInk.shutter, KathaInk.ink, shade)!),
    );
    for (var x = 4.0; x < 104; x += 8) {
      canvas.drawLine(
        Offset(x, 101 - x * 0.09),
        Offset(x, 95 - x * 0.09),
        strokeOf(KathaInk.ink.withValues(alpha: 0.25), 0.8),
      );
    }
    // A blue door, and light under it at night.
    canvas.drawRect(
      const Rect.fromLTRB(28, 122, 66, 200),
      fillOf(Color.lerp(KathaInk.teal, KathaInk.ink, night ? 0.45 : 0.1)!),
    );
    canvas.drawCircle(const Offset(60, 164), 1.8, fillOf(KathaInk.marigold));
    if (night) {
      canvas.drawRect(
        const Rect.fromLTRB(28, 197, 66, 200),
        fillOf(kathaLampLight),
      );
    }
    // A dish antenna on the roof, pointed at nothing in particular.
    canvas.drawLine(
      const Offset(80, 88),
      const Offset(80, 74),
      strokeOf(KathaInk.ink, 1.4),
    );
    canvas.drawArc(
      const Rect.fromLTRB(68, 60, 92, 82),
      math.pi * 0.6,
      math.pi,
      true,
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, night ? 0.5 : 0.08)!),
    );
  }

  void _tank(Canvas canvas) {
    final stand = strokeOf(KathaInk.ink.withValues(alpha: 0.7), 2);
    canvas.drawLine(const Offset(336, 120), const Offset(332, 198), stand);
    canvas.drawLine(const Offset(380, 120), const Offset(384, 198), stand);
    canvas.drawLine(const Offset(334, 160), const Offset(382, 160), stand);
    // The black tank, ridged, with its lid on.
    final body = RRect.fromLTRBR(326, 74, 390, 122, const Radius.circular(10));
    canvas.drawRRect(
      body,
      fillOf(Color.lerp(KathaInk.ink, kathaNightSky, night ? 0.3 : 0)!),
    );
    for (final y in [86.0, 98.0, 110.0]) {
      canvas.drawLine(
        Offset(328, y),
        Offset(388, y),
        strokeOf(KathaInk.paper.withValues(alpha: 0.12), 1.4),
      );
    }
    canvas.drawRRect(
      RRect.fromLTRBR(348, 68, 368, 76, const Radius.circular(3)),
      fillOf(KathaInk.ink),
    );
    // The overflow pipe, and the stain it has left down the wall.
    canvas.drawLine(
      const Offset(390, 92),
      const Offset(398, 92),
      strokeOf(KathaInk.shutter, 2),
    );
  }

  void _washingLine(Canvas canvas) {
    final rope = strokeOf(KathaInk.ink.withValues(alpha: 0.55), 0.9);
    canvas.drawLine(const Offset(96, 118), const Offset(326, 108), rope);
    // A lungi, a shirt, a towel: someone's whole week.
    final pieces = [
      (120.0, 30.0, 40.0, KathaInk.leaf),
      (164.0, 20.0, 26.0, KathaInk.marigold),
      (196.0, 24.0, 34.0, KathaInk.brick),
      (262.0, 18.0, 22.0, KathaInk.teal),
    ];
    for (final (x, w, h, color) in pieces) {
      final y = 118 - (x - 96) * 10 / 230;
      final cloth = Color.lerp(color, KathaInk.ink, night ? 0.45 : 0)!;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), fillOf(cloth));
      canvas.drawRect(
        Rect.fromLTWH(x, y + h - 4, w, 4),
        fillOf(Color.lerp(cloth, KathaInk.ink, 0.2)!),
      );
      for (final px in [x + 3, x + w - 3]) {
        canvas.drawRect(
          Rect.fromLTWH(px - 1, y - 2, 2, 5),
          fillOf(KathaInk.brickShade),
        );
      }
    }
  }
}

/// The crane's jib, turning slowly over the city: it is the only thing up
/// there that is working.
class Crane extends KathaActor {
  Crane({required super.actorId, this.night = false})
    : super(
        linkColor: KathaInk.marigold,
        position: Vector2(236, 32),
        priority: -9,
      );

  final bool night;
  double _swing = 0;
  double _left = 0;

  @override
  Offset get glowCentre => const Offset(0, 0);
  @override
  double get glowRadius => 40;
  @override
  Vector2 get bubbleAnchor => Vector2(0, 0);

  @override
  double perform(String anim, double seconds) {
    if (game.reducedMotion) return 0;
    _left = math.max(2.4, seconds);
    return _left;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_left > 0) {
      _left -= dt;
      _swing += dt * 0.35;
    }
  }

  @override
  void render(Canvas canvas) {
    final steel = strokeOf(
      night
          ? Color.lerp(kathaNightSky, KathaInk.marigold, 0.45)!
          : KathaInk.marigoldShade,
      1.6,
    );
    final reach = math.cos(_swing) * 70;
    final back = -math.cos(_swing) * 22;
    canvas.drawLine(Offset(back, 0), Offset(reach, 0), steel);
    canvas.drawLine(
      Offset(0, -10),
      Offset(reach * 0.7, 0),
      steel..strokeWidth = 0.8,
    );
    canvas.drawLine(Offset(0, -10), Offset(back, 0), steel);
    canvas.drawRect(
      Rect.fromLTRB(back - 5, 0, back + 3, 6),
      fillOf(KathaInk.shutter),
    );
    canvas.drawLine(
      Offset(reach * 0.8, 0),
      Offset(reach * 0.8, 26),
      strokeOf(KathaInk.ink, 0.7),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(reach * 0.8, 29), width: 8, height: 5),
      fillOf(KathaInk.brick),
    );
    if (night) {
      canvas.drawCircle(Offset(reach, 0), 1.8, fillOf(KathaInk.brick));
    }
  }
}

// =============================================================================
// The kitchen
// =============================================================================

/// The terrace on Deepavali night: lamps along the parapet.
class TerraceLamps extends PositionComponent {
  TerraceLamps() : super(priority: -7);

  double _clock = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < 9; i++) {
      final o = Offset(112 + i * 32.0, 147);
      final flicker = 0.85 + 0.15 * math.sin(_clock * 12 + i * 1.9);
      canvas.drawCircle(
        o.translate(0, -5),
        11 * flicker,
        fillOf(kathaLampLight.withValues(alpha: 0.22)),
      );
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 5, o.dy - 2)
          ..quadraticBezierTo(o.dx, o.dy + 4, o.dx + 5, o.dy - 2)
          ..close(),
        fillOf(KathaInk.brick),
      );
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 2, o.dy - 2)
          ..quadraticBezierTo(o.dx, o.dy - 10 * flicker, o.dx + 2, o.dy - 2)
          ..close(),
        fillOf(kathaLampLight),
      );
    }
  }
}

// =============================================================================
// The ward meeting
// =============================================================================
