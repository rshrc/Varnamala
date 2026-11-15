import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// `bg.ward_meeting`: a striped tent over the street corner, plastic chairs,
/// tube lights, a stage with speakers stacked either side, and behind it a
/// banner of the neta, twice life size, smiling. The front of the stage is
/// [StageFront], so that whoever stands on it stands on it.
class WardMeetingBackdrop extends PositionComponent {
  WardMeetingBackdrop() : super(priority: -10);

  /// Where feet stand on the stage.
  static const stageTop = 196.0;

  /// Where the stage begins, from the left.
  static const stageLeft = 196.0;

  late final Picture _picture = recordPicture(_paint);

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    // Evening, and the street beyond the tent.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(kathaNightSky, KathaInk.brick, 0.25)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 232, kathaWorldWidth, kathaWorldHeight),
      fillOf(KathaInk.road),
    );
    // Back wall of the tent: cloth in panels.
    canvas.drawRect(
      const Rect.fromLTRB(0, 40, kathaWorldWidth, 232),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.marigold, 0.4)!),
    );
    for (var x = 0.0; x < 400; x += 26) {
      canvas.drawRect(
        Rect.fromLTWH(x, 40, 13, 192),
        fillOf(Color.lerp(KathaInk.paper, KathaInk.brick, 0.25)!),
      );
    }
    // The canopy: stripes and a scalloped edge.
    for (var x = 0.0; x < 400; x += 20) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 10, 36), fillOf(KathaInk.brick));
      canvas.drawRect(Rect.fromLTWH(x + 10, 0, 10, 36), fillOf(KathaInk.paper));
    }
    for (var x = 0.0; x < 400; x += 20) {
      canvas.drawArc(
        Rect.fromLTWH(x, 28, 20, 16),
        0,
        math.pi,
        true,
        fillOf(KathaInk.marigold),
      );
    }
    // Tube lights on the poles, one flickering (drawn steady here).
    for (final x in [24.0, 166.0]) {
      canvas.drawRect(
        Rect.fromLTWH(x - 2, 36, 4, 196),
        fillOf(KathaInk.shutter),
      );
      canvas.drawRect(Rect.fromLTWH(x - 14, 62, 28, 4), fillOf(kathaFlameCore));
      canvas.drawRect(
        Rect.fromLTWH(x - 18, 56, 36, 16),
        fillOf(kathaFlameCore.withValues(alpha: 0.18)),
      );
    }
    // Plastic chairs in rows, some empty, one tipped back.
    for (var row = 0; row < 2; row++) {
      for (var i = 0; i < 6; i++) {
        final x = 34.0 + i * 26 + row * 12;
        final y = 186.0 + row * 14;
        final colour = (i + row).isEven ? KathaInk.teal : KathaInk.brick;
        canvas.drawRRect(
          RRect.fromLTRBR(x, y - 22, x + 18, y - 4, const Radius.circular(3)),
          fillOf(colour),
        );
        canvas.drawRect(
          Rect.fromLTRB(x - 1, y - 6, x + 19, y - 2),
          fillOf(Color.lerp(colour, KathaInk.ink, 0.25)!),
        );
        canvas.drawLine(
          Offset(x + 2, y - 2),
          Offset(x, y + 12),
          strokeOf(colour, 2),
        );
        canvas.drawLine(
          Offset(x + 16, y - 2),
          Offset(x + 18, y + 12),
          strokeOf(colour, 2),
        );
      }
    }

    // The banner: the neta, beaming, hands folded, a sunburst behind him.
    const banner = Rect.fromLTRB(208, 50, 392, 150);
    canvas.drawRect(banner, fillOf(KathaInk.paper));
    canvas.save();
    canvas.clipRect(banner);
    final ray = fillOf(KathaInk.marigold.withValues(alpha: 0.4));
    const sun = Offset(228, 92);
    for (var i = 0; i < 16; i += 2) {
      final a = i * math.pi / 8, b = (i + 1) * math.pi / 8;
      canvas.drawPath(
        Path()
          ..moveTo(sun.dx, sun.dy)
          ..lineTo(sun.dx + math.cos(a) * 200, sun.dy + math.sin(a) * 200)
          ..lineTo(sun.dx + math.cos(b) * 200, sun.dy + math.sin(b) * 200)
          ..close(),
        ray,
      );
    }
    netaPortrait(canvas, const Offset(228, 92), 1.0);
    canvas.restore();
    // The band along the bottom of the banner is blank: its words come from
    // the telling.
    canvas.drawRect(
      const Rect.fromLTRB(208, 136, 392, 150),
      fillOf(KathaInk.brick),
    );
    canvas.drawRect(banner, strokeOf(KathaInk.ink, 2));

    // Speakers stacked by the stage.
    for (final x in [198.0, 372.0]) {
      for (var i = 0; i < 2; i++) {
        final top = 150.0 + i * 24;
        canvas.drawRect(Rect.fromLTWH(x, top, 26, 24), fillOf(KathaInk.ink));
        canvas.drawCircle(
          Offset(x + 13, top + 12),
          8,
          fillOf(Color.lerp(KathaInk.ink, KathaInk.paper, 0.25)!),
        );
        canvas.drawCircle(Offset(x + 13, top + 12), 3, fillOf(KathaInk.ink));
      }
    }
  }
}

/// The front of the stage: a cloth skirt with marigold scallops, in front of
/// the feet of whoever is on it.
class StageFront extends PositionComponent {
  StageFront() : super(priority: 5);

  @override
  void render(Canvas canvas) {
    const top = WardMeetingBackdrop.stageTop;
    const left = WardMeetingBackdrop.stageLeft;
    canvas.drawRect(
      const Rect.fromLTRB(left, top, kathaWorldWidth, 232),
      fillOf(KathaInk.teal),
    );
    for (var x = left; x < 400; x += 12) {
      canvas.drawRect(
        Rect.fromLTWH(x, top, 6, 36),
        fillOf(Color.lerp(KathaInk.teal, KathaInk.ink, 0.2)!),
      );
    }
    for (var x = left; x < 400; x += 14) {
      canvas.drawArc(
        Rect.fromLTWH(x, top - 4, 14, 12),
        0,
        math.pi,
        true,
        fillOf(KathaInk.marigold),
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(left, top - 2, kathaWorldWidth, top + 1),
      fillOf(Color.lerp(KathaInk.teal, KathaInk.paper, 0.4)!),
    );
  }
}

/// The neta's face, for banners and posters: big, round, sunglasses at night,
/// a moustache with ambitions, marigolds round the neck, hands folded.
void netaPortrait(Canvas canvas, Offset c, double s) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(s);
  final skin = Color.lerp(KathaInk.skinWarm, KathaInk.skinDeep, 0.35)!;
  canvas.drawPath(
    Path()
      ..moveTo(-28, 40)
      ..quadraticBezierTo(-26, 16, 0, 14)
      ..quadraticBezierTo(26, 16, 28, 40)
      ..close(),
    fillOf(const Color(0xFFFFFFFF)),
  );
  canvas.drawPath(
    Path()
      ..moveTo(-6, 38)
      ..quadraticBezierTo(-6, 24, 0, 20)
      ..quadraticBezierTo(6, 24, 6, 38)
      ..close(),
    fillOf(skin),
  );
  for (var i = 0; i <= 10; i++) {
    final u = i / 10;
    canvas.drawCircle(
      Offset(-16 + u * 32, 12 + math.sin(u * math.pi) * 9),
      2.6,
      fillOf(i.isEven ? KathaInk.marigold : KathaInk.brick),
    );
  }
  canvas.drawCircle(const Offset(-16.5, -1), 3.2, fillOf(skin));
  canvas.drawCircle(const Offset(16.5, -1), 3.2, fillOf(skin));
  canvas.drawOval(const Rect.fromLTRB(-16, -20, 16, 16), fillOf(skin));
  // Oiled hair, combed back.
  canvas.drawPath(
    Path()
      ..moveTo(-16, -4)
      ..cubicTo(-18, -22, 18, -26, 16, -4)
      ..lineTo(14, -10)
      ..cubicTo(8, -17, -8, -17, -14, -10)
      ..close(),
    fillOf(KathaInk.ink),
  );
  // Sunglasses, and the smile beneath them.
  canvas.drawRRect(
    RRect.fromLTRBR(-12, -6, -2, 1, const Radius.circular(2.5)),
    fillOf(KathaInk.ink),
  );
  canvas.drawRRect(
    RRect.fromLTRBR(2, -6, 12, 1, const Radius.circular(2.5)),
    fillOf(KathaInk.ink),
  );
  canvas.drawLine(
    const Offset(-2, -4),
    const Offset(2, -4),
    strokeOf(KathaInk.ink, 1.2),
  );
  canvas.drawPath(
    Path()
      ..moveTo(-9, 5)
      ..quadraticBezierTo(0, 2, 9, 5)
      ..quadraticBezierTo(0, 8, -9, 5)
      ..close(),
    fillOf(KathaInk.ink),
  );
  canvas.drawPath(
    Path()
      ..moveTo(-7, 8)
      ..quadraticBezierTo(0, 15, 7, 8)
      ..close(),
    fillOf(KathaInk.paper),
  );
  canvas.restore();
}

/// The microphone on its stand, on the stage. `squeal` sets it howling:
/// rings of feedback, and the stand shivering.
class MicStand extends KathaActor {
  MicStand({required super.actorId, required Vector2 at})
    : super(linkColor: KathaInk.ink, position: at, priority: 7);

  double _squeal = 0;

  @override
  Offset get glowCentre => const Offset(0, -86);
  @override
  double get glowRadius => 14;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -96);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'squeal' || game.reducedMotion) return 0;
    _squeal = 1.2;
    return 1.3;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_squeal > 0) _squeal = math.max(0, _squeal - dt);
  }

  @override
  void render(Canvas canvas) {
    final shake = _squeal > 0 ? math.sin(_squeal * 80) * 1.2 : 0.0;
    canvas.drawLine(
      const Offset(-10, 0),
      const Offset(10, 0),
      strokeOf(KathaInk.ink, 2.4),
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(shake, -80),
      strokeOf(KathaInk.ink, 1.8),
    );
    canvas.drawLine(
      Offset(shake, -80),
      Offset(shake + 8, -88),
      strokeOf(KathaInk.ink, 1.8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(shake + 10, -91), width: 7, height: 11),
        const Radius.circular(3.5),
      ),
      fillOf(Color.lerp(KathaInk.ink, KathaInk.paper, 0.2)!),
    );
    if (_squeal > 0) {
      for (var i = 0; i < 3; i++) {
        final r = 8.0 + i * 7 + (1.2 - _squeal) * 12;
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(10, -91), radius: r),
          -math.pi * 0.4,
          math.pi * 0.8,
          false,
          strokeOf(KathaInk.brick.withValues(alpha: _squeal / 1.2), 1.4),
        );
      }
    }
  }
}

/// The crowd in the front rows, heads and shoulders along the bottom of the
/// picture. `laugh` sets them rocking; `clap` puts their hands up.
class Crowd extends KathaActor {
  Crowd({required super.actorId, this.from = 0, this.to = 190})
    : super(linkColor: KathaInk.ink, position: Vector2.zero(), priority: 8);

  final double from;
  final double to;
  double _laugh = 0;
  double _clap = 0;
  double _clock = 0;

  @override
  Offset get glowCentre => Offset((from + to) / 2, 248);
  @override
  double get glowRadius => 40;
  @override
  Vector2 get bubbleAnchor => Vector2((from + to) / 2, 230);

  @override
  double perform(String anim, double seconds) {
    if (game.reducedMotion) return 0;
    if (anim == 'laugh') _laugh = math.max(1.6, seconds);
    if (anim == 'clap') _clap = math.max(2.4, seconds);
    return math.max(_laugh, _clap);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_laugh > 0) _laugh = math.max(0, _laugh - dt);
    if (_clap > 0) _clap = math.max(0, _clap - dt);
  }

  @override
  void render(Canvas canvas) {
    final shirts = [
      KathaInk.brick,
      KathaInk.leaf,
      KathaInk.marigoldShade,
      KathaInk.teal,
    ];
    var i = 0;
    for (var x = from + 14; x < to; x += 30, i++) {
      final bob = _laugh > 0 ? math.sin(_clock * 14 + i * 1.3).abs() * -3 : 0.0;
      final y = 252.0 + (i.isEven ? 0 : 4) + bob;
      final skin = Color.lerp(
        KathaInk.skinWarm,
        KathaInk.skinDeep,
        (i * 0.37) % 1,
      )!;
      canvas.drawRRect(
        RRect.fromLTRBR(x - 15, y, x + 15, y + 20, const Radius.circular(10)),
        fillOf(Color.lerp(shirts[i % 4], KathaInk.ink, 0.35)!),
      );
      canvas.drawCircle(
        Offset(x, y - 8),
        10,
        fillOf(Color.lerp(skin, KathaInk.ink, 0.35)!),
      );
      canvas.drawPath(
        Path()
          ..moveTo(x - 10, y - 9)
          ..cubicTo(x - 10, y - 22, x + 10, y - 22, x + 10, y - 9)
          ..close(),
        fillOf(
          Color.lerp(KathaInk.ink, KathaInk.paper, i % 5 == 0 ? 0.55 : 0.05)!,
        ),
      );
      if (_clap > 0) {
        final apart = 3 + 4 * math.sin(_clock * 20 + i).abs();
        for (final side in [-1.0, 1.0]) {
          canvas.drawCircle(
            Offset(x + side * apart, y - 22 + (i % 2) * 3.0),
            3.6,
            fillOf(Color.lerp(skin, KathaInk.ink, 0.25)!),
          );
        }
      }
    }
  }
}

/// A camera flash: the whole picture goes white for a blink.
class CameraFlash extends KathaActor {
  CameraFlash({required super.actorId})
    : super(linkColor: KathaInk.paper, position: Vector2.zero(), priority: 95);

  double _flash = 0;

  @override
  Offset get glowCentre => const Offset(200, 130);
  @override
  double get glowRadius => 1;
  @override
  Vector2 get bubbleAnchor => Vector2(200, 100);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'flash') return 0;
    _flash = game.reducedMotion ? 0 : 0.45;
    return 0.5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flash > 0) _flash = math.max(0, _flash - dt);
  }

  @override
  void render(Canvas canvas) {
    if (_flash <= 0) return;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      fillOf(
        const Color(0xFFFFFFFF)
            .withValues(alpha: (_flash / 0.45).clamp(0, 1) * 0.9),
      ),
    );
  }
}

/// A tea cart, so Chai Anna can be wherever the people are.
class TeaCart extends PositionComponent {
  TeaCart({required double x}) : super(position: Vector2(x, 0), priority: 3);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-30, 186, 30, 222),
      fillOf(KathaInk.leaf),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-32, 182, 32, 188),
      fillOf(KathaInk.leafShade),
    );
    for (final x in [-20.0, 20.0]) {
      canvas.drawCircle(Offset(x, 226), 7, fillOf(KathaInk.ink));
      canvas.drawCircle(Offset(x, 226), 2.4, fillOf(KathaInk.shutter));
    }
    // A steel kettle and a row of glasses.
    canvas.drawOval(
      const Rect.fromLTRB(-24, 166, -6, 184),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!),
    );
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(2 + i * 6.0, 174, 4.4, 9),
        fillOf(Color.lerp(KathaInk.marigold, KathaInk.brick, 0.4)!),
      );
    }
  }
}

// =============================================================================
// The new poster
// =============================================================================
