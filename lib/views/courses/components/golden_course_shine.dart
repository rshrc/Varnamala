import 'dart:math';

import 'package:flutter/material.dart';
import 'package:words625/views/courses/components/course_node_layout.dart';

class GoldenCourseShine extends StatefulWidget {
  const GoldenCourseShine({super.key});

  @override
  State<GoldenCourseShine> createState() => GoldenCourseShineState();
}

class GoldenCourseShineState extends State<GoldenCourseShine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: SizedBox(
        width: courseNodeSize + 28,
        height: courseNodeSize + courseNodeLip + 28,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: GoldenCourseShinePainter(
              phase: reduceMotion ? 0.18 : _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class GoldenCourseShinePainter extends CustomPainter {
  const GoldenCourseShinePainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 1);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFFFFD65A).withValues(alpha: 0.18);
    canvas.drawCircle(center, courseNodeSize / 2 + 8, glow);

    for (var index = 0; index < 3; index++) {
      final angle = phase * 6.2832 + index * 2.0944;
      final point = Offset(
        center.dx + cos(angle) * (courseNodeSize / 2 + 10),
        center.dy + sin(angle) * (courseNodeSize / 2 + 10),
      );
      final radius = index == 0 ? 2.8 : 1.8;
      canvas.drawCircle(
        point,
        radius,
        Paint()..color = const Color(0xFFFFF4B8).withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(GoldenCourseShinePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
