import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// The landlady's house dressed for Deepavali, drawn over the night door:
/// marigold strings down the door frame, a star lantern on the balcony, a
/// rangoli in the lane, and clay lamps along every ledge. The lights
/// themselves are [FestiveGlow].
class FestiveHouse extends PositionComponent {
  FestiveHouse() : super(priority: -8);

  late final Picture _picture = recordPicture(_paint);

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    // Marigold strings down both sides of the door, and a swag across it.
    for (final x in [244.0, 302.0]) {
      for (var i = 0; i < 12; i++) {
        canvas.drawCircle(
          Offset(x, 118 + i * 5.0),
          2.6,
          fillOf(i.isEven ? KathaInk.marigold : KathaInk.brick),
        );
      }
    }
    for (var i = 0; i <= 12; i++) {
      final t = i / 12;
      canvas.drawCircle(
        Offset(244 + t * 58, 116 + math.sin(t * math.pi) * 6),
        2.4,
        fillOf(i.isEven ? KathaInk.marigold : KathaInk.brick),
      );
    }
    // The rangoli: a lotus in powder, in the lane before the gate.
    const centre = Offset(200, 232);
    for (var ring = 3; ring >= 1; ring--) {
      final color = [
        KathaInk.paper,
        KathaInk.brick,
        KathaInk.marigold,
        KathaInk.teal,
      ][ring];
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4 + ring * 0.2;
        canvas.save();
        canvas.translate(centre.dx, centre.dy);
        canvas.scale(1, 0.32);
        canvas.rotate(a);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, -ring * 9.0),
            width: ring * 6.0,
            height: ring * 12.0,
          ),
          fillOf(color),
        );
        canvas.restore();
      }
    }
    canvas.drawOval(
      Rect.fromCenter(center: centre, width: 14, height: 5),
      fillOf(KathaInk.marigold),
    );
    // Lamps: their clay cups. The flames are FestiveGlow's.
    for (final o in festiveLamps) {
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 5, o.dy - 2)
          ..quadraticBezierTo(o.dx, o.dy + 4, o.dx + 5, o.dy - 2)
          ..close(),
        fillOf(KathaInk.brick),
      );
    }
    // The lantern's string.
    canvas.drawLine(
      const Offset(220, 100),
      const Offset(220, 110),
      strokeOf(KathaInk.ink, 0.8),
    );
  }
}

/// Where the clay lamps stand: along the compound wall, on the window sill,
/// either side of the door.
const festiveLamps = [
  Offset(18, 164),
  Offset(52, 164),
  Offset(86, 164),
  Offset(120, 164),
  Offset(154, 148),
  Offset(240, 205),
  Offset(308, 205),
  Offset(338, 157),
  Offset(358, 157),
  Offset(378, 157),
];

/// The lights of Deepavali: lamp flames that flicker, a string of bulbs along
/// the parapet that chase, and the lantern's glow. Over the night tint, so
/// they are the brightest things in the picture. They stand behind the
/// people, so a lamp on the wall never glows on somebody's chest.
class FestiveGlow extends KathaActor {
  FestiveGlow({required super.actorId})
    : super(
        linkColor: KathaInk.marigold,
        position: Vector2.zero(),
        priority: -7,
      );

  double _clock = 0;
  double _awake = 0;

  @override
  Offset get glowCentre => const Offset(220, 120);
  @override
  double get glowRadius => 40;
  @override
  Vector2 get bubbleAnchor => Vector2(220, 100);

  @override
  double perform(String anim, double seconds) {
    if (game.reducedMotion) return 0;
    _awake = math.max(3, seconds);
    return _awake;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_awake > 0) _awake -= dt;
  }

  @override
  void render(Canvas canvas) {
    // Halos first, then the flames in them.
    for (var i = 0; i < festiveLamps.length; i++) {
      final o = festiveLamps[i];
      final flicker = 0.85 + 0.15 * math.sin(_clock * 13 + i * 2.3);
      canvas.drawCircle(
        o.translate(0, -5),
        13 * flicker,
        fillOf(kathaLampLight.withValues(alpha: 0.22)),
      );
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 2.2, o.dy - 2)
          ..quadraticBezierTo(o.dx, o.dy - 11 * flicker, o.dx + 2.2, o.dy - 2)
          ..close(),
        fillOf(kathaLampLight),
      );
      canvas.drawCircle(o.translate(0, -4), 1.2, fillOf(kathaFlameCore));
    }
    // A string of bulbs along the parapet, chasing.
    const colours = [
      KathaInk.marigold,
      KathaInk.brick,
      KathaInk.teal,
      kathaFlameCore,
    ];
    for (var i = 0; i < 28; i++) {
      final x = 182 + i * 7.8;
      final y = 64 + math.sin(i * 0.9) * 1.6;
      final on = ((i + (_clock * 5).floor()) % 4) != 0;
      final c = colours[i % 4];
      if (on) {
        canvas.drawCircle(Offset(x, y), 4, fillOf(c.withValues(alpha: 0.28)));
      }
      canvas.drawCircle(
        Offset(x, y),
        1.8,
        fillOf(on ? c : c.withValues(alpha: 0.35)),
      );
    }
    // The star lantern on the balcony, swaying.
    canvas.save();
    canvas.translate(220, 110);
    canvas.rotate(math.sin(_clock * 1.6) * 0.08);
    canvas.drawCircle(
      const Offset(0, 10),
      20,
      fillOf(kathaLampLight.withValues(alpha: 0.18)),
    );
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? 12.0 : 5.5;
      final p = Offset(math.cos(a) * r, 10 + math.sin(a) * r);
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    canvas.drawPath(star, fillOf(KathaInk.marigold));
    canvas.drawCircle(const Offset(0, 10), 4, fillOf(kathaFlameCore));
    for (final dx in [-4.0, 0.0, 4.0]) {
      canvas.drawLine(
        Offset(dx, 21),
        Offset(dx * 1.4, 32),
        strokeOf(KathaInk.brick, 1.2),
      );
    }
    canvas.restore();
  }
}

/// One clay lamp that Dev lights: dark until `light`, then a flame that
/// grows and steadies, brighter than the rest because it is his.
class Diya extends KathaActor {
  Diya({required super.actorId, required Vector2 at})
    : super(linkColor: KathaInk.marigold, position: at, priority: 92);

  double _lit = -1;
  double _clock = 0;

  @override
  Offset get glowCentre => const Offset(0, -6);
  @override
  double get glowRadius => 18;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -20);

  @override
  double perform(String anim, double seconds) {
    if (anim == 'light') {
      _lit = game.reducedMotion ? 1 : 0;
      return 1.6;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_lit >= 0 && _lit < 1) _lit = math.min(1, _lit + dt / 1.2);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(-7, -2)
        ..quadraticBezierTo(0, 6, 7, -2)
        ..close(),
      fillOf(KathaInk.brick),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-7, -2)
        ..lineTo(7, -2)
        ..lineTo(9, -4)
        ..close(),
      fillOf(KathaInk.brickShade),
    );
    if (_lit < 0) return;
    final grow = KathaEase.easeOut(_lit);
    final flicker = 0.9 + 0.1 * math.sin(_clock * 14);
    canvas.drawCircle(
      const Offset(0, -8),
      22 * grow,
      fillOf(kathaLampLight.withValues(alpha: 0.3)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-3, -3)
        ..quadraticBezierTo(0, -17 * grow * flicker, 3, -3)
        ..close(),
      fillOf(kathaLampLight),
    );
    canvas.drawCircle(const Offset(0, -6), 1.6 * grow, fillOf(kathaFlameCore));
  }
}

/// A sparkler in a child's raised hand: a wire, and sparks thrown off its
/// tip while it burns. It finds the hand by asking the rig where it is.
class Sparkler extends KathaActor {
  Sparkler({required super.actorId, required this.holder})
    : super(
        linkColor: KathaInk.marigold,
        position: Vector2.zero(),
        priority: 93,
      );

  final CutoutRig holder;
  double _burn = 0;
  double _clock = 0;

  Vector2 get _tip {
    final arm = holder.gestureArm;
    final local =
        Vector2(0, arm.upper) + (Vector2(0, arm.fore + 20)..rotate(arm.bend));
    return arm.absolutePositionOf(local);
  }

  @override
  Offset get glowCentre => _tip.toOffset();
  @override
  double get glowRadius => 20;
  @override
  Vector2 get bubbleAnchor => _tip;

  @override
  double perform(String anim, double seconds) {
    if (anim != 'light' || game.reducedMotion) return 0;
    _burn = math.max(3.2, seconds);
    return _burn;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_burn > 0) _burn = math.max(0, _burn - dt);
  }

  @override
  void render(Canvas canvas) {
    final arm = holder.gestureArm;
    final hand = arm.absolutePositionOf(
      Vector2(0, arm.upper) + (Vector2(0, arm.fore)..rotate(arm.bend)),
    );
    final tip = _tip;
    canvas.drawLine(
      hand.toOffset(),
      tip.toOffset(),
      strokeOf(KathaInk.shutter, 1.2),
    );
    if (_burn <= 0) return;
    canvas.drawCircle(
      tip.toOffset(),
      10,
      fillOf(kathaLampLight.withValues(alpha: 0.35)),
    );
    final spark = strokeOf(kathaFlameCore, 1);
    for (var i = 0; i < 16; i++) {
      final a = i * 0.39 + _clock * 9;
      final r = 5 + ((i * 7 + (_clock * 30).floor()) % 9);
      final d = Offset(math.cos(a) * r, math.sin(a) * r);
      canvas.drawLine(tip.toOffset() + d * 0.4, tip.toOffset() + d, spark);
    }
    canvas.drawCircle(tip.toOffset(), 2.4, fillOf(kathaFlameCore));
  }
}

/// Fireworks over the city. `burst` opens one shell; `rocket` sends one up
/// first, a whistle of a trail, then opens it; `show` lets off a few.
class Fireworks extends KathaActor {
  Fireworks({
    required super.actorId,
    this.sky = const Rect.fromLTRB(20, 10, 380, 90),
  }) : super(
         linkColor: KathaInk.marigold,
         position: Vector2.zero(),
         priority: -7,
       );

  final Rect sky;
  final List<_Shell> _shells = [];
  int _fired = 0;

  @override
  Offset get glowCentre => sky.center;
  @override
  double get glowRadius => 40;
  @override
  Vector2 get bubbleAnchor => Vector2(sky.center.dx, sky.bottom);

  Offset _spot(int n) => Offset(
    sky.left + ((n * 131 + 47) % sky.width.toInt()),
    sky.top + ((n * 71 + 13) % sky.height.toInt()),
  );

  static const _colours = [
    KathaInk.marigold,
    KathaInk.brick,
    KathaInk.teal,
    kathaFlameCore,
    KathaInk.leaf,
  ];

  @override
  double perform(String anim, double seconds) {
    if (game.reducedMotion) return 0;
    switch (anim) {
      case 'burst':
        _shells.add(_Shell(_spot(_fired), _colours[_fired % 5], delay: 0));
        _fired++;
        return 1.6;
      case 'rocket':
        _shells.add(
          _Shell(
            _spot(_fired),
            _colours[_fired % 5],
            delay: 0,
            rise: 0.9,
            big: true,
          ),
        );
        _fired++;
        return 2.6;
      case 'show':
        for (var i = 0; i < 5; i++) {
          _shells.add(
            _Shell(_spot(_fired), _colours[_fired % 5], delay: i * 0.45),
          );
          _fired++;
        }
        return 4.0;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final shell in _shells) {
      shell.t += dt;
    }
    _shells.removeWhere((s) => s.t > s.delay + s.rise + 1.6);
  }

  @override
  void render(Canvas canvas) {
    for (final shell in _shells) {
      final t = shell.t - shell.delay;
      if (t < 0) continue;
      if (t < shell.rise) {
        // The rocket climbing, a trail of sparks behind it.
        final p = t / shell.rise;
        final from = Offset(shell.at.dx - 20, sky.bottom + 80);
        final at = Offset.lerp(from, shell.at, KathaEase.easeOut(p))!;
        canvas.drawLine(
          at,
          Offset.lerp(from, at, 0.85)!,
          strokeOf(kathaLampLight.withValues(alpha: 0.6), 1.4),
        );
        canvas.drawCircle(at, 1.8, fillOf(kathaFlameCore));
        continue;
      }
      final b = (t - shell.rise) / 1.6;
      final radius =
          (shell.big ? 46 : 30) * KathaEase.easeOut(math.min(1, b * 1.6));
      final fade = (1 - b).clamp(0.0, 1.0);
      if (b < 0.15) {
        canvas.drawCircle(
          shell.at,
          radius * 1.2,
          fillOf(shell.colour.withValues(alpha: 0.25 * (1 - b / 0.15))),
        );
      }
      final spark = strokeOf(shell.colour.withValues(alpha: fade), 1.4);
      for (var i = 0; i < 18; i++) {
        final a = i * math.pi / 9;
        final d = Offset(math.cos(a), math.sin(a) + b * 0.4);
        canvas.drawLine(
          shell.at + d * radius * 0.7,
          shell.at + d * radius,
          spark,
        );
      }
    }
  }
}

class _Shell {
  _Shell(
    this.at,
    this.colour, {
    required this.delay,
    this.rise = 0,
    this.big = false,
  });

  final Offset at;
  final Color colour;
  final double delay;
  final double rise;
  final bool big;
  double t = 0;
}
