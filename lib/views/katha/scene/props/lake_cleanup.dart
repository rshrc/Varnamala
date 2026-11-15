import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// Marigolds laid on the water. `float` sends them from the landlady's hand
/// in a little arc onto the lake, where they rest among the foam.
class MarigoldOffering extends KathaActor {
  MarigoldOffering({required super.actorId, required Vector2 from})
    : super(
        linkColor: KathaInk.marigold,
        position: Vector2.zero(),
        priority: 4,
      ) {
    _from = from.toOffset();
  }

  late final Offset _from;
  double _t = -1;
  double _clock = 0;

  static const _to = Offset(150, 196);

  @override
  Offset get glowCentre => _to;
  @override
  double get glowRadius => 20;
  @override
  Vector2 get bubbleAnchor => Vector2(_to.dx, _to.dy - 20);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'float') return 0;
    _t = game.reducedMotion ? 1 : 0;
    return math.max(3, seconds);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_t >= 0 && _t < 1) _t = math.min(1, _t + dt / 1.4);
  }

  @override
  void render(Canvas canvas) {
    if (_t < 0) return;
    for (var i = 0; i < 5; i++) {
      final p = (_t * 1.3 - i * 0.08).clamp(0.0, 1.0);
      final land = _to.translate(i * 9.0 - 18, (i % 2) * 4.0);
      final arc = Offset.lerp(
        _from,
        land,
        p,
      )!.translate(0, -math.sin(p * math.pi) * 18);
      final bob = p >= 1 ? math.sin(_clock * 1.6 + i) * 1.2 : 0.0;
      final c = arc.translate(0, bob);
      canvas.drawCircle(c, 4.2, fillOf(KathaInk.marigold));
      canvas.drawCircle(c, 2.2, fillOf(KathaInk.marigoldShade));
      if (p >= 1) {
        canvas.drawOval(
          Rect.fromCenter(center: c.translate(0, 4), width: 12, height: 3),
          fillOf(KathaInk.paper.withValues(alpha: 0.35)),
        );
      }
    }
  }
}

/// The lake on fire, seen from the terrace at night: an orange glow beyond
/// the towers and a column of smoke. `ignite` starts it; it does not go out.
class LakeFireGlow extends KathaActor {
  LakeFireGlow({required super.actorId})
    : super(linkColor: KathaInk.brick, position: Vector2.zero(), priority: -9);

  double _heat = 0;
  double _clock = 0;
  bool _burning = false;

  static const _at = Offset(262, 138);

  @override
  Offset get glowCentre => _at;
  @override
  double get glowRadius => 40;
  @override
  Vector2 get bubbleAnchor => Vector2(_at.dx, _at.dy - 40);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'ignite') return 0;
    _burning = true;
    if (game.reducedMotion) _heat = 1;
    return math.max(4, seconds);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_burning && _heat < 1) _heat = math.min(1, _heat + dt / 2);
  }

  @override
  void render(Canvas canvas) {
    if (_heat <= 0) return;
    canvas.save();
    // Behind the parapet: only the sky and the skyline above it light up.
    canvas.clipRect(const Rect.fromLTRB(0, 0, kathaWorldWidth, 146));
    final flicker = 0.85 + 0.15 * math.sin(_clock * 9) * math.sin(_clock * 4.3);
    for (var i = 4; i >= 1; i--) {
      canvas.drawCircle(
        _at,
        i * 22.0 * _heat * flicker,
        fillOf(
          Color.lerp(
            KathaInk.marigold,
            KathaInk.brick,
            i / 4,
          )!.withValues(alpha: 0.16 * _heat),
        ),
      );
    }
    // Smoke, rising and leaning with the wind.
    for (var i = 0; i < 8; i++) {
      final p = ((_clock * 0.25) + i / 8) % 1.0;
      canvas.drawCircle(
        _at.translate(p * 40, -p * 120),
        (8 + p * 22) * _heat,
        fillOf(
          Color.lerp(
            KathaInk.ink,
            KathaInk.shutter,
            0.4,
          )!.withValues(alpha: 0.5 * (1 - p) * _heat),
        ),
      );
    }
    // Flame tips showing between the towers.
    for (var i = 0; i < 6; i++) {
      final h = (10 + 8 * math.sin(_clock * 11 + i * 1.7).abs()) * _heat;
      final x = _at.dx - 30 + i * 12.0;
      canvas.drawPath(
        Path()
          ..moveTo(x - 5, 146)
          ..quadraticBezierTo(x, 146 - h * 2, x + 5, 146)
          ..close(),
        fillOf(
          Color.lerp(
            KathaInk.marigold,
            const Color(0xFFFFE9B8),
            (i % 2) * 0.5,
          )!,
        ),
      );
    }
    canvas.restore();
  }
}

/// The morning after the fire: black ash lying on the water among the foam.
class LakeAsh extends PositionComponent {
  LakeAsh() : super(priority: -8);

  @override
  void render(Canvas canvas) {
    final ash = fillOf(KathaInk.ink.withValues(alpha: 0.55));
    for (final (x, y, w) in [
      (30.0, 156.0, 40.0),
      (120.0, 172.0, 54.0),
      (200.0, 158.0, 30.0),
      (60.0, 192.0, 36.0),
      (250.0, 186.0, 44.0),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: w, height: w * 0.22),
        ash,
      );
    }
  }
}

/// A notice board on the lake fence: a white sheet, a red government seal, a
/// corner lifting in the wind. Its words come from the telling, so the sheet
/// shows only lines.
class LakeNotice extends KathaActor {
  LakeNotice({required super.actorId})
    : super(
        linkColor: KathaInk.brick,
        position: Vector2(286, 228),
        priority: 2,
      );

  double _flutter = 0;
  double _clock = 0;

  @override
  Offset get glowCentre => const Offset(0, -64);
  @override
  double get glowRadius => 30;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -96);

  @override
  double perform(String anim, double seconds) {
    if (game.reducedMotion) return 0;
    _flutter = math.max(2.5, seconds);
    return _flutter;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_flutter > 0) _flutter = math.max(0, _flutter - dt);
  }

  @override
  void render(Canvas canvas) {
    final post = fillOf(KathaInk.brickShade);
    canvas.drawRect(const Rect.fromLTRB(-26, -60, -22, 0), post);
    canvas.drawRect(const Rect.fromLTRB(22, -60, 26, 0), post);
    canvas.drawRect(
      const Rect.fromLTRB(-30, -92, 30, -50),
      fillOf(KathaInk.paper),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-30, -92, 30, -50),
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    for (var y = -84.0; y < -56; y += 5) {
      canvas.drawLine(
        Offset(-24, y),
        Offset(y > -62 ? 4 : 22, y),
        Paint()
          ..color = KathaInk.ink.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
    }
    canvas.drawCircle(const Offset(18, -60), 5, fillOf(KathaInk.brick));
    final lift = _flutter > 0 ? (2 + 2 * math.sin(_clock * 18)) : 0.0;
    canvas.drawPath(
      Path()
        ..moveTo(30, -92)
        ..lineTo(22 - lift, -92 - lift)
        ..lineTo(30, -84)
        ..close(),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.12)!),
    );
  }
}

/// A Sunday's work on the lake steps: full sacks tied at the neck, a rake, a
/// pile of what came out of the water.
class CleanupSacks extends PositionComponent {
  CleanupSacks() : super(priority: 1);

  @override
  void render(Canvas canvas) {
    for (final (x, w) in [(318.0, 26.0), (344.0, 22.0), (330.0, 20.0)]) {
      final top = x == 330.0 ? 168.0 : 176.0;
      canvas.drawRRect(
        RRect.fromLTRBR(
          x - w / 2,
          top,
          x + w / 2,
          210,
          const Radius.circular(8),
        ),
        fillOf(
          x == 330.0
              ? KathaInk.leafShade
              : Color.lerp(KathaInk.ink, KathaInk.leaf, 0.3)!,
        ),
      );
      canvas.drawRect(
        Rect.fromLTRB(x - 3, top - 5, x + 3, top + 1),
        fillOf(KathaInk.marigold),
      );
    }
    // What came out: a tyre, a chappal, bottles.
    canvas.drawCircle(const Offset(290, 204), 8, fillOf(KathaInk.ink));
    canvas.drawCircle(
      const Offset(290, 204),
      4,
      fillOf(Color.lerp(KathaInk.paper, KathaInk.marigoldShade, 0.35)!),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(270, 205, 282, 209, const Radius.circular(2)),
      fillOf(KathaInk.brick),
    );
    canvas.drawLine(
      const Offset(360, 212),
      const Offset(380, 160),
      Paint()
        ..color = KathaInk.brickShade
        ..strokeWidth = 2,
    );
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(374 + i * 3.0, 156),
        Offset(376 + i * 3.0, 164),
        Paint()
          ..color = KathaInk.ink
          ..strokeWidth = 1.2,
      );
    }
  }
}

/// Two big steel vessels of food on the steps, steaming, a ladle in each.
class FoodVessels extends PositionComponent {
  FoodVessels() : super(priority: 6);

  @override
  void render(Canvas canvas) {
    final steel = Color.lerp(KathaInk.paper, KathaInk.ink, 0.28)!;
    for (final (x, food) in [
      (196.0, KathaInk.marigoldShade),
      (240.0, KathaInk.brick),
    ]) {
      canvas.drawRRect(
        RRect.fromLTRBR(x - 18, 196, x + 18, 222, const Radius.circular(6)),
        fillOf(steel),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 197), width: 38, height: 9),
        fillOf(Color.lerp(steel, KathaInk.ink, 0.15)!),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 198), width: 32, height: 6),
        fillOf(food),
      );
      canvas.drawLine(
        Offset(x + 6, 198),
        Offset(x + 18, 182),
        Paint()
          ..color = steel
          ..strokeWidth = 2,
      );
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(x - 6 + i * 6.0, 186 - i * 4.0),
          3.5,
          fillOf(KathaInk.paper.withValues(alpha: 0.5)),
        );
      }
    }
  }
}

/// A sample bottle on the steps. `test` drops the reagent in: the water swirls
/// from clear to a dark brown.
class TestBottle extends KathaActor {
  TestBottle({required super.actorId, required Vector2 at})
    : super(linkColor: KathaInk.leaf, position: at, priority: 7);

  double _t = -1;
  double _clock = 0;

  @override
  Offset get glowCentre => const Offset(0, -10);
  @override
  double get glowRadius => 16;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -26);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'test') return 0;
    _t = game.reducedMotion ? 1 : 0;
    return 2.5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_t >= 0 && _t < 1) _t = math.min(1, _t + dt / 1.8);
  }

  @override
  void render(Canvas canvas) {
    final water = Color.lerp(
      Color.lerp(KathaInk.paper, KathaInk.teal, 0.25)!,
      const Color(0xFF5A4126),
      _t < 0 ? 0 : _t,
    )!;
    canvas.drawRRect(
      RRect.fromLTRBR(-6, -20, 6, 0, const Radius.circular(3)),
      fillOf(KathaInk.paper.withValues(alpha: 0.5)),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(-5, -14, 5, -1, const Radius.circular(2)),
      fillOf(water),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-3, -25, 3, -20),
      fillOf(KathaInk.teal),
    );
    if (_t > 0 && _t < 1) {
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(math.sin(_clock * 6 + i) * 3, -6 - i * 3.0),
          1,
          fillOf(KathaInk.paper.withValues(alpha: 0.6)),
        );
      }
    }
  }
}

/// Where the sewage comes in: a compound wall on the far bank, a fat pipe
/// through it pouring dark water into the lake, and above it the building's
/// board, its name left blank for the telling to say.
class OutfallPipe extends KathaActor {
  OutfallPipe({required super.actorId})
    : super(linkColor: KathaInk.brick, position: Vector2.zero(), priority: -7);

  double _clock = 0;
  double _pour = 0;

  @override
  Offset get glowCentre => const Offset(330, 176);
  @override
  double get glowRadius => 30;
  @override
  Vector2 get bubbleAnchor => Vector2(330, 150);

  @override
  double perform(String anim, double seconds) {
    if (game.reducedMotion) return 0;
    _pour = math.max(4, seconds);
    return _pour;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_pour > 0) {
      _pour -= dt;
      _clock += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    // The wall and the gleaming tower behind it.
    canvas.drawRect(
      const Rect.fromLTRB(262, 40, 400, 150),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.35)!),
    );
    for (var y = 48.0; y < 146; y += 12) {
      for (var x = 270.0; x < 396; x += 14) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, 8, 7),
          fillOf(KathaInk.teal.withValues(alpha: 0.45)),
        );
      }
    }
    canvas.drawRect(
      const Rect.fromLTRB(256, 150, 400, 200),
      fillOf(Color.lerp(KathaInk.brick, KathaInk.paper, 0.3)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(256, 146, 400, 152),
      fillOf(KathaInk.paper),
    );
    // The board.
    canvas.drawRect(
      const Rect.fromLTRB(276, 112, 384, 140),
      fillOf(KathaInk.paper),
    );
    canvas.drawRect(
      const Rect.fromLTRB(276, 112, 384, 140),
      Paint()
        ..color = KathaInk.marigoldShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(286, 122),
      const Offset(374, 122),
      Paint()
        ..color = KathaInk.teal
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      const Offset(296, 131),
      const Offset(364, 131),
      Paint()
        ..color = KathaInk.teal.withValues(alpha: 0.6)
        ..strokeWidth = 2,
    );
    // The pipe and what it pours.
    canvas.drawRect(
      const Rect.fromLTRB(310, 170, 350, 184),
      fillOf(KathaInk.shutter),
    );
    canvas.drawOval(
      const Rect.fromLTRB(304, 168, 316, 186),
      fillOf(KathaInk.ink),
    );
    final sewage = fillOf(const Color(0xFF4A3A26));
    canvas.drawPath(
      Path()
        ..moveTo(306, 172)
        ..quadraticBezierTo(296, 180, 300, 206)
        ..lineTo(312, 206)
        ..quadraticBezierTo(308, 184, 312, 182)
        ..close(),
      sewage,
    );
    canvas.drawOval(
      const Rect.fromLTRB(270, 198, 330, 210),
      fillOf(const Color(0xFF4A3A26).withValues(alpha: 0.7)),
    );
    for (var i = 0; i < 4; i++) {
      final p = ((_clock * 1.5) + i / 4) % 1.0;
      canvas.drawCircle(
        Offset(304 - p * 4, 176 + p * 28),
        1.6,
        fillOf(const Color(0xFF7A6040)),
      );
    }
  }
}
