import 'dart:async' as async;
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/katha_panel_game.dart';

enum FaceExpression {
  neutral,
  happy,
  laugh,
  shock,
  smug,
  sigh,
  shrug,
  stern,

  /// Eyes shut and staying shut: asleep in bed.
  asleep,

  /// Too much chilli: eyes squeezed, mouth gasping, face burning.
  spicy,
}

/// Eyes, brows, nose and mouth, drawn on the head. Shared by every character:
/// the face set is one set, so a new character costs a hairstyle, not a new
/// face.
class Face extends PositionComponent with HasGameReference<KathaPanelGame> {
  Face({
    required this.facing,
    required this.radius,
    required this.skin,
    this.mouthDrop = 0,
    this.browWeight = 1.7,
    super.priority,
  });

  /// -1 looking left, +1 looking right. Shifts the features a little toward
  /// where the character is looking.
  final double facing;
  final double radius;
  final Color skin;

  /// How much lower the mouth sits - room for a moustache.
  final double mouthDrop;
  final double browWeight;

  FaceExpression expression = FaceExpression.neutral;

  /// What the face returns to after a passing expression: neutral, or
  /// asleep for someone in bed.
  FaceExpression rest = FaceExpression.neutral;
  bool _blinking = false;
  async.Timer? _revert;

  double _talkLeft = 0;
  double _talkClock = 0;

  /// Shows [next] for [seconds], then returns to neutral.
  void show(FaceExpression next, double seconds) {
    _revert?.cancel();
    expression = next;
    game.wake(0.05);
    _revert = async.Timer(Duration(milliseconds: (seconds * 1000).round()), () {
      expression = rest;
      if (isMounted) game.wake(0.05);
    });
  }

  /// Holds [next] until told otherwise: falling asleep, waking up.
  void settle(FaceExpression next) {
    _revert?.cancel();
    rest = next;
    expression = next;
    if (isMounted) game.wake(0.05);
  }

  void blink() {
    if (expression == FaceExpression.laugh ||
        expression == FaceExpression.asleep ||
        expression == FaceExpression.spicy) {
      return;
    }
    _blinking = true;
    game.wake(0.05);
    async.Timer(const Duration(milliseconds: 130), () {
      _blinking = false;
      if (isMounted) game.wake(0.05);
    });
  }

  /// Moves the lips for [seconds]: the character is speaking.
  void talk(double seconds) {
    _talkLeft = seconds;
    _talkClock = 0;
    game.wake(seconds + 0.1);
  }

  /// Closes the mouth: the line is over.
  void hush() {
    if (_talkLeft <= 0) return;
    _talkLeft = 0;
    game.wake(0.05);
  }

  /// How far the mouth is open right now, 0 to 1. Two sine waves at unrelated
  /// speeds, so the lips do not tick like a metronome.
  double get _openness {
    if (_talkLeft <= 0) return 0;
    final beat = math.sin(_talkClock * 15).abs();
    final swell = 0.62 + 0.38 * math.sin(_talkClock * 5.3 + 1);
    return (0.12 + 0.88 * beat * swell).clamp(0.0, 1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_talkLeft > 0) {
      _talkLeft -= dt;
      _talkClock += dt;
    }
  }

  @override
  void onRemove() {
    _revert?.cancel();
    super.onRemove();
  }

  static final _ink = Paint()..color = KathaInk.ink;
  static final _paper = Paint()..color = KathaInk.paper;
  static final _stroke = Paint()
    ..color = KathaInk.ink
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void render(Canvas canvas) {
    final s = radius / 12;
    final fx = facing * 1.5 * s;
    final stroke = _stroke..strokeWidth = 1.5 * s;
    final eyes = [
      Offset(-4.6 * s + fx, -1.2 * s),
      Offset(4.6 * s + fx, -1.2 * s),
    ];
    final shade = Paint()..color = Color.lerp(skin, KathaInk.ink, 0.2)!;

    // A touch of colour in the cheeks.
    final burning = expression == FaceExpression.spicy;
    final blush = Paint()
      ..color = KathaInk.brick.withValues(alpha: burning ? 0.55 : 0.2);
    final cheek = (burning ? 3.4 : 2.3) * s;
    canvas.drawCircle(Offset(-7.2 * s + fx * 0.5, 3.4 * s), cheek, blush);
    canvas.drawCircle(Offset(7.2 * s + fx * 0.5, 3.4 * s), cheek, blush);

    // Brows first: they carry as much of the expression as the mouth does.
    final brow = Paint()
      ..color = KathaInk.ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = browWeight * s;
    for (var i = 0; i < 2; i++) {
      final side = i == 0 ? -1.0 : 1.0;
      final eye = eyes[i];
      final (lift, tilt) = switch (expression) {
        FaceExpression.shock => (3.0, 0.0),
        FaceExpression.shrug => (2.2, 1.6),
        FaceExpression.sigh => (0.2, -1.6),
        FaceExpression.smug => (side == facing ? 1.8 : 0.0, 0.0),
        FaceExpression.laugh => (0.8, 0.8),
        FaceExpression.stern => (-0.6, -1.8),
        FaceExpression.spicy => (2.4, -1.4),
        FaceExpression.asleep => (-0.4, 0.0),
        _ => (0.0, 0.4),
      };
      final y = eye.dy - 5.6 * s - lift * s;
      canvas.drawLine(
        Offset(eye.dx - 2.8 * s, y + side * tilt * 0.5 * s),
        Offset(eye.dx + 2.8 * s, y - side * tilt * 0.5 * s),
        brow,
      );
    }

    for (final eye in eyes) {
      if (expression == FaceExpression.asleep) {
        // Shut: a soft downward curve, lashes resting.
        canvas.drawArc(
          Rect.fromCenter(
            center: eye.translate(0, -0.6 * s),
            width: 5 * s,
            height: 3.6 * s,
          ),
          0.25,
          math.pi - 0.5,
          false,
          stroke,
        );
        continue;
      }
      if (expression == FaceExpression.spicy) {
        // Squeezed tight: > <
        final point = eye == eyes[0] ? 1.0 : -1.0;
        canvas.drawPath(
          Path()
            ..moveTo(eye.dx - point * 2.4 * s, eye.dy - 2 * s)
            ..lineTo(eye.dx + point * 1.8 * s, eye.dy)
            ..lineTo(eye.dx - point * 2.4 * s, eye.dy + 2 * s),
          stroke,
        );
        continue;
      }
      if (_blinking) {
        canvas.drawLine(
          eye.translate(-2.4 * s, 0.4 * s),
          eye.translate(2.4 * s, 0.4 * s),
          stroke,
        );
        continue;
      }
      if (expression == FaceExpression.laugh) {
        canvas.drawArc(
          Rect.fromCenter(
            center: eye.translate(0, 1 * s),
            width: 5 * s,
            height: 4 * s,
          ),
          math.pi,
          math.pi,
          false,
          stroke,
        );
        continue;
      }
      // White, pupil looking where the character looks, and a glint.
      final wide = expression == FaceExpression.shock;
      final white = Rect.fromCenter(
        center: eye,
        width: (wide ? 6.6 : 5.2) * s,
        height: (wide ? 7.2 : 5.6) * s,
      );
      canvas.drawOval(white, _paper);
      final pupil = eye.translate(
        facing * (wide ? 0.4 : 0.9) * s,
        wide ? 0 : 0.3 * s,
      );
      canvas.drawCircle(pupil, (wide ? 1.5 : 1.9) * s, _ink);
      canvas.drawCircle(pupil.translate(0.6 * s, -0.7 * s), 0.55 * s, _paper);
      if (expression == FaceExpression.sigh ||
          expression == FaceExpression.smug ||
          expression == FaceExpression.stern) {
        // A heavy lid: the top of the eye covered in skin.
        canvas.save();
        canvas.clipRect(
          Rect.fromLTRB(
            white.left - 1,
            white.top - 1,
            white.right + 1,
            eye.dy - 0.4 * s,
          ),
        );
        canvas.drawOval(white.inflate(0.4), Paint()..color = skin);
        canvas.restore();
        canvas.drawLine(
          Offset(white.left, eye.dy - 0.4 * s),
          Offset(white.right, eye.dy - 0.4 * s),
          stroke,
        );
      }
    }

    // Nose: one soft stroke, turned toward where the character faces.
    canvas.drawPath(
      Path()
        ..moveTo(fx * 0.9, 0.6 * s)
        ..quadraticBezierTo(
          fx * 0.9 + facing * 2.4 * s,
          3 * s,
          fx * 0.9,
          3.6 * s,
        ),
      Paint()
        ..color = shade.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.5 * s,
    );

    final mouth = Offset(fx * 0.8, (6.6 + mouthDrop) * s);
    final open = _openness;
    final speaking =
        _talkLeft > 0 &&
        expression != FaceExpression.laugh &&
        expression != FaceExpression.shock;
    if (speaking) {
      // Lips moving: an opening that grows and closes with the speech.
      final box = Rect.fromCenter(
        center: mouth.translate(0, 0.4 * s),
        width: (4.2 + 1.6 * open) * s,
        height: (0.9 + 4.2 * open) * s,
      );
      canvas.drawOval(box, _ink);
      if (open > 0.45) {
        canvas.drawOval(
          Rect.fromCenter(
            center: box.center.translate(0, box.height * 0.22),
            width: box.width * 0.6,
            height: box.height * 0.42,
          ),
          Paint()..color = KathaInk.brick,
        );
      }
      return;
    }
    switch (expression) {
      case FaceExpression.asleep:
        // Mouth a little open, breathing slow.
        canvas.drawOval(
          Rect.fromCenter(
            center: mouth.translate(0, 0.4 * s),
            width: 2.6 * s,
            height: 1.8 * s,
          ),
          _ink,
        );
      case FaceExpression.spicy:
        // Gasping for water, tongue out.
        final gasp = Rect.fromCenter(
          center: mouth.translate(0, 0.8 * s),
          width: 6.4 * s,
          height: 5.2 * s,
        );
        canvas.drawOval(gasp, _ink);
        canvas.drawOval(
          Rect.fromCenter(
            center: gasp.center.translate(0, 1.4 * s),
            width: 3.6 * s,
            height: 2.6 * s,
          ),
          Paint()..color = KathaInk.brick,
        );
      case FaceExpression.happy:
        canvas.drawArc(
          Rect.fromCenter(
            center: mouth.translate(0, -1.6 * s),
            width: 7 * s,
            height: 5 * s,
          ),
          0.2,
          math.pi - 0.4,
          false,
          stroke,
        );
      case FaceExpression.laugh:
        final laugh = Path()
          ..moveTo(mouth.dx - 4 * s, mouth.dy - 1.2 * s)
          ..lineTo(mouth.dx + 4 * s, mouth.dy - 1.2 * s)
          ..arcToPoint(
            Offset(mouth.dx - 4 * s, mouth.dy - 1.2 * s),
            radius: Radius.circular(4 * s),
          );
        canvas.drawPath(laugh, _ink);
        canvas.drawRect(
          Rect.fromLTRB(
            mouth.dx - 3 * s,
            mouth.dy - 1.2 * s,
            mouth.dx + 3 * s,
            mouth.dy - 0.1 * s,
          ),
          _paper,
        );
      case FaceExpression.shock:
        canvas.drawOval(
          Rect.fromCenter(
            center: mouth.translate(0, 0.8 * s),
            width: 3.6 * s,
            height: 4.6 * s,
          ),
          _ink,
        );
      case FaceExpression.smug:
        canvas.drawPath(
          Path()
            ..moveTo(mouth.dx - 3 * s, mouth.dy)
            ..quadraticBezierTo(
              mouth.dx + 0.6 * s,
              mouth.dy + 1.4 * s,
              mouth.dx + 3.4 * s * facing.sign,
              mouth.dy - 1.8 * s,
            ),
          stroke,
        );
      case FaceExpression.shrug:
        canvas.drawArc(
          Rect.fromCenter(
            center: mouth.translate(0, 1.8 * s),
            width: 5.6 * s,
            height: 3.2 * s,
          ),
          math.pi + 0.35,
          math.pi - 0.7,
          false,
          stroke,
        );
      case FaceExpression.sigh:
        canvas.drawLine(
          mouth.translate(-2.4 * s, 0.6 * s),
          mouth.translate(2.4 * s, 0.2 * s),
          stroke,
        );
      case FaceExpression.stern:
        canvas.drawArc(
          Rect.fromCenter(
            center: mouth.translate(0, 1.2 * s),
            width: 5 * s,
            height: 2.4 * s,
          ),
          math.pi + 0.4,
          math.pi - 0.8,
          false,
          stroke,
        );
      case FaceExpression.neutral:
        canvas.drawArc(
          Rect.fromCenter(
            center: mouth.translate(0, -0.8 * s),
            width: 5 * s,
            height: 2.4 * s,
          ),
          0.3,
          math.pi - 0.6,
          false,
          stroke,
        );
    }
  }
}
