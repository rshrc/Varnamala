import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paint_kit.dart';

/// The office lunch table: steel tiffin carriers, a bottle, a laptop pushed
/// aside. Drawn in front of whoever stands behind it.
class LunchTable extends PositionComponent {
  LunchTable() : super(priority: 4);

  @override
  void render(Canvas canvas) {
    const top = 182.0;
    canvas.drawRect(
      const Rect.fromLTRB(70, top, 330, top + 6),
      fillOf(KathaInk.paper),
    );
    canvas.drawRect(
      const Rect.fromLTRB(76, top + 6, 324, 226),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.12)!),
    );
    // Tiffin carriers: three steel tins, a clip handle.
    for (final x in [176.0, 230.0]) {
      final steel = fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!);
      for (var i = 0; i < 3; i++) {
        canvas.drawRRect(
          RRect.fromLTRBR(
            x - 11,
            top - 10 - i * 9.0,
            x + 11,
            top - 1 - i * 9.0,
            const Radius.circular(2),
          ),
          steel,
        );
      }
      canvas.drawLine(
        Offset(x - 12, top - 4),
        Offset(x - 12, top - 34),
        Paint()
          ..color = KathaInk.ink
          ..strokeWidth = 1.4,
      );
      canvas.drawLine(
        Offset(x + 12, top - 4),
        Offset(x + 12, top - 34),
        Paint()
          ..color = KathaInk.ink
          ..strokeWidth = 1.4,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, top - 34), width: 24, height: 12),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = KathaInk.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
    // An open tin of lemon rice between them.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(203, top - 2), width: 30, height: 9),
      fillOf(Color.lerp(KathaInk.paper, KathaInk.ink, 0.3)!),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(203, top - 3), width: 24, height: 6),
      fillOf(KathaInk.marigold),
    );
    canvas.drawRect(
      const Rect.fromLTRB(290, top - 26, 298, top),
      fillOf(KathaInk.teal.withValues(alpha: 0.7)),
    );
  }
}

/// `bg.office`: an open office. Desks with monitors along the back, a water
/// cooler, a plant that somebody does water, a motivational poster of a
/// mountain, a clock, and the boss's glass cabin with its blinds.
class OfficeBackdrop extends PositionComponent {
  OfficeBackdrop() : super(priority: -10);

  late final Picture _picture = recordPicture(_paint);

  @override
  void render(Canvas canvas) => canvas.drawPicture(_picture);

  static void _paint(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, kathaWorldWidth, 202),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.teal, 0.1)!,
    );
    // Floor tiles.
    final floor = Color.lerp(KathaInk.paper, KathaInk.ink, 0.16)!;
    canvas.drawRect(
      const Rect.fromLTRB(0, 202, kathaWorldWidth, kathaWorldHeight),
      Paint()..color = floor,
    );
    final grout = Paint()
      ..color = KathaInk.ink.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= kathaWorldWidth; x += 32) {
      canvas.drawLine(Offset(x, 202), Offset(x - 16, kathaWorldHeight), grout);
    }
    for (final y in [220.0, 242.0]) {
      canvas.drawLine(Offset(0, y), Offset(kathaWorldWidth, y), grout);
    }
    // Ceiling lights.
    for (final x in [60.0, 180.0, 300.0]) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, 44, 5),
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }
    // Window strip with the city outside.
    canvas.drawRect(
      const Rect.fromLTRB(14, 26, 120, 92),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.teal, 0.35)!,
    );
    final tower = Paint()
      ..color = Color.lerp(KathaInk.paper, KathaInk.teal, 0.55)!;
    for (final (x, h) in [
      (20.0, 40.0),
      (40.0, 54.0),
      (66.0, 30.0),
      (84.0, 48.0),
      (104.0, 36.0),
    ]) {
      canvas.drawRect(Rect.fromLTWH(x, 92 - h, 14, h), tower);
    }
    canvas.drawRect(
      const Rect.fromLTRB(14, 26, 120, 92),
      Paint()
        ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.35)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      const Offset(67, 26),
      const Offset(67, 92),
      Paint()
        ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.35)!
        ..strokeWidth = 2,
    );

    // The motivational poster: a mountain, a flag on top, a rising sun.
    canvas.drawRect(
      const Rect.fromLTRB(140, 40, 196, 92),
      Paint()..color = KathaInk.ink,
    );
    canvas.drawRect(
      const Rect.fromLTRB(143, 43, 193, 89),
      Paint()..color = Color.lerp(KathaInk.marigold, KathaInk.paper, 0.5)!,
    );
    canvas.drawCircle(
      const Offset(178, 60),
      6,
      Paint()..color = KathaInk.marigold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(143, 89)
        ..lineTo(166, 56)
        ..lineTo(193, 89)
        ..close(),
      Paint()..color = KathaInk.teal,
    );
    canvas.drawLine(
      const Offset(166, 56),
      const Offset(166, 46),
      Paint()
        ..color = KathaInk.ink
        ..strokeWidth = 1,
    );
    canvas.drawRect(
      const Rect.fromLTRB(166, 46, 173, 50),
      Paint()..color = KathaInk.brick,
    );

    // Wall clock.
    canvas.drawCircle(
      const Offset(228, 56),
      12,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawCircle(
      const Offset(228, 56),
      12,
      Paint()
        ..color = KathaInk.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final hand = Paint()
      ..color = KathaInk.ink
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(228, 56), const Offset(228, 48), hand);
    canvas.drawLine(const Offset(228, 56), const Offset(234, 58), hand);

    // Desks along the back with monitors and chairs.
    for (final x in [24.0, 124.0, 224.0]) {
      canvas.drawRect(
        Rect.fromLTWH(x, 160, 84, 6),
        Paint()..color = Color.lerp(KathaInk.brick, KathaInk.paper, 0.4)!,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 4, 166, 4, 34),
        Paint()..color = KathaInk.ink.withValues(alpha: 0.5),
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 76, 166, 4, 34),
        Paint()..color = KathaInk.ink.withValues(alpha: 0.5),
      );
      for (final dx in [10.0, 46.0]) {
        canvas.drawRect(
          Rect.fromLTWH(x + dx, 136, 28, 20),
          Paint()..color = KathaInk.ink,
        );
        canvas.drawRect(
          Rect.fromLTWH(x + dx + 2, 138, 24, 16),
          Paint()..color = Color.lerp(KathaInk.teal, KathaInk.paper, 0.4)!,
        );
        canvas.drawRect(
          Rect.fromLTWH(x + dx + 12, 156, 4, 4),
          Paint()..color = KathaInk.ink,
        );
      }
      canvas.drawRRect(
        RRect.fromLTRBR(x + 30, 168, x + 54, 190, const Radius.circular(4)),
        Paint()..color = KathaInk.ink.withValues(alpha: 0.75),
      );
    }

    // Water cooler and a plant.
    canvas.drawRect(
      const Rect.fromLTRB(4, 150, 20, 200),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(5, 122, 19, 150, const Radius.circular(5)),
      Paint()..color = Color.lerp(KathaInk.teal, KathaInk.paper, 0.45)!,
    );
    canvas.drawRect(
      const Rect.fromLTRB(300, 180, 316, 200),
      Paint()..color = KathaInk.brick,
    );
    for (final (x, y) in [
      (302.0, 172.0),
      (308.0, 164.0),
      (314.0, 172.0),
      (308.0, 176.0),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 9, height: 16),
        Paint()..color = KathaInk.leaf,
      );
    }

    // The boss's glass cabin, blinds half down.
    canvas.drawRect(
      const Rect.fromLTRB(326, 30, 400, 202),
      Paint()..color = Color.lerp(KathaInk.paper, KathaInk.teal, 0.3)!,
    );
    final blind = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.7)
      ..strokeWidth = 1.6;
    for (var y = 34.0; y < 96; y += 5) {
      canvas.drawLine(Offset(328, y), Offset(398, y), blind);
    }
    final frame = Paint()
      ..color = Color.lerp(KathaInk.paper, KathaInk.ink, 0.4)!
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawRect(const Rect.fromLTRB(326, 30, 400, 202), frame);
    canvas.drawLine(const Offset(360, 100), const Offset(360, 202), frame);
    canvas.drawRect(
      const Rect.fromLTRB(364, 146, 368, 160),
      Paint()..color = KathaInk.ink,
    );
  }
}
