// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/courses/components/community_sheet.dart';
import 'package:words625/views/theme.dart';

/// Diameter of the circular node face.
const double kNodeSize = 74;

/// How far the darker "lip" sits below the face. This is what makes a node read
/// as a physical key rather than a sticker — pressing it sinks the face onto
/// the lip, the same language as the app's chiclet buttons.
const double kNodeLip = 6;

/// Total height a node occupies, including its label.
const double kNodeExtent = kNodeSize + kNodeLip + 28;

/// How many levels of [course] the learner has finished.
int courseProgress(Course course) => getIt<AppPrefs>()
    .preferences
    .getInt(course.courseName, defaultValue: 0)
    .getValue();

bool courseIsComplete(Course course) {
  final total = course.levels?.length ?? 0;
  return total > 0 && courseProgress(course) >= total;
}

class CourseNode extends StatefulWidget {
  const CourseNode(
    this.course, {
    this.isCurrent = false,
    this.isLocked = false,
    this.unlockedBy,
    this.onReturn,
    Key? key,
  }) : super(key: key);

  final Course course;

  /// The next course to work on — the one wearing the START flag.
  final bool isCurrent;

  /// Courses open one at a time: everything past the current one is shut until
  /// the course before it is finished.
  final bool isLocked;

  /// Name of the course that opens this one, for the locked message.
  final String? unlockedBy;

  /// Called after the lesson closes so the path can restate progress.
  final VoidCallback? onReturn;

  @override
  State<CourseNode> createState() => _CourseNodeState();
}

class _CourseNodeState extends State<CourseNode> {
  bool _pressed = false;

  Future<void> _open() async {
    if (widget.isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: VarnamalaTheme.textPrimary,
            content: Text(
              widget.unlockedBy == null
                  ? 'Finish the course before this one to unlock it.'
                  : 'Finish ${widget.unlockedBy!.toTitleCase} to unlock this.',
            ),
          ),
        );
      return;
    }

    await context.router.push(LessonRoute(course: widget.course));
    if (!mounted) return;
    setState(() {});
    widget.onReturn?.call();
  }

  void _openCommunity() {
    // Open even on a locked course: that is often exactly where the questions
    // about what is coming get asked.
    showCommunitySheet(
      context,
      language: context.read<LanguageProvider>().selectedLanguage,
      courseName: widget.course.courseName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLocked
        ? const Color(0xFFD3D9DE)
        : widget.course.color != null
            ? Color(widget.course.color!)
            : VarnamalaTheme.peacockCyan;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isCurrent) const _StartFlag(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: _open,
              // Long press is the shortcut; the badge below is how anyone
              // finds out the discussion exists in the first place.
              onLongPress: _openCommunity,
              child: _NodeFace(
                course: widget.course,
                color: color,
                pressed: _pressed,
                locked: widget.isLocked,
              ),
            ),
            Positioned(
              left: -4,
              top: 2,
              child: _DiscussionBadge(onTap: _openCommunity),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.course.courseName.toTitleCase,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: widget.isCurrent ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.1,
            color: widget.isLocked
                ? VarnamalaTheme.textHint
                : widget.isCurrent
                    ? VarnamalaTheme.textPrimary
                    : VarnamalaTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// The speech bubble clipped to the side of a node.
///
/// A long press alone would be invisible — nobody discovers a gesture that
/// nothing on screen hints at. This is the visible way in, and it doubles as a
/// sign that a discussion exists at all.
class _DiscussionBadge extends StatelessWidget {
  const _DiscussionBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open course discussion',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.forum_rounded,
            size: 14,
            color: VarnamalaTheme.peacockTeal,
          ),
        ),
      ),
    );
  }
}

/// The circular face, its lip, and the progress ring around both.
class _NodeFace extends StatelessWidget {
  const _NodeFace({
    required this.course,
    required this.color,
    required this.pressed,
    required this.locked,
  });

  final Course course;
  final Color color;
  final bool pressed;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final totalLevels = course.levels?.length ?? 0;

    return PreferenceBuilder<int>(
      preference: getIt<AppPrefs>()
          .preferences
          .getInt(course.courseName, defaultValue: 0),
      builder: (context, done) {
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
          width: kNodeSize + 16,
          height: kNodeSize + kNodeLip + 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring, only once there is progress worth showing.
              if (percent > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RingPainter(
                      percent: percent,
                      color: complete
                          ? VarnamalaTheme.success
                          : VarnamalaTheme.peacockTurquoise,
                    ),
                  ),
                ),

              // The key: lip stays put, face sinks onto it when pressed.
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: kNodeSize,
                    height: kNodeSize + kNodeLip,
                    child: Stack(
                      children: [
                        Positioned(
                          top: kNodeLip,
                          child: Container(
                            width: kNodeSize,
                            height: kNodeSize,
                            decoration: BoxDecoration(
                              color: lipColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 90),
                          curve: Curves.easeOut,
                          top: pressed ? kNodeLip : 0,
                          child: Container(
                            width: kNodeSize,
                            height: kNodeSize,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                locked
                                    ? Icons.lock_rounded
                                    : _iconFor(course.courseName),
                                color: locked
                                    ? const Color(0xFFF7F9FA)
                                    : Colors.white,
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 17,
                      color: VarnamalaTheme.success,
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

/// The bobbing "START" flag over the course the learner should do next.
class _StartFlag extends StatefulWidget {
  const _StartFlag();

  @override
  State<_StartFlag> createState() => _StartFlagState();
}

class _StartFlagState extends State<_StartFlag>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Padding(
        padding: EdgeInsets.only(bottom: 6 - _controller.value * 3),
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: VarnamalaTheme.peacockTeal,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
        ),
        child: const Text(
          'START',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

/// Progress arc drawn around the node, starting at twelve o'clock.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.percent, required this.color});

  final double percent;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 8 + (kNodeSize + kNodeLip) / 2);
    const radius = kNodeSize / 2 + 6;
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
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent || old.color != color;
}

IconData _iconFor(String courseName) {
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
