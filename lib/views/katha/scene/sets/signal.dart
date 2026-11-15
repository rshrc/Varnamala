import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:words625/views/katha/scene/engine/idle_bit.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';

/// `bg.signal`: stuck at a red light. A banyan with a roadside shrine at its
/// foot, a sugarcane juice cart, a chemist's green cross, and a zebra
/// crossing nobody uses.
class SignalBackdrop extends PositionComponent {
  SignalBackdrop() : super(priority: -10);

  late final Picture _picture = () {
    final recorder = PictureRecorder();
    _paint(Canvas(recorder));
    return recorder.endRecording();
  }();

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = KathaInk.paper,
    );
    final cloud = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8);
    for (final (x, y) in [(150.0, 30.0), (300.0, 22.0)]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 44, height: 11),
        cloud,
      );
      canvas.drawCircle(Offset(x - 7, y - 5), 8, cloud);
      canvas.drawCircle(Offset(x + 6, y - 6), 9, cloud);
    }

    // Skyline.
    final building = Paint()..color = KathaInk.skyline;
    final window = Paint()..color = KathaInk.skylineWindow;
    const blocks = [
      (100.0, 50.0, 104.0),
      (148.0, 44.0, 132.0),
      (190.0, 60.0, 92.0),
      (248.0, 40.0, 120.0),
      (286.0, 56.0, 100.0),
      (340.0, 60.0, 128.0),
    ];
    for (var i = 0; i < blocks.length; i++) {
      final (x, w, h) = blocks[i];
      canvas.drawRect(Rect.fromLTWH(x, 182 - h, w, h), building);
      for (var row = 0; row < (h - 14) ~/ 14; row++) {
        for (var col = 0; col < (w - 8) ~/ 10; col++) {
          if ((i * 5 + row * 7 + col * 3) % 5 == 0) continue;
          canvas.drawRect(
            Rect.fromLTWH(x + 6 + col * 10, 182 - h + 8 + row * 14, 4, 6),
            window,
          );
        }
      }
    }
    // A mobile tower on a roof.
    final mast = Paint()
      ..color = KathaInk.skyline
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(168, 50), const Offset(168, 14), mast);
    canvas.drawLine(const Offset(162, 26), const Offset(174, 26), mast);
    canvas.drawLine(const Offset(163, 36), const Offset(173, 36), mast);

    _juiceCart(canvas);
    _chemist(canvas);
    _banyan(canvas);

    // Footpath, kerb, road.
    canvas.drawRect(
      const Rect.fromLTRB(0, 202, kathaWorldWidth, 222),
      Paint()..color = KathaInk.footpath,
    );
    for (var x = 0.0; x < kathaWorldWidth; x += 16) {
      canvas.drawRect(
        Rect.fromLTWH(x, 220, 8, 5),
        Paint()..color = KathaInk.ink,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 8, 220, 8, 5),
        Paint()..color = KathaInk.paper,
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(0, 225, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = KathaInk.road,
    );
    // Zebra crossing, ahead of the stop line.
    final stripe = Paint()..color = KathaInk.paper.withValues(alpha: 0.8);
    for (var x = 160.0; x < 204; x += 9) {
      canvas.drawRect(Rect.fromLTWH(x, 228, 5, 30), stripe);
    }
    canvas.drawRect(const Rect.fromLTWH(208, 228, 2.5, 30), stripe);
  }

  /// A banyan, roots hanging from its branches, with a small painted stone
  /// shrine at its foot that someone has given fresh marigolds today.
  static void _banyan(Canvas canvas) {
    final bark = Paint()..color = KathaInk.brickShade;
    canvas.drawPath(
      Path()
        ..moveTo(42, 204)
        ..cubicTo(48, 170, 46, 130, 52, 96)
        ..lineTo(66, 96)
        ..cubicTo(70, 130, 70, 170, 80, 204)
        ..close(),
      bark,
    );
    final root = Paint()
      ..color = KathaInk.brickShade.withValues(alpha: 0.8)
      ..strokeWidth = 1.2;
    final leaf = Paint()..color = KathaInk.leaf;
    final leafLight = Paint()
      ..color = Color.lerp(KathaInk.leaf, KathaInk.paper, 0.25)!;
    for (final (x, y, r) in [
      (20.0, 92.0, 30.0),
      (60.0, 70.0, 36.0),
      (100.0, 88.0, 30.0),
      (0.0, 110.0, 22.0),
      (122.0, 106.0, 18.0),
    ]) {
      canvas.drawCircle(Offset(x, y), r, leaf);
    }
    for (final (x, y, r) in [
      (46.0, 62.0, 16.0),
      (86.0, 78.0, 12.0),
      (14.0, 84.0, 12.0),
    ]) {
      canvas.drawCircle(Offset(x, y), r, leafLight);
    }
    for (final x in [14.0, 26.0, 92.0, 104.0, 116.0]) {
      canvas.drawLine(Offset(x, 112), Offset(x + 1, 150 + (x % 3) * 10), root);
    }
    // The shrine: a stone daubed in vermilion and white, a few flowers.
    canvas.drawRRect(
      RRect.fromLTRBR(82, 190, 98, 204, const Radius.circular(5)),
      Paint()..color = KathaInk.brick,
    );
    canvas.drawRect(
      const Rect.fromLTRB(82, 195, 98, 197.6),
      Paint()..color = KathaInk.paper,
    );
    for (final x in [84.0, 90.0, 96.0]) {
      canvas.drawCircle(
        Offset(x, 205),
        2.2,
        Paint()..color = KathaInk.marigold,
      );
    }
  }

  static void _juiceCart(Canvas canvas) {
    // Canopy.
    canvas.drawPath(
      Path()
        ..moveTo(114, 150)
        ..lineTo(172, 150)
        ..lineTo(166, 140)
        ..lineTo(120, 140)
        ..close(),
      Paint()..color = KathaInk.leaf,
    );
    final pole = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(120, 150), const Offset(120, 184), pole);
    canvas.drawLine(const Offset(166, 150), const Offset(166, 184), pole);
    canvas.drawRect(
      const Rect.fromLTRB(112, 182, 174, 196),
      Paint()..color = KathaInk.marigold,
    );
    // Sugarcane stacked against the cart.
    final cane = Paint()
      ..color = Color.lerp(KathaInk.leaf, KathaInk.marigold, 0.4)!
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(176 + i * 2.0, 200),
        Offset(171 + i * 2.5, 156),
        cane,
      );
    }
    // The crusher's big wheel, and a glass of juice waiting.
    canvas.drawCircle(
      const Offset(132, 172),
      9,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(const Offset(123, 172), const Offset(141, 172), pole);
    canvas.drawRect(
      const Rect.fromLTRB(152, 172, 157, 182),
      Paint()..color = Color.lerp(KathaInk.leaf, KathaInk.paper, 0.5)!,
    );
    canvas.drawCircle(const Offset(124, 200), 5, Paint()..color = KathaInk.ink);
    canvas.drawCircle(const Offset(162, 200), 5, Paint()..color = KathaInk.ink);
  }

  static void _chemist(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(340, 130, 400, 204),
      Paint()..color = KathaInk.shopWall,
    );
    canvas.drawRect(
      const Rect.fromLTRB(346, 156, 394, 204),
      Paint()..color = KathaInk.shutter,
    );
    // The green cross every chemist hangs out.
    final cross = Paint()..color = KathaInk.leaf;
    canvas.drawRect(const Rect.fromLTRB(362, 134, 372, 152), cross);
    canvas.drawRect(const Rect.fromLTRB(358, 138, 376, 148), cross);
  }
}

/// The traffic light. Red until a cue turns it green.
class TrafficSignal extends KathaActor {
  TrafficSignal({required super.actorId})
    : super(linkColor: KathaInk.leaf, position: Vector2(28, 118), priority: 1);

  bool green = false;

  @override
  Offset get glowCentre => Offset(7, green ? 28 : 6);

  @override
  double get glowRadius => 18;

  @override
  Vector2 get bubbleAnchor => Vector2(7, -4);

  @override
  double perform(String anim, double seconds) {
    if (anim != 'go_green') return 0;
    green = true;
    glow();
    return 0.9;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(5.5, 34, 8.5, 98),
      Paint()..color = KathaInk.ink,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(0, -2, 14, 36, const Radius.circular(3)),
      Paint()..color = KathaInk.ink,
    );
    final off = Paint()..color = KathaInk.ink.withValues(alpha: 0.6);
    canvas.drawCircle(
      const Offset(7, 6),
      4,
      green ? off : (Paint()..color = KathaInk.brick),
    );
    canvas.drawCircle(const Offset(7, 17), 4, off);
    canvas.drawCircle(
      const Offset(7, 28),
      4,
      green ? (Paint()..color = KathaInk.leaf) : off,
    );
    super.render(canvas);
  }
}

/// The cow that has decided the middle of the road is where she lives now.
/// Painted horns and a bell, chewing, entirely unbothered by horns. Leaves
/// when she is ready, which is after the light has already turned.
class RoadCow extends KathaActor {
  RoadCow({required super.actorId, required super.position})
    : super(linkColor: KathaInk.brick, priority: 1);

  static final _hide = Color.lerp(KathaInk.paper, KathaInk.khaki, 0.3)!;
  static final _hideShade = Color.lerp(_hide, KathaInk.ink, 0.12)!;
  static final _patch = Color.lerp(KathaInk.khakiShade, KathaInk.ink, 0.25)!;
  static final _muzzle = Color.lerp(KathaInk.brick, KathaInk.paper, 0.5)!;

  double _chewLeft = 0;
  double _walkLeft = 0;
  double _clock = 0;
  double _headLift = 0;
  double _liftLeft = 0;

  @override
  Offset get glowCentre => const Offset(4, -30);

  @override
  double get glowRadius => 46;

  @override
  Vector2 get bubbleAnchor => Vector2(30, -60);

  @override
  double perform(String anim, double seconds) {
    switch (anim) {
      case 'chew':
        _chewLeft = math.max(1.4, seconds);
        return _chewLeft;
      case 'look':
        // Lifts her head and stares straight back at Raju. Chewing.
        _liftLeft = 1.8;
        _chewLeft = 1.8;
        return 1.8;
      case 'walk_off':
        if (game.reducedMotion) {
          position.x = -80;
          return 0.05;
        }
        // Turns round, ambles off the way she came.
        scale.x = -1;
        _walkLeft = math.max(2.4, seconds);
        add(
          MoveByEffect(
            Vector2(-190, 0),
            EffectController(duration: _walkLeft, curve: Curves.easeIn),
          ),
        );
        return _walkLeft + 0.1;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_chewLeft > 0) _chewLeft -= dt;
    if (_walkLeft > 0) _walkLeft -= dt;
    if (_liftLeft > 0) {
      _liftLeft -= dt;
      _headLift = math.min(1, _headLift + dt * 5);
    } else {
      _headLift = math.max(0, _headLift - dt * 4);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final walking = _walkLeft > 0 && !game.reducedMotion;
    final step = walking ? math.sin(_clock * 12) * 3 : 0.0;
    final bob = walking ? math.sin(_clock * 24).abs() * 1.2 : 0.0;
    final hoof = Paint()..color = KathaInk.ink;

    // Far legs, then near legs.
    for (final (x, swing, near) in [
      (-17.0, -step, false),
      (15.0, step, false),
      (-21.0, step, true),
      (19.0, -step, true),
    ]) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          x - 3 + swing,
          -22,
          x + 3 + swing,
          -2,
          const Radius.circular(2),
        ),
        Paint()..color = near ? _hide : _hideShade,
      );
      canvas.drawRect(Rect.fromLTRB(x - 3 + swing, -3, x + 3 + swing, 0), hoof);
    }

    canvas.save();
    canvas.translate(0, -bob);
    // Tail, swishing.
    final swish = math.sin(_clock * 3) * 0.3;
    canvas.save();
    canvas.translate(-28, -38);
    canvas.rotate(0.2 + swish);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-6, 10, -3, 22),
      Paint()
        ..color = _hideShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawOval(
      const Rect.fromLTRB(-6, 20, 0, 28),
      Paint()..color = KathaInk.ink,
    );
    canvas.restore();

    // Body, hump, patches, dewlap.
    canvas.drawRRect(
      RRect.fromLTRBR(-30, -46, 24, -18, const Radius.circular(13)),
      Paint()..color = _hide,
    );
    canvas.drawCircle(const Offset(13, -45), 8.5, Paint()..color = _hide);
    canvas.drawOval(
      const Rect.fromLTRB(-18, -42, -4, -30),
      Paint()..color = _patch,
    );
    canvas.drawOval(
      const Rect.fromLTRB(2, -30, 12, -22),
      Paint()..color = _patch,
    );
    canvas.drawPath(
      Path()
        ..moveTo(18, -34)
        ..quadraticBezierTo(30, -22, 24, -16)
        ..quadraticBezierTo(20, -22, 16, -24)
        ..close(),
      Paint()..color = _hideShade,
    );
    // Bell on a marigold cord.
    canvas.drawLine(
      const Offset(22, -34),
      const Offset(27, -26),
      Paint()
        ..color = KathaInk.marigold
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(
      const Offset(27.5, -24),
      2.6,
      Paint()..color = KathaInk.marigoldShade,
    );

    // Head, pivoting at the neck.
    canvas.save();
    canvas.translate(24, -38);
    canvas.rotate(-0.35 * _headLift);
    final chew = _chewLeft > 0 ? math.sin(_clock * 14).abs() * 1.6 : 0.0;
    canvas.drawPath(
      Path()
        ..moveTo(0, -8)
        ..quadraticBezierTo(14, -10, 20, 2)
        ..quadraticBezierTo(16, 8, 4, 6)
        ..close(),
      Paint()..color = _hide,
    );
    canvas.drawOval(
      Rect.fromLTRB(14, -1, 23, 6 + chew),
      Paint()..color = _muzzle,
    );
    canvas.drawCircle(const Offset(20.5, 1.6), 0.9, hoof);
    // Ear, and horns painted at the tips the way festival cows are.
    canvas.drawOval(
      const Rect.fromLTRB(-6, -6, 3, -1),
      Paint()..color = _hideShade,
    );
    final horn = Paint()
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(4, -8)
        ..quadraticBezierTo(2, -15, 7, -18),
      horn..color = _hideShade,
    );
    canvas.drawLine(
      const Offset(5.6, -16),
      const Offset(7, -18),
      horn..color = KathaInk.brick,
    );
    // An eye with lashes, half-closed in perfect calm.
    canvas.drawCircle(const Offset(10, -3), 1.8, hoof);
    canvas.drawArc(
      const Rect.fromLTRB(7.6, -5.6, 12.4, -1.4),
      math.pi,
      math.pi,
      true,
      Paint()..color = _hide,
    );
    canvas.drawLine(
      const Offset(8, -3.6),
      const Offset(12.2, -3.6),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 0.9,
    );
    canvas.restore();
    canvas.restore();
  }
}

/// A monkey on a banyan branch, scratching its head now and then.
class BanyanMonkey extends IdleBit {
  BanyanMonkey()
    : super(seconds: 1.4, chance: 0.6, position: Vector2(104, 108));

  static final _fur = Color.lerp(KathaInk.khakiShade, KathaInk.ink, 0.15)!;
  static final _face = Color.lerp(KathaInk.brick, KathaInk.paper, 0.45)!;

  @override
  void render(Canvas canvas) {
    final fur = Paint()..color = _fur;
    // The branch it sits on.
    canvas.drawLine(
      const Offset(-26, 6),
      const Offset(22, 2),
      Paint()
        ..color = KathaInk.brickShade
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );
    // Tail hanging down in a curl.
    canvas.drawPath(
      Path()
        ..moveTo(-4, 2)
        ..quadraticBezierTo(-10, 16, -4, 24)
        ..quadraticBezierTo(0, 28, 2, 23),
      Paint()
        ..color = _fur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawOval(const Rect.fromLTRB(-7, -10, 7, 4), fur);
    canvas.drawCircle(const Offset(0, -14), 5.4, fur);
    canvas.drawOval(
      const Rect.fromLTRB(-3.4, -16, 3.4, -10),
      Paint()..color = _face,
    );
    final eye = Paint()..color = KathaInk.ink;
    canvas.drawCircle(const Offset(-1.4, -14.2), 0.7, eye);
    canvas.drawCircle(const Offset(1.4, -14.2), 0.7, eye);
    // The scratching arm: up to the head and back while it plays.
    final lift = math.sin(t * math.pi);
    final scratch = math.sin(t * math.pi * 8) * 0.6 * lift;
    canvas.save();
    canvas.translate(5, -6);
    canvas.rotate(-0.4 - lift * 2.2 + scratch * 0.3);
    canvas.drawLine(
      Offset.zero,
      const Offset(0, 9),
      Paint()
        ..color = _fur
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }
}
