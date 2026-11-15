import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// `bg.kitchen`: the landlady's kitchen. Tiles to shoulder height, a granite
/// counter on the right with a two-burner stove and the cooker on it, the red
/// cylinder underneath, steel tins on a shelf, and a window on the left with a
/// crow on the sill.
class KitchenBackdrop extends PositionComponent {
  KitchenBackdrop() : super(priority: -10);

  late final Picture _picture = recordPicture(_paint);

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    final wall = Color.lerp(KathaInk.paper, KathaInk.marigold, 0.3)!;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, 226),
      fillOf(wall),
    );
    // Tiles from the counter up to shoulder height.
    const tiles = Rect.fromLTRB(0, 96, kathaWorldWidth, 226);
    canvas.drawRect(
      tiles,
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.12)!),
    );
    final grout = strokeOf(KathaInk.ink.withValues(alpha: 0.08), 0.8);
    for (var x = 0.0; x <= 400; x += 16) {
      canvas.drawLine(Offset(x, 96), Offset(x, 226), grout);
    }
    for (var y = 96.0; y <= 226; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(400, y), grout);
    }
    // A band of patterned tiles: someone chose these in 1994.
    for (var x = 0.0; x < 400; x += 16) {
      canvas.drawRect(
        Rect.fromLTWH(x + 2, 98, 12, 12),
        fillOf(KathaInk.teal.withValues(alpha: 0.35)),
      );
      canvas.drawCircle(Offset(x + 8, 104), 2.4, fillOf(KathaInk.marigold));
    }
    // Floor.
    canvas.drawRect(
      const Rect.fromLTRB(0, 226, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(KathaInk.brick, KathaInk.ink, 0.18)!),
    );

    // The window, left: a grille, sky, a crow on the sill.
    const win = Rect.fromLTRB(26, 30, 112, 92);
    canvas.drawRect(
      win,
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.25)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(26, 64, 112, 92),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.45)!),
    );
    for (var x = win.left + 9; x < win.right; x += 11) {
      canvas.drawLine(
        Offset(x, win.top),
        Offset(x, win.bottom),
        strokeOf(KathaInk.ink, 1.2),
      );
    }
    canvas.drawRect(win, strokeOf(KathaInk.brickShade, 3));
    canvas.drawRect(
      const Rect.fromLTRB(22, 92, 116, 97),
      fillOf(KathaInk.paper),
    );
    // Crow.
    canvas.drawOval(const Rect.fromLTRB(86, 78, 104, 91), fillOf(KathaInk.ink));
    canvas.drawCircle(const Offset(102, 78), 4.5, fillOf(KathaInk.ink));
    canvas.drawPath(
      Path()
        ..moveTo(106, 77)
        ..lineTo(112, 79)
        ..lineTo(106, 80)
        ..close(),
      fillOf(KathaInk.shutter),
    );

    // Calendar and a wall clock.
    canvas.drawRect(
      const Rect.fromLTRB(140, 26, 172, 70),
      fillOf(KathaInk.paper),
    );
    canvas.drawRect(
      const Rect.fromLTRB(140, 26, 172, 40),
      fillOf(KathaInk.leaf),
    );
    canvas.drawCircle(const Offset(206, 46), 13, fillOf(KathaInk.paper));
    canvas.drawCircle(const Offset(206, 46), 13, strokeOf(KathaInk.ink, 1.6));
    canvas.drawLine(
      const Offset(206, 46),
      const Offset(206, 37),
      strokeOf(KathaInk.ink, 1.4),
    );
    canvas.drawLine(
      const Offset(206, 46),
      const Offset(212, 50),
      strokeOf(KathaInk.ink, 1.4),
    );

    // The shelf of steel tins, right.
    canvas.drawRect(
      const Rect.fromLTRB(236, 70, 396, 74),
      fillOf(KathaInk.brickShade),
    );
    final steel = Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!;
    for (var i = 0; i < 7; i++) {
      final x = 244.0 + i * 21;
      final h = 18.0 + (i % 3) * 5;
      canvas.drawRRect(
        RRect.fromLTRBR(x, 70 - h, x + 16, 70, const Radius.circular(2)),
        fillOf(steel),
      );
      canvas.drawRect(
        Rect.fromLTRB(x + 2, 70 - h, x + 5, 70),
        fillOf(KathaInk.paper.withValues(alpha: 0.4)),
      );
      canvas.drawRect(
        Rect.fromLTRB(x - 1, 68 - h, x + 17, 71 - h),
        fillOf(Color.lerp(steel, KathaInk.ink, 0.2)!),
      );
    }
    // Ladles hanging on hooks.
    for (final x in [250.0, 262.0, 274.0]) {
      canvas.drawLine(Offset(x, 82), Offset(x, 112), strokeOf(steel, 1.6));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 114), width: 7, height: 5),
        fillOf(steel),
      );
    }

    // The counter: black granite on a cabinet, the stove on top.
    canvas.drawRect(
      const Rect.fromLTRB(226, 150, 400, 226),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.brick, 0.35)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(220, 142, 400, 152),
      fillOf(KathaInk.ink),
    );
    canvas.drawRect(
      const Rect.fromLTRB(220, 142, 400, 144),
      fillOf(KathaInk.paper.withValues(alpha: 0.25)),
    );
    // An open cabinet under the stove, and the red cylinder in it.
    canvas.drawRect(
      const Rect.fromLTRB(300, 158, 368, 222),
      fillOf(KathaInk.interior),
    );
    gasCylinder(canvas, const Offset(334, 220), height: 52);
    canvas.drawLine(
      const Offset(334, 168),
      const Offset(318, 152),
      strokeOf(KathaInk.ink, 1.6),
    );
    // Cabinet doors.
    for (final l in [232.0, 372.0]) {
      canvas.drawRect(
        Rect.fromLTRB(l, 160, l + 24, 220),
        fillOf(Color.lerp(KathaInk.paper, KathaInk.brick, 0.5)!),
      );
      canvas.drawCircle(Offset(l + 19, 190), 1.6, fillOf(KathaInk.ink));
    }
    // The stove, steel, two burners.
    canvas.drawRRect(
      RRect.fromLTRBR(266, 132, 384, 144, const Radius.circular(2)),
      fillOf(steel),
    );
    for (final x in [292.0, 352.0]) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, 131), width: 30, height: 3),
        fillOf(KathaInk.ink),
      );
    }
    canvas.drawCircle(const Offset(278, 139), 2.4, fillOf(KathaInk.ink));
    canvas.drawCircle(const Offset(372, 139), 2.4, fillOf(KathaInk.ink));
  }
}

/// The red LPG cylinder, standing with its base at [base]: a domed body, the
/// collar it is carried by, and the regulator on top.
void gasCylinder(Canvas canvas, Offset base, {double height = 48}) {
  final w = height * 0.46;
  final body = RRect.fromLTRBR(
    base.dx - w / 2,
    base.dy - height,
    base.dx + w / 2,
    base.dy,
    Radius.circular(w * 0.42),
  );
  canvas.drawRRect(body, fillOf(KathaInk.brick));
  canvas.save();
  canvas.clipRRect(body);
  canvas.drawRect(
    Rect.fromLTRB(base.dx + w * 0.18, body.top, body.right, body.bottom),
    fillOf(KathaInk.ink.withValues(alpha: 0.18)),
  );
  canvas.drawRect(
    Rect.fromLTRB(body.left + 3, body.top, body.left + 6, body.bottom),
    fillOf(KathaInk.paper.withValues(alpha: 0.28)),
  );
  canvas.restore();
  // Base ring and the collar on top.
  canvas.drawRect(
    Rect.fromLTRB(body.left + 1, base.dy - 3, body.right - 1, base.dy),
    fillOf(KathaInk.brickShade),
  );
  final collar = Rect.fromLTRB(
    base.dx - w * 0.34,
    body.top - height * 0.14,
    base.dx + w * 0.34,
    body.top + 4,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(collar, const Radius.circular(3)),
    fillOf(KathaInk.brickShade),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(collar.deflate(2.4), const Radius.circular(2)),
    fillOf(KathaInk.interior),
  );
  canvas.drawRect(
    Rect.fromCenter(center: Offset(base.dx, body.top - 1), width: 6, height: 7),
    fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.35)!),
  );
}

/// The blue flame on the front burner. `out` puts it out with a pop; `light`
/// brings it back.
class StoveFlame extends KathaActor {
  StoveFlame({required super.actorId, this.lit = true})
    : super(
        linkColor: KathaInk.teal,
        position: Vector2(292, 129),
        priority: -5,
      );

  bool lit;
  double _clock = 0;
  double _dying = 0;

  @override
  Offset get glowCentre => const Offset(0, -4);
  @override
  double get glowRadius => 24;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -20);

  @override
  double perform(String anim, double seconds) {
    switch (anim) {
      case 'out':
        lit = false;
        _dying = 0.5;
        return 0.6;
      case 'light':
        lit = true;
        return 1.2;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_dying > 0) _dying = math.max(0, _dying - dt);
  }

  @override
  void render(Canvas canvas) {
    // The pot on the burner is drawn by the flame, so it sits over it.
    final scale = lit ? 1.0 : _dying / 0.5;
    if (scale > 0.02) {
      for (var i = 0; i < 7; i++) {
        final x = -12 + i * 4.0;
        final h = (6 + 2.4 * math.sin(_clock * 18 + i * 1.7)) * scale;
        canvas.drawPath(
          Path()
            ..moveTo(x - 2, 0)
            ..quadraticBezierTo(x, -h * 1.4, x + 2, 0)
            ..close(),
          fillOf(const Color(0xFF4F8CE0).withValues(alpha: 0.85)),
        );
      }
    } else {
      // A wisp of smoke where the flame was.
      canvas.drawCircle(
        const Offset(-2, -8),
        2.4,
        fillOf(KathaInk.shutter.withValues(alpha: 0.5)),
      );
    }
    // A steel pot of bisi bele bath, simmering.
    canvas.drawRRect(
      RRect.fromLTRBR(-20, -30, 20, -4, const Radius.circular(4)),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-22, -32, 22, -28),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.42)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-14, -26, -10, -6),
      fillOf(KathaInk.paper.withValues(alpha: 0.35)),
    );
  }
}

/// The pressure cooker on the back burner. `whistle` lifts its weight and
/// lets off a column of steam, with a squeal you can see.
class PressureCooker extends KathaActor {
  PressureCooker({required super.actorId})
    : super(
        linkColor: KathaInk.marigold,
        position: Vector2(352, 129),
        priority: -5,
      );

  double _whistle = 0;

  @override
  Offset get glowCentre => const Offset(0, -20);
  @override
  double get glowRadius => 26;
  @override
  Vector2 get bubbleAnchor => Vector2(0, -44);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'whistle') return 0;
    _whistle = game.reducedMotion ? 0 : 1.0;
    return 1.1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_whistle > 0) _whistle = math.max(0, _whistle - dt);
  }

  @override
  void render(Canvas canvas) {
    final steel = Color.lerp(KathaInk.paper, KathaInk.ink, 0.28)!;
    canvas.drawRRect(
      RRect.fromLTRBR(-17, -30, 17, 0, const Radius.circular(7)),
      fillOf(steel),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-11, -26, -7, -4),
      fillOf(KathaInk.paper.withValues(alpha: 0.4)),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(-19, -34, 19, -28, const Radius.circular(3)),
      fillOf(Color.lerp(steel, KathaInk.ink, 0.2)!),
    );
    // Black handle, sticking out to the right.
    canvas.drawRRect(
      RRect.fromLTRBR(16, -33, 40, -28, const Radius.circular(2)),
      fillOf(KathaInk.ink),
    );
    final lift = _whistle > 0 ? 3 + 2 * math.sin(_whistle * 40) : 0.0;
    canvas.drawRect(
      Rect.fromLTRB(-3, -40 - lift, 3, -34 - lift),
      fillOf(KathaInk.ink),
    );
    if (_whistle > 0) {
      final t = 1 - _whistle;
      for (var i = 0; i < 6; i++) {
        final p = (t * 1.6 + i * 0.16) % 1.0;
        canvas.drawCircle(
          Offset(math.sin(i * 2.1) * 6 * p, -44 - p * 52),
          3 + p * 7,
          fillOf(KathaInk.paper.withValues(alpha: 0.8 * (1 - p))),
        );
      }
      // Lines of the shriek.
      final shriek = strokeOf(
        KathaInk.ink.withValues(alpha: 0.5 * _whistle),
        1.2,
      );
      for (final side in [-1.0, 1.0]) {
        canvas.drawLine(Offset(side * 10, -50), Offset(side * 20, -58), shriek);
        canvas.drawLine(Offset(side * 12, -42), Offset(side * 24, -44), shriek);
      }
    }
  }
}

/// A cylinder standing by Chai Anna's counter: the spare.
class SpareCylinder extends PositionComponent {
  SpareCylinder({required Vector2 at}) : super(position: at, priority: 4);

  @override
  void render(Canvas canvas) => gasCylinder(canvas, Offset.zero, height: 46);
}

/// The cylinder riding in the back of Raju's auto, beside Dev, belted in by
/// his arm: a VIP.
class CylinderPassenger extends PositionComponent {
  CylinderPassenger({required double x})
    : super(position: Vector2(x, 216), priority: 1);

  @override
  void render(Canvas canvas) => gasCylinder(canvas, Offset.zero, height: 44);
}
