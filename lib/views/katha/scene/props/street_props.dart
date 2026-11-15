import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';
import 'package:words625/views/katha/scene/sets/chai_stall.dart';
import 'package:words625/views/katha/scene/sets/ward_meeting.dart';

/// The private water tanker, parked at the gate on a dry morning, and the
/// queue of buckets waiting for it.
class WaterTanker extends PositionComponent {
  WaterTanker() : super(priority: -2);

  @override
  void render(Canvas canvas) {
    const blue = Color(0xFF2E6FA8);
    canvas.drawRRect(
      RRect.fromLTRBR(300, 140, 420, 196, const Radius.circular(26)),
      fillOf(blue),
    );
    canvas.drawRect(
      const Rect.fromLTRB(300, 166, 420, 170),
      fillOf(KathaInk.paper),
    );
    TextPainterLite.digits(
      '₹2000',
      12,
      KathaInk.paper,
    ).paint(canvas, const Offset(318, 146));
    canvas.drawCircle(const Offset(330, 206), 10, fillOf(KathaInk.ink));
    canvas.drawCircle(const Offset(330, 206), 4, fillOf(KathaInk.khaki));
    canvas.drawRect(
      const Rect.fromLTRB(300, 194, 420, 200),
      fillOf(KathaInk.ink),
    );
    // Hose, dripping into nothing.
    canvas.drawPath(
      Path()
        ..moveTo(304, 186)
        ..quadraticBezierTo(286, 200, 292, 214),
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // The bucket queue.
    final colours = [
      KathaInk.brick,
      KathaInk.leaf,
      KathaInk.marigold,
      KathaInk.teal,
      KathaInk.brick,
    ];
    for (var i = 0; i < colours.length; i++) {
      final x = 232.0 + i * 13;
      canvas.drawPath(
        Path()
          ..moveTo(x - 5, 204)
          ..lineTo(x + 5, 204)
          ..lineTo(x + 4, 216)
          ..lineTo(x - 4, 216)
          ..close(),
        fillOf(colours[i]),
      );
    }
  }
}

/// A roasted-corn cart: wheels, a coal brazier glowing, cobs stacked, a big
/// striped umbrella, smoke going up.
class CornCart extends PositionComponent {
  CornCart({required double x}) : super(position: Vector2(x, 0), priority: -1);

  @override
  Future<void> onLoad() async {
    add(KettleSteam(at: Vector2(0, 168)));
  }

  @override
  void render(Canvas canvas) {
    // Umbrella.
    canvas.drawLine(
      const Offset(0, 104),
      const Offset(0, 176),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 2,
    );
    final canopy = Path()
      ..moveTo(-38, 120)
      ..quadraticBezierTo(0, 82, 38, 120)
      ..close();
    canvas.drawPath(canopy, fillOf(KathaInk.brick));
    canvas.save();
    canvas.clipPath(canopy);
    for (var x = -38.0; x < 38; x += 16) {
      canvas.drawRect(Rect.fromLTRB(x, 80, x + 8, 122), fillOf(KathaInk.paper));
    }
    canvas.restore();
    // Cart.
    canvas.drawRect(
      const Rect.fromLTRB(-30, 176, 30, 196),
      fillOf(KathaInk.brickShade),
    );
    canvas.drawCircle(const Offset(-20, 206), 9, fillOf(KathaInk.ink));
    canvas.drawCircle(const Offset(20, 206), 9, fillOf(KathaInk.ink));
    // Brazier with coals.
    canvas.drawRect(
      const Rect.fromLTRB(-12, 166, 12, 176),
      fillOf(KathaInk.ink),
    );
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(-8 + i * 5.0, 165),
        3,
        fillOf(const Color(0xFFFF7A3D)),
      );
    }
    // Cobs.
    for (var i = 0; i < 4; i++) {
      final o = Offset(16 + i * 3.0, 172 - i * 2.0);
      canvas.drawOval(
        Rect.fromCenter(center: o, width: 12, height: 5),
        fillOf(KathaInk.marigold),
      );
    }
  }
}

/// A pothole in the road. `bump` drops the whole picture into it and out
/// again: the auto, the passengers, the cylinder, the street.
class Pothole extends KathaActor {
  Pothole({required super.actorId, required Vector2 at})
    : super(linkColor: KathaInk.ink, position: at, priority: 3);

  @override
  Offset get glowCentre => Offset.zero;
  @override
  double get glowRadius => 20;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -20);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'bump' || game.reducedMotion) return 0;
    game.camera.viewfinder.add(
      SequenceEffect([
        MoveByEffect(Vector2(0, -7), EffectController(duration: 0.07)),
        MoveByEffect(Vector2(0, 11), EffectController(duration: 0.09)),
        MoveByEffect(Vector2(0, -6), EffectController(duration: 0.08)),
        MoveByEffect(Vector2(0, 2), EffectController(duration: 0.08)),
      ]),
    );
    return 0.5;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawOval(
      const Rect.fromLTRB(-26, -6, 26, 6),
      fillOf(Color.lerp(KathaInk.road, KathaInk.ink, 0.5)!),
    );
    canvas.drawOval(
      const Rect.fromLTRB(-20, -3, 18, 4),
      fillOf(Color.lerp(KathaInk.teal, KathaInk.ink, 0.45)!),
    );
    canvas.drawLine(
      const Offset(-12, -1),
      const Offset(4, -1),
      strokeOf(KathaInk.paper.withValues(alpha: 0.35), 1),
    );
  }
}

// =============================================================================
// The meeting room
// =============================================================================

/// The morning after the meeting, pasted over the old hoarding: the neta on
/// the left, beaming, and on the right, Dev, caught mid-surprise with his
/// mouth open. `reveal` unrolls it from the top.
class NewPoster extends KathaActor {
  NewPoster({required super.actorId, this.startShown = false})
    : super(
        linkColor: KathaInk.marigold,
        position: Vector2.zero(),
        priority: -6,
      );

  /// Already pasted up: every morning after the one it appeared.
  final bool startShown;

  late double _shown = startShown ? 1 : 0;
  bool _rolling = false;

  static const _board = Rect.fromLTRB(140, 44, 250, 112);

  @override
  Offset get glowCentre => _board.center;
  @override
  double get glowRadius => 46;
  @override
  Vector2 get bubbleAnchor => Vector2(_board.center.dx, _board.bottom);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'reveal') return 0;
    if (game.reducedMotion) {
      _shown = 1;
      return 0.05;
    }
    _rolling = true;
    return 1.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_rolling) {
      _shown = math.min(1, _shown + dt / 0.9);
      if (_shown >= 1) _rolling = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_shown <= 0) return;
    final visible = Rect.fromLTRB(
      _board.left,
      _board.top,
      _board.right,
      _board.top + _board.height * _shown,
    );
    canvas.save();
    canvas.clipRect(visible);
    canvas.drawRect(_board, fillOf(KathaInk.paper));
    final ray = fillOf(KathaInk.marigold.withValues(alpha: 0.35));
    const sun = Offset(195, 78);
    for (var i = 0; i < 16; i += 2) {
      final a = i * math.pi / 8, b = (i + 1) * math.pi / 8;
      canvas.drawPath(
        Path()
          ..moveTo(sun.dx, sun.dy)
          ..lineTo(sun.dx + math.cos(a) * 120, sun.dy + math.sin(a) * 120)
          ..lineTo(sun.dx + math.cos(b) * 120, sun.dy + math.sin(b) * 120)
          ..close(),
        ray,
      );
    }
    netaPortrait(canvas, const Offset(168, 72), 0.95);
    _devPortrait(canvas, const Offset(222, 72), 0.95);
    // The band for the words, which come from the telling.
    canvas.drawRect(
      Rect.fromLTRB(
        _board.left,
        _board.bottom - 12,
        _board.right,
        _board.bottom,
      ),
      fillOf(KathaInk.teal),
    );
    canvas.restore();
    // The paper's lower edge, still unrolling.
    if (_shown < 1) {
      canvas.drawRect(
        Rect.fromLTRB(
          _board.left - 2,
          visible.bottom - 3,
          _board.right + 2,
          visible.bottom + 3,
        ),
        fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.15)!),
      );
    }
  }

  /// Dev on the poster, startled: the photographer did not wait.
  static void _devPortrait(Canvas canvas, Offset c, double s) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(s);
    canvas.drawPath(
      Path()
        ..moveTo(-24, 40)
        ..quadraticBezierTo(-22, 16, 0, 14)
        ..quadraticBezierTo(22, 16, 24, 40)
        ..close(),
      fillOf(KathaInk.teal),
    );
    const skin = KathaInk.skinWarm;
    canvas.drawCircle(const Offset(-14, -1), 3, fillOf(skin));
    canvas.drawCircle(const Offset(14, -1), 3, fillOf(skin));
    canvas.drawOval(const Rect.fromLTRB(-14, -18, 14, 15), fillOf(skin));
    canvas.drawPath(
      Path()
        ..moveTo(-15, -2)
        ..cubicTo(-17, -20, -4, -27, 6, -24)
        ..cubicTo(14, -22, 17, -14, 15, -2)
        ..lineTo(12, -9)
        ..cubicTo(6, -15, -6, -14, -12, -8)
        ..close(),
      fillOf(KathaInk.ink),
    );
    // Eyes wide, mouth an O.
    for (final x in [-6.0, 6.0]) {
      canvas.drawCircle(Offset(x, -3), 3.4, fillOf(KathaInk.paper));
      canvas.drawCircle(Offset(x, -3), 1.6, fillOf(KathaInk.ink));
    }
    canvas.drawOval(const Rect.fromLTRB(-3, 5, 3, 11), fillOf(KathaInk.ink));
    canvas.restore();
  }
}

/// A loudspeaker cone strapped to the roof of Raju's auto. `announce` sends
/// sound out of it in rings.
class Loudspeaker extends KathaActor {
  Loudspeaker({required super.actorId, required Vector2 at})
    : super(linkColor: KathaInk.brick, position: at, priority: 4);

  double _on = 0;

  @override
  Offset get glowCentre => const Offset(0, 0);
  @override
  double get glowRadius => 16;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -14);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'announce' || game.reducedMotion) return 0;
    _on = math.max(2, seconds);
    return _on;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_on > 0) _on = math.max(0, _on - dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      const Offset(10, 4),
      const Offset(10, 16),
      strokeOf(KathaInk.ink, 1.6),
    );
    canvas.drawPath(
      Path()
        ..moveTo(4, -2)
        ..lineTo(-18, -10)
        ..lineTo(-18, 10)
        ..lineTo(4, 4)
        ..close(),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.2)!),
    );
    canvas.drawRect(const Rect.fromLTRB(4, -3, 14, 5), fillOf(KathaInk.ink));
    if (_on > 0) {
      for (var i = 0; i < 3; i++) {
        final r = 8.0 + ((i * 6 + _on * 30) % 18);
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(-18, 0), radius: r),
          math.pi * 0.75,
          math.pi * 0.5,
          false,
          strokeOf(KathaInk.brick.withValues(alpha: 0.7), 1.4),
        );
      }
    }
  }
}
