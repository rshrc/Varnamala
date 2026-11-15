import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// `bg.meeting_room`: a glass box with a view, a screen on the wall, and a
/// long table across the front. The table is drawn by [MeetingTable] so it
/// can stand in front of the people.
class MeetingRoomBackdrop extends PositionComponent {
  MeetingRoomBackdrop() : super(priority: -10);

  late final Picture _picture = recordPicture(_paint);

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.1)!),
    );
    // A window wall, left, with the city in it.
    const glass = Rect.fromLTRB(0, 0, 96, 226);
    canvas.drawRect(
      glass,
      fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.3)!),
    );
    final tower = fillOf(Color.lerp(KathaInk.paper, KathaInk.teal, 0.5)!);
    for (final (l, t, w) in [
      (0.0, 90.0, 24.0),
      (28.0, 60.0, 30.0),
      (64.0, 100.0, 28.0),
    ]) {
      canvas.drawRect(Rect.fromLTRB(l, t, l + w, 226), tower);
    }
    for (final x in [32.0, 64.0]) {
      canvas.drawRect(
        Rect.fromLTWH(x - 1, 0, 2, 226),
        fillOf(KathaInk.shutter),
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(96, 0, 102, 226),
      fillOf(KathaInk.shutter),
    );
    // A frosted band across the glass, at eye height.
    canvas.drawRect(
      const Rect.fromLTRB(0, 120, 96, 132),
      fillOf(KathaInk.paper.withValues(alpha: 0.55)),
    );
    // Carpet.
    canvas.drawRect(
      const Rect.fromLTRB(0, 226, kathaWorldWidth, kathaWorldHeight),
      fillOf(Color.lerp(KathaInk.ink, KathaInk.teal, 0.35)!),
    );
    // The screen's bezel; what is on it is [MeetingScreen].
    canvas.drawRRect(
      RRect.fromLTRBR(124, 16, 284, 114, const Radius.circular(4)),
      fillOf(KathaInk.ink),
    );
    canvas.drawRect(
      const Rect.fromLTRB(200, 114, 208, 122),
      fillOf(KathaInk.ink),
    );
    // A plant in the corner that someone waters, and a whiteboard doodle.
    canvas.drawRect(
      const Rect.fromLTRB(354, 190, 380, 226),
      fillOf(KathaInk.brick),
    );
    for (var i = 0; i < 7; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(356 + i * 4.0, 176 - (i % 3) * 10.0),
          width: 10,
          height: 22,
        ),
        fillOf(i.isEven ? KathaInk.leaf : KathaInk.leafShade),
      );
    }
    canvas.drawRect(
      const Rect.fromLTRB(300, 30, 392, 96),
      fillOf(KathaInk.paper),
    );
    canvas.drawRect(
      const Rect.fromLTRB(300, 30, 392, 96),
      strokeOf(KathaInk.shutter, 2),
    );
    final marker = strokeOf(KathaInk.teal, 1.6);
    canvas.drawPath(
      Path()
        ..moveTo(310, 86)
        ..lineTo(330, 72)
        ..lineTo(348, 78)
        ..lineTo(380, 44),
      marker,
    );
    canvas.drawLine(const Offset(372, 44), const Offset(380, 44), marker);
    canvas.drawLine(const Offset(380, 44), const Offset(380, 52), marker);
    // Two circles and an arrow: a plan nobody remembers.
    canvas.drawCircle(const Offset(318, 48), 7, strokeOf(KathaInk.brick, 1.4));
    canvas.drawCircle(const Offset(346, 52), 6, strokeOf(KathaInk.brick, 1.4));
  }
}

/// The meeting table, in front of everyone: a long top, its edge, and a laptop
/// at each place.
class MeetingTable extends PositionComponent {
  MeetingTable({required this.laptops}) : super(priority: 6);

  final List<double> laptops;

  @override
  void render(Canvas canvas) {
    final wood = Color.lerp(KathaInk.marigoldShade, KathaInk.ink, 0.25)!;
    canvas.drawRect(
      const Rect.fromLTRB(0, 196, kathaWorldWidth, 204),
      fillOf(Color.lerp(wood, KathaInk.paper, 0.2)!),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 204, kathaWorldWidth, kathaWorldHeight),
      fillOf(wood),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 204, kathaWorldWidth, 208),
      fillOf(KathaInk.ink.withValues(alpha: 0.25)),
    );
    for (final x in laptops) {
      // Lid, seen from behind, with a sticker.
      canvas.drawPath(
        Path()
          ..moveTo(x - 20, 198)
          ..lineTo(x - 17, 176)
          ..lineTo(x + 17, 176)
          ..lineTo(x + 20, 198)
          ..close(),
        fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.35)!),
      );
      canvas.drawCircle(Offset(x + 6, 186), 3, fillOf(KathaInk.marigold));
      canvas.drawRect(
        Rect.fromLTRB(x - 22, 197, x + 22, 200),
        fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.45)!),
      );
    }
    // A tea glass someone forgot.
    canvas.drawRect(
      const Rect.fromLTRB(150, 186, 158, 198),
      fillOf(
        Color.lerp(
          KathaInk.marigold,
          KathaInk.brick,
          0.4,
        )!.withValues(alpha: 0.8),
      ),
    );
  }
}

/// The screen on the meeting-room wall. It shows the client on a call; then
/// the app, a chart going up; then a crash, all red; then green again.
class MeetingScreen extends KathaActor {
  MeetingScreen({required super.actorId})
    : super(linkColor: KathaInk.teal, position: Vector2(128, 20), priority: -8);

  /// call | chart | crash | fix
  String _state = 'call';
  double _clock = 0;
  double _since = 0;
  double _clapping = 0;
  double _watch = 0;

  static const _w = 152.0, _h = 90.0;

  @override
  Offset get glowCentre => const Offset(_w / 2, _h / 2);
  @override
  double get glowRadius => 60;
  @override
  Vector2 get bubbleAnchor => Vector2(_w - 24, 30);

  @override
  double perform(String anim, double seconds) {
    _since = 0;
    switch (anim) {
      case 'call' || 'chart' || 'crash' || 'fix':
        _state = anim;
        return anim == 'crash' ? 1.4 : 1.2;
      case 'clap':
        _clapping = math.max(1.8, seconds);
        return _clapping;
      case 'watch':
        _watch = math.max(1.8, seconds);
        return _watch;
    }
    return 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    _since += dt;
    if (_clapping > 0) _clapping = math.max(0, _clapping - dt);
    if (_watch > 0) _watch = math.max(0, _watch - dt);
  }

  @override
  void render(Canvas canvas) {
    const screen = Rect.fromLTWH(0, 0, _w, _h);
    canvas.save();
    canvas.clipRect(screen);
    switch (_state) {
      case 'crash':
        final flash = _since < 0.6 && (_since * 10).floor().isEven;
        canvas.drawRect(
          screen,
          fillOf(flash ? KathaInk.paper : KathaInk.brick),
        );
        // Glitch bars.
        for (var i = 0; i < 6; i++) {
          final y = (i * 17 + _clock * 60) % _h;
          canvas.drawRect(
            Rect.fromLTWH((i * 23) % 40.0, y, 60 + (i * 31) % 70.0, 3),
            fillOf(KathaInk.ink.withValues(alpha: 0.25)),
          );
        }
        final cross = strokeOf(KathaInk.paper, 7);
        canvas.drawLine(const Offset(58, 26), const Offset(94, 62), cross);
        canvas.drawLine(const Offset(94, 26), const Offset(58, 62), cross);
      case 'fix' || 'chart':
        canvas.drawRect(screen, fillOf(KathaInk.paper));
        canvas.drawRect(
          const Rect.fromLTWH(0, 0, _w, 12),
          fillOf(KathaInk.teal),
        );
        final grow = math.min(1.0, _since / 0.9);
        final bars = [22.0, 34.0, 30.0, 48.0, 62.0];
        for (var i = 0; i < bars.length; i++) {
          final h = bars[i] * grow;
          canvas.drawRect(
            Rect.fromLTRB(16 + i * 18.0, 82 - h, 28 + i * 18.0, 82),
            fillOf(i == bars.length - 1 ? KathaInk.marigold : KathaInk.teal),
          );
        }
        // The client, small, in the corner of the call.
        _client(canvas, const Rect.fromLTWH(112, 18, 36, 30), small: true);
        if (_state == 'fix') {
          canvas.drawCircle(const Offset(126, 68), 13, fillOf(KathaInk.leaf));
          canvas.drawPath(
            Path()
              ..moveTo(119, 68)
              ..lineTo(124, 73)
              ..lineTo(133, 62),
            strokeOf(KathaInk.paper, 3),
          );
        }
      default:
        canvas.drawRect(
          screen,
          fillOf(Color.lerp(KathaInk.ink, KathaInk.teal, 0.5)!),
        );
        _client(canvas, const Rect.fromLTWH(30, 8, 92, 78), small: false);
    }
    canvas.restore();
    // Reflection across the glass.
    canvas.drawPath(
      Path()
        ..moveTo(_w - 40, 0)
        ..lineTo(_w - 20, 0)
        ..lineTo(_w - 60, _h)
        ..lineTo(_w - 80, _h)
        ..close(),
      fillOf(KathaInk.paper.withValues(alpha: 0.06)),
    );
  }

  /// The client: a grey suit, a pair of serious glasses, and a bookshelf
  /// arranged to look read.
  void _client(Canvas canvas, Rect tile, {required bool small}) {
    canvas.drawRect(
      tile,
      fillOf(Color.lerp(KathaInk.paper, KathaInk.marigold, 0.25)!),
    );
    final s = tile.width / 92;
    canvas.save();
    canvas.translate(tile.left, tile.top);
    canvas.scale(s);
    // Bookshelf.
    for (var i = 0; i < 9; i++) {
      canvas.drawRect(
        Rect.fromLTWH(4 + i * 9.5, 8, 7, 22),
        fillOf(
          [
            KathaInk.teal,
            KathaInk.brick,
            KathaInk.leaf,
          ][i % 3].withValues(alpha: 0.6),
        ),
      );
    }
    canvas.drawRect(
      const Rect.fromLTWH(0, 30, 92, 3),
      fillOf(KathaInk.brickShade),
    );
    // Suit and head.
    canvas.drawPath(
      Path()
        ..moveTo(14, 78)
        ..quadraticBezierTo(16, 56, 46, 54)
        ..quadraticBezierTo(76, 56, 78, 78)
        ..close(),
      fillOf(Color.lerp(KathaInk.ink, KathaInk.paper, 0.3)!),
    );
    canvas.drawPath(
      Path()
        ..moveTo(40, 56)
        ..lineTo(46, 70)
        ..lineTo(52, 56)
        ..close(),
      fillOf(KathaInk.paper),
    );
    final skin = Color.lerp(KathaInk.skinWarm, KathaInk.paper, 0.15)!;
    canvas.drawOval(const Rect.fromLTRB(32, 22, 60, 54), fillOf(skin));
    canvas.drawPath(
      Path()
        ..moveTo(32, 36)
        ..cubicTo(30, 18, 62, 16, 60, 36)
        ..lineTo(57, 30)
        ..cubicTo(50, 26, 40, 26, 35, 30)
        ..close(),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.45)!),
    );
    final frame = strokeOf(KathaInk.ink, 1.6);
    canvas.drawRect(const Rect.fromLTRB(36, 35, 45, 41), frame);
    canvas.drawRect(const Rect.fromLTRB(48, 35, 57, 41), frame);
    if (_clapping > 0) {
      // Smiling now, hands meeting in front of the camera.
      canvas.drawArc(
        const Rect.fromLTRB(40, 42, 52, 50),
        0.2,
        math.pi - 0.4,
        false,
        strokeOf(KathaInk.ink, 1.4),
      );
      final apart = 6 + 6 * math.sin(_clock * 22).abs();
      for (final side in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(46 + side * apart, 66),
            width: 9,
            height: 13,
          ),
          fillOf(skin),
        );
      }
    } else {
      canvas.drawLine(
        const Offset(42, 47),
        const Offset(50, 47),
        strokeOf(KathaInk.ink, 1.4),
      );
    }
    if (_watch > 0) {
      // A wrist raised to the camera, a watch on it.
      canvas.drawLine(
        const Offset(70, 80),
        const Offset(64, 54),
        strokeOf(Color.lerp(KathaInk.ink, KathaInk.paper, 0.3)!, 8),
      );
      canvas.drawCircle(const Offset(63, 51), 5, fillOf(KathaInk.marigold));
      canvas.drawCircle(const Offset(63, 51), 3, fillOf(KathaInk.paper));
    }
    canvas.restore();
    if (small) canvas.drawRect(tile, strokeOf(KathaInk.paper, 1));
  }
}

// =============================================================================
// Deepavali
// =============================================================================
