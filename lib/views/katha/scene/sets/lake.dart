import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// `bg.lake_dawn`: the neighbourhood lake at five in the morning. A pink sky,
/// towers and a crane on the far shore, grey water carrying drifts of white
/// foam, dead branches standing out of it, a bottle at the edge. In front, the
/// old stone steps down to the water that nobody uses any more, a path, a
/// bench, and a rain tree to stand behind.
class LakeBackdrop extends PositionComponent {
  LakeBackdrop() : super(priority: -10);

  /// Where the path is, for feet.
  static const ground = 228.0;

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    _paint(Canvas(recorder));
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    // Sky, warming from the horizon up.
    for (var i = 0; i < 6; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * 18.0, kathaWorldWidth, 19),
        fillOf(
          Color.lerp(
            Color.lerp(KathaInk.paper, KathaInk.teal, 0.25)!,
            kathaDawnPink,
            i / 5,
          )!,
        ),
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(0, 108, kathaWorldWidth, 120),
      fillOf(kathaDawnGold),
    );
    canvas.drawCircle(
      const Offset(300, 116),
      14,
      fillOf(const Color(0xFFFFE9B8)),
    );
    // The far shore: towers, one still a frame, a crane.
    final far = fillOf(Color.lerp(kathaDawnPink, KathaInk.ink, 0.35)!);
    for (final (l, t, w) in [
      (0.0, 84.0, 34.0),
      (40.0, 70.0, 26.0),
      (72.0, 92.0, 40.0),
      (180.0, 78.0, 30.0),
      (214.0, 96.0, 24.0),
      (330.0, 74.0, 36.0),
      (372.0, 90.0, 28.0),
    ]) {
      canvas.drawRect(Rect.fromLTRB(l, t, l + w, 122), far);
    }
    final frame = Paint()
      ..color = Color.lerp(kathaDawnPink, KathaInk.ink, 0.45)!
      ..strokeWidth = 1.2;
    for (var y = 64.0; y <= 122; y += 10) {
      canvas.drawLine(Offset(124, y), Offset(158, y), frame);
    }
    for (final x in [124.0, 141.0, 158.0]) {
      canvas.drawLine(Offset(x, 64), Offset(x, 122), frame);
    }
    canvas.drawLine(
      const Offset(256, 30),
      const Offset(256, 122),
      frame..strokeWidth = 1.6,
    );
    canvas.drawLine(const Offset(226, 34), const Offset(312, 34), frame);
    // The water: grey-green, a gleam of dawn across it.
    canvas.drawRect(
      const Rect.fromLTRB(0, 122, kathaWorldWidth, 206),
      fillOf(const Color(0xFF7E8F86)),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 122, kathaWorldWidth, 128),
      fillOf(Color.lerp(kathaDawnPink, const Color(0xFF7E8F86), 0.5)!),
    );
    for (var i = 0; i < 7; i++) {
      canvas.drawRect(
        Rect.fromLTWH(262.0 + (i % 3) * 8, 132.0 + i * 9, 50.0 - i * 5, 2),
        fillOf(kathaDawnGold.withValues(alpha: 0.55)),
      );
    }
    // Dead branches standing out of the water.
    final dead = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final x in [62.0, 214.0]) {
      canvas.drawLine(Offset(x, 170), Offset(x + 2, 128), dead);
      canvas.drawLine(
        Offset(x + 1, 146),
        Offset(x - 10, 134),
        dead..strokeWidth = 1.4,
      );
      canvas.drawLine(Offset(x + 2, 138), Offset(x + 12, 128), dead);
    }
    // The near bank: stone steps down to the water, old and cracked.
    final stone = Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!;
    for (var i = 0; i < 4; i++) {
      final y = 188.0 + i * 6;
      canvas.drawRect(
        Rect.fromLTRB(110 - i * 4.0, y, 300 + i * 4.0, y + 6),
        fillOf(Color.lerp(stone, KathaInk.ink, i * 0.05)!),
      );
      canvas.drawLine(
        Offset(110 - i * 4.0, y + 6),
        Offset(300 + i * 4.0, y + 6),
        Paint()..color = KathaInk.ink.withValues(alpha: 0.15),
      );
    }
    canvas.drawLine(
      const Offset(180, 194),
      const Offset(190, 206),
      Paint()..color = KathaInk.ink.withValues(alpha: 0.3),
    );
    // The path, packed earth.
    canvas.drawRect(
      const Rect.fromLTRB(0, 212, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.marigoldShade, 0.35)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 206, kathaWorldWidth, 212),
      fillOf(Color.lerp(KathaInk.leaf, KathaInk.ink, 0.15)!),
    );
    // A plastic bottle and a packet at the water's edge.
    canvas.drawRRect(
      RRect.fromLTRBR(318, 200, 330, 205, const Radius.circular(2)),
      fillOf(KathaInk.teal.withValues(alpha: 0.7)),
    );
    canvas.drawRect(
      const Rect.fromLTRB(92, 201, 101, 206),
      fillOf(KathaInk.brick.withValues(alpha: 0.7)),
    );
    // A bench, and the rain tree on the right.
    canvas.drawRect(
      const Rect.fromLTRB(16, 214, 70, 219),
      fillOf(KathaInk.brickShade),
    );
    canvas.drawRect(
      const Rect.fromLTRB(20, 219, 24, 232),
      fillOf(KathaInk.ink),
    );
    canvas.drawRect(
      const Rect.fromLTRB(62, 219, 66, 232),
      fillOf(KathaInk.ink),
    );
    canvas.drawRect(
      const Rect.fromLTRB(368, 60, 386, 236),
      fillOf(Color.lerp(KathaInk.brickShade, KathaInk.ink, 0.3)!),
    );
    for (final (x, y, r) in [
      (352.0, 40.0, 34.0),
      (392.0, 30.0, 30.0),
      (372.0, 12.0, 28.0),
      (330.0, 62.0, 22.0),
    ]) {
      canvas.drawCircle(
        Offset(x, y),
        r,
        fillOf(Color.lerp(KathaInk.leaf, KathaInk.ink, 0.25)!),
      );
    }
  }
}

/// The foam on the lake, drifting: white clouds of it riding the water, a
/// little at a time.
class LakeFoam extends KathaActor {
  LakeFoam({required super.actorId})
    : super(linkColor: KathaInk.paper, position: Vector2.zero(), priority: -9);

  double _clock = 0;
  double _stir = 0;

  @override
  Offset get glowCentre => const Offset(140, 160);
  @override
  double get glowRadius => 40;
  @override
  Vector2 get bubbleAnchor => Vector2(140, 150);

  @override
  double perform(String anim, double seconds) {
    if (game.reducedMotion) return 0;
    _stir = math.max(4, seconds);
    return _stir;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_stir > 0) {
      _stir -= dt;
      _clock += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final foam = fillOf(const Color(0xFFF4F1EA).withValues(alpha: 0.92));
    final shade = fillOf(
      Color.lerp(const Color(0xFFF4F1EA), const Color(0xFF7E8F86), 0.3)!,
    );
    for (final (x, y, s) in [
      (20.0, 150.0, 1.0),
      (96.0, 166.0, 1.3),
      (176.0, 148.0, 0.9),
      (40.0, 186.0, 1.1),
      (236.0, 176.0, 0.8),
      (150.0, 190.0, 0.7),
    ]) {
      final dx = math.sin(_clock * 0.6 + x) * 4;
      final c = Offset(x + dx, y);
      canvas.drawOval(
        Rect.fromCenter(
          center: c.translate(0, 3),
          width: 46 * s,
          height: 12 * s,
        ),
        shade,
      );
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(
          c.translate((i - 1.5) * 9 * s, -(i % 2) * 3 * s),
          7 * s,
          foam,
        );
      }
    }
  }
}

/// The lake at night: the dawn sky painted over dark, a moon, the towers
/// lit, and the whole scene dimmed. Sits over [LakeBackdrop].
class LakeNight extends PositionComponent {
  LakeNight() : super(priority: -9);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(0, 0, kathaWorldWidth, 64),
      fillOf(const Color(0xFF1C2A44)),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 64, kathaWorldWidth, 122),
      fillOf(const Color(0xFF1C2A44).withValues(alpha: 0.85)),
    );
    canvas.drawCircle(
      const Offset(300, 36),
      11,
      fillOf(const Color(0xFFFFF2C4)),
    );
    canvas.drawCircle(
      const Offset(306, 32),
      10,
      fillOf(const Color(0xFF1C2A44)),
    );
    for (var i = 0; i < 18; i++) {
      canvas.drawCircle(
        Offset((i * 97 % 400).toDouble(), (i * 29 % 56).toDouble() + 4),
        0.9,
        fillOf(const Color(0xFFFFF2C4).withValues(alpha: 0.8)),
      );
    }
    // Windows lit in the towers across the water.
    for (var i = 0; i < 40; i++) {
      final x = (i * 37 % 400).toDouble();
      final y = 78 + (i * 13 % 40).toDouble();
      canvas.drawRect(
        Rect.fromLTWH(x, y, 2.4, 3),
        fillOf(const Color(0xFFFFD27A).withValues(alpha: 0.85)),
      );
    }
    // The water goes dark too.
    canvas.drawRect(
      const Rect.fromLTRB(0, 122, kathaWorldWidth, 206),
      fillOf(const Color(0xFF1C2A44).withValues(alpha: 0.55)),
    );
    // The moon on the water.
    canvas.drawRect(
      const Rect.fromLTRB(288, 132, 312, 134),
      fillOf(const Color(0xFFFFF2C4).withValues(alpha: 0.5)),
    );
    canvas.drawRect(
      const Rect.fromLTRB(292, 142, 308, 144),
      fillOf(const Color(0xFFFFF2C4).withValues(alpha: 0.35)),
    );
  }
}

/// Birds come back to the lake. `arrive` brings a few herons gliding in from
/// the right, wings slowing, until they settle on the water.
class BirdFlock extends KathaActor {
  BirdFlock({required super.actorId})
    : super(linkColor: KathaInk.teal, position: Vector2.zero(), priority: -6);

  double _t = -1;
  double _clock = 0;

  static const _rests = [
    Offset(70, 176),
    Offset(112, 168),
    Offset(196, 184),
    Offset(240, 172),
  ];

  @override
  Offset get glowCentre => const Offset(150, 176);
  @override
  double get glowRadius => 50;
  @override
  Vector2 get bubbleAnchor => Vector2(150, 150);

  @override
  double perform(String anim, double seconds) {
    // Once they have come, they stay: a second cue does not fly them in again.
    if (anim != 'arrive' || _t >= 0) return 0;
    _t = game.reducedMotion ? 1 : 0;
    return 4.5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_t >= 0 && _t < 1) _t = math.min(1, _t + dt / 3.5);
  }

  @override
  void render(Canvas canvas) {
    if (_t < 0) return;
    for (var i = 0; i < _rests.length; i++) {
      final p = ((_t * 1.4) - i * 0.12).clamp(0.0, 1.0);
      final from = Offset(440 + i * 30.0, 30 + i * 12.0);
      final at = Offset.lerp(
        from,
        _rests[i],
        1 - math.pow(1 - p, 2).toDouble(),
      )!;
      final flying = p < 1;
      final flap = flying ? math.sin(_clock * 10 + i) * 6 : 0.0;
      final body = fillOf(KathaInk.paper);
      // A heron: white body, long neck, a yellow bill, legs tucked.
      canvas.drawOval(Rect.fromCenter(center: at, width: 16, height: 7), body);
      canvas.drawLine(
        at.translate(-6, -1),
        at.translate(-11, -10),
        Paint()
          ..color = KathaInk.paper
          ..strokeWidth = 2,
      );
      canvas.drawCircle(at.translate(-11, -11), 2.2, body);
      canvas.drawLine(
        at.translate(-13, -11),
        at.translate(-18, -10),
        Paint()
          ..color = KathaInk.marigold
          ..strokeWidth = 1.4,
      );
      if (flying) {
        canvas.drawPath(
          Path()
            ..moveTo(at.dx - 3, at.dy - 2)
            ..quadraticBezierTo(
              at.dx + 4,
              at.dy - 14 - flap,
              at.dx + 12,
              at.dy - 8 - flap,
            )
            ..lineTo(at.dx + 4, at.dy - 1)
            ..close(),
          body,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: at.translate(0, 5), width: 22, height: 3),
          fillOf(KathaInk.paper.withValues(alpha: 0.35)),
        );
      }
    }
  }
}
