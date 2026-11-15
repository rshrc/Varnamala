import 'dart:math' as math;
import 'dart:ui';

import 'package:words625/views/katha/scene/engine/rig_part.dart';

/// An arm, pivoting at the shoulder, with a fixed bend at the elbow. Angle 0
/// hangs straight down.
class Limb extends RigPart {
  Limb({
    required super.position,
    required super.restAngle,
    required this.outward,
    required this.sleeve,
    required this.skin,
    this.upper = 19,
    this.fore = 18,
    double bend = 0,
    this.sleeveLength = 15,
    this.cuff,
    this.held,
    super.priority,
  }) : restBend = bend,
       bend = bend,
       super(draw: _drawLimb);

  /// +1 for an arm on the left of the picture, -1 on the right: the sign of
  /// the rotation that lifts it away from the body.
  final double outward;
  final Color sleeve;
  final Color skin;

  /// Shoulder to elbow, and elbow to wrist.
  final double upper;
  final double fore;

  /// How far the forearm swings at the elbow, in radians. A straight arm
  /// reads as a stick; a slight bend reads as an arm. A raised hand
  /// straightens it for a moment, then [settle] puts it back.
  double bend;
  final double restBend;

  @override
  void settle() {
    super.settle();
    bend = restBend;
  }

  final double sleeveLength;

  /// A band at the end of the sleeve: a rolled cuff.
  final Color? cuff;

  /// Something carried in the hand, drawn hanging from it. Set to null when
  /// it is let go of.
  void Function(Canvas canvas, Offset hand)? held;

  /// Fingers spread, as when holding up a price.
  bool fingersShown = false;

  /// Absolute angle for a lift of [amount] radians away from the body.
  double lifted(double amount) => restAngle + outward * amount;

  static void _drawLimb(Canvas canvas, RigPart part) {
    final limb = part as Limb;
    final skin = Paint()
      ..color = limb.skin
      ..strokeCap = StrokeCap.round;
    final sleeve = Paint()
      ..color = limb.sleeve
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Upper arm, then everything below the elbow in the forearm's own frame.
    canvas.drawLine(
      Offset.zero,
      Offset(0, limb.upper),
      skin..strokeWidth = 7.4,
    );
    canvas.drawLine(
      Offset.zero,
      Offset(0, math.min(limb.sleeveLength, limb.upper)),
      sleeve,
    );
    canvas.save();
    canvas.translate(0, limb.upper);
    canvas.rotate(limb.bend);
    final hand = Offset(0, limb.fore);
    canvas.drawLine(
      Offset.zero,
      Offset(0, limb.fore - 2),
      skin..strokeWidth = 6.6,
    );
    if (limb.sleeveLength > limb.upper) {
      canvas.drawLine(
        Offset.zero,
        Offset(0, limb.sleeveLength - limb.upper),
        sleeve,
      );
    }
    if (limb.cuff != null) {
      final end = limb.sleeveLength - limb.upper;
      canvas.drawLine(
        Offset(-4.6, end),
        Offset(4.6, end),
        Paint()
          ..color = limb.cuff!
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    if (limb.fingersShown) {
      final finger = Paint()
        ..color = limb.skin
        ..strokeWidth = 2.3
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 5; i++) {
        final spread = -0.8 + i * 0.4;
        canvas.drawLine(
          hand,
          hand + Offset(math.sin(spread) * 7.4, math.cos(spread) * 7.4),
          finger,
        );
      }
    }
    final fill = Paint()..color = limb.skin;
    canvas.drawCircle(hand, 4.6, fill);
    // A thumb, on the side toward the body.
    canvas.drawCircle(hand + Offset(-limb.outward * 3.6, -1.2), 2, fill);
    limb.held?.call(canvas, hand);
    canvas.restore();
  }
}
