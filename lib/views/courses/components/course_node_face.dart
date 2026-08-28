import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:words625/application/lesson/interactive_course_progress.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/courses/components/course_node_layout.dart';
import 'package:words625/views/theme.dart';

/// The circular face, its lip, and the progress ring around both.
class CourseNodeFace extends StatelessWidget {
  const CourseNodeFace({
    required this.course,
    required this.color,
    required this.pressed,
    required this.locked,
    super.key,
  });

  final Course course;
  final Color color;
  final bool pressed;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final progress = const InteractiveCourseProgress().read(course);
    final totalLevels = progress.totalPlayableLessons;

    return PreferenceBuilder<int>(
      preference: getIt<AppPrefs>()
          .preferences
          .getInt(course.courseName, defaultValue: 0),
      builder: (context, _) {
        final done = progress.completedPlayableLessons;
        final percent =
            totalLevels == 0 ? 0.0 : (done / totalLevels).clamp(0.0, 1.0);
        final complete = percent >= 1;

        // A flat, hand-mixed darker shade for the lip. Deliberately not a
        // gradient — one solid step down reads as depth, a ramp reads as gloss.
        final lipColor = HSLColor.fromColor(color)
            .withLightness(
                (HSLColor.fromColor(color).lightness - 0.16).clamp(0.0, 1.0))
            .toColor();

        return SizedBox(
          width: courseNodeSize + 16,
          height: courseNodeSize + courseNodeLip + 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring, only once there is progress worth showing.
              if (percent > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CourseNodeProgressRingPainter(
                      percent: percent,
                      color: complete ? context.appWarning : context.appSuccess,
                    ),
                  ),
                ),

              // The key: lip stays put, face sinks onto it when pressed.
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: courseNodeSize,
                    height: courseNodeSize + courseNodeLip,
                    child: Stack(
                      children: [
                        Positioned(
                          top: courseNodeLip,
                          child: Container(
                            width: courseNodeSize,
                            height: courseNodeSize,
                            decoration: BoxDecoration(
                              color: lipColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 90),
                          curve: Curves.easeOut,
                          top: pressed ? courseNodeLip : 0,
                          child: Container(
                            width: courseNodeSize,
                            height: courseNodeSize,
                            decoration: BoxDecoration(
                              color: complete ? null : color,
                              gradient: complete
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFF0A3),
                                        Color(0xFFFFC83D),
                                        Color(0xFFE69B16),
                                      ],
                                    )
                                  : null,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                locked
                                    ? Icons.lock_rounded
                                    : courseIconFor(course.courseName),
                                color: locked
                                    ? context.appTextSecondary
                                    : Theme.of(context).colorScheme.onPrimary,
                                size: locked ? 28 : 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // A crown only when the course is actually finished, instead of a
              // permanent "0" that means nothing to a new learner.
              if (complete)
                Positioned(
                  right: 0,
                  bottom: 4,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 17,
                      color: context.appWarning,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Progress arc drawn around the node, starting at twelve o'clock.
class CourseNodeProgressRingPainter extends CustomPainter {
  const CourseNodeProgressRingPainter(
      {required this.percent, required this.color});

  final double percent;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        Offset(size.width / 2, 8 + (courseNodeSize + courseNodeLip) / 2);
    const radius = courseNodeSize / 2 + 6;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = VarnamalaTheme.textHint.withValues(alpha: 0.16);
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -1.5708, 6.2832 * percent, false, arc);
  }

  @override
  bool shouldRepaint(CourseNodeProgressRingPainter old) =>
      old.percent != percent || old.color != color;
}

IconData courseIconFor(String courseName) {
  final name = courseName.toLowerCase();
  if (name.contains('basic')) return Icons.egg_alt_rounded;
  if (name.contains('greet')) return Icons.waving_hand_rounded;
  if (name.contains('introduc')) return Icons.person_add_alt_1_rounded;
  if (name.contains('family')) return Icons.family_restroom_rounded;
  if (name.contains('food') || name.contains('drink')) {
    return Icons.restaurant_rounded;
  }
  if (name.contains('number')) return Icons.pin_rounded;
  if (name.contains('colour') || name.contains('color')) {
    return Icons.palette_rounded;
  }
  if (name.contains('travel')) return Icons.flight_rounded;
  if (name.contains('time') || name.contains('day')) {
    return Icons.schedule_rounded;
  }
  if (name.contains('shop')) return Icons.shopping_bag_rounded;
  if (name.contains('health')) return Icons.healing_rounded;
  if (name.contains('home')) return Icons.chair_rounded;
  if (name.contains('work') || name.contains('school')) {
    return Icons.school_rounded;
  }
  if (name.contains('feel') || name.contains('emotion')) {
    return Icons.mood_rounded;
  }
  if (name.contains('festival')) return Icons.celebration_rounded;
  if (name.contains('animal')) return Icons.pets_rounded;
  if (name.contains('weather') || name.contains('nature')) {
    return Icons.wb_sunny_rounded;
  }
  if (name.contains('cloth')) return Icons.checkroom_rounded;
  return Icons.menu_book_rounded;
}
