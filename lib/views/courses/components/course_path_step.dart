import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/views/courses/components/course_node.dart';
import 'package:words625/views/courses/components/course_tree_layout.dart';
import 'package:words625/views/courses/components/trail_note.dart';
import 'package:words625/views/theme.dart';

/// One node plus the connector that reaches it from the previous node.
class CoursePathStep extends StatelessWidget {
  const CoursePathStep({
    required this.course,
    required this.pathIndex,
    required this.dx,
    required this.previousDx,
    required this.isCurrent,
    required this.isLocked,
    required this.unlockedBy,
    required this.note,
    required this.onProgressChanged,
    super.key,
  });

  final Course course;

  /// Position on the path, which picks the node's colour from the palette.
  final int pathIndex;
  final double dx;
  final double? previousDx;
  final bool isCurrent;
  final bool isLocked;
  final String? unlockedBy;
  final TrailNote? note;
  final VoidCallback onProgressChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (previousDx != null)
          SizedBox(
            height: coursePathGap,
            width: double.infinity,
            child: CustomPaint(
              painter: CoursePathConnectorPainter(
                from: previousDx!,
                to: dx,
                color: context.appAccent.withValues(alpha: 0.35),
              ),
            ),
          ),
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // The note goes on whichever side the path is not using, which is
            // exactly the space that otherwise sits empty. Each one is nudged
            // off the exact edge and off its node's centre line, so a run of
            // them wanders alongside the path instead of forming a column.
            if (note != null)
              Builder(builder: (context) {
                final perch =
                    trailNotePerch(course.courseId ?? course.courseName);
                final side = dx > 0 ? -1.0 : 1.0;
                return Align(
                  alignment: Alignment(side * perch.xFactor, perch.yFactor),
                  child: Transform.rotate(
                    angle: perch.angle,
                    child: Transform.scale(
                      scale: perch.scale,
                      child: TrailNoteButton(
                        note: note!,
                        pointsRight: dx > 0,
                      ),
                    ),
                  ),
                );
              }),
            Align(
              alignment: Alignment(dx, 0),
              child: CourseNode(
                course,
                pathIndex: pathIndex,
                isCurrent: isCurrent,
                isLocked: isLocked,
                unlockedBy: unlockedBy,
                onReturn: onProgressChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A dashed curve from the previous node down to this one. Dashes keep the path
/// present without competing with the nodes for attention.
class CoursePathConnectorPainter extends CustomPainter {
  const CoursePathConnectorPainter({
    required this.from,
    required this.to,
    required this.color,
  });

  final double from;
  final double to;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Alignment.x maps -1..1 across the space left over beside the node.
    final half = (size.width - courseNodeSize) / 2;
    final start = Offset(size.width / 2 + from * half, 0);
    final end = Offset(size.width / 2 + to * half, size.height);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx,
        start.dy + size.height * 0.55,
        end.dx,
        end.dy - size.height * 0.55,
        end.dx,
        end.dy,
      );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + 7, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + 7;
      }
    }
  }

  @override
  bool shouldRepaint(CoursePathConnectorPainter old) =>
      old.from != from || old.to != to || old.color != color;
}
