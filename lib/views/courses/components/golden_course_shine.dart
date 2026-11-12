import 'dart:math';

import 'package:flutter/material.dart';
import 'package:words625/views/courses/components/course_node_layout.dart';
import 'package:words625/views/widgets/resting_loop.dart';

class GoldenCourseShine extends StatefulWidget {
  const GoldenCourseShine({super.key});

  @override
  State<GoldenCourseShine> createState() => GoldenCourseShineState();
}

class GoldenCourseShineState extends State<GoldenCourseShine>
    with SingleTickerProviderStateMixin {
  /// One orbit per burst, then rest. See [RestingLoop] for why it rests. The
  /// sparks sit at the same place at the start and end of an orbit, so the
  /// rest does not snap.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final RestingLoop _loop = RestingLoop(_controller);
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _loop.stop();
    } else {
      _loop.start();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Its own layer, so an orbit repaints these sparks and not the node,
      // label and connector it sits among.
      child: RepaintBoundary(
        child: SizedBox(
          width: courseNodeSize + 28,
          height: courseNodeSize + courseNodeLip + 28,
          child: CustomPaint(
            painter: GoldenCourseShinePainter(
              phase: _reduceMotion ? null : _controller,
            ),
          ),
        ),
      ),
    );
  }
}

class GoldenCourseShinePainter extends CustomPainter {
  /// Repaints straight off [phase], skipping build and layout every frame. A
  /// null phase draws the sparks still, for reduced motion.
  GoldenCourseShinePainter({required this.phase}) : super(repaint: phase);

  final Animation<double>? phase;

  static const _stillPhase = 0.18;
  static final _glow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6
    ..color = const Color(0xFFFFD65A).withValues(alpha: 0.18);
  static final _spark = Paint()
    ..color = const Color(0xFFFFF4B8).withValues(alpha: 0.9);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 1);
    canvas.drawCircle(center, courseNodeSize / 2 + 8, _glow);

    final t = phase?.value ?? _stillPhase;
    for (var index = 0; index < 3; index++) {
      final angle = t * 6.2832 + index * 2.0944;
      final point = Offset(
        center.dx + cos(angle) * (courseNodeSize / 2 + 10),
        center.dy + sin(angle) * (courseNodeSize / 2 + 10),
      );
      canvas.drawCircle(point, index == 0 ? 2.8 : 1.8, _spark);
    }
  }

  @override
  bool shouldRepaint(GoldenCourseShinePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
