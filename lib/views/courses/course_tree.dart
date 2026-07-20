// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:chiclet/chiclet.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/course_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/language_info.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/views/theme.dart';
import 'components/course_node.dart';

/// Horizontal offsets, as a fraction of the available half-width, that the path
/// walks through as it descends. Repeating this cycle is what turns a column of
/// buttons into a route you travel along.
const List<double> _kWander = [0.0, 0.42, 0.62, 0.42, 0.0, -0.42, -0.62, -0.42];

/// Vertical gap between one node and the next, where the connector is drawn.
const double _kGap = 34;

class CourseTree extends StatefulWidget {
  const CourseTree({Key? key}) : super(key: key);

  @override
  State<CourseTree> createState() => _CourseTreeState();
}

class _CourseTreeState extends State<CourseTree> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final language = context.read<LanguageProvider>().selectedLanguage;
      context.read<CourseProvider>().getCourses(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: VarnamalaTheme.courseTreeGradient,
      ),
      child: Consumer<CourseProvider>(
        builder: (context, courseState, _) {
          if (courseState.hasFailed) {
            return _UnavailableNotice(language: courseState.failedLanguage!);
          }

          final groups = courseState.courses;
          if (groups == null) {
            return const Center(child: _LoadingIndicator());
          }

          // The manifest groups courses into rows; the path only needs their
          // order, and lays them out one per step so the wander stays readable.
          final courses = [for (final group in groups) ...group];
          if (courses.isEmpty) return const SizedBox.shrink();

          // The next course to do: the first one not yet finished. Everything
          // after it stays locked, so the path is something you open up rather
          // than a menu you pick from.
          final notes = courseRepository
              .notes(context.read<LanguageProvider>().selectedLanguage);

          final firstUnfinished =
              courses.indexWhere((course) => !courseIsComplete(course));
          final currentIndex =
              firstUnfinished == -1 ? courses.length - 1 : firstUnfinished;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 20, bottom: 48),
            itemCount: courses.length,
            itemBuilder: (context, index) => _PathStep(
              course: courses[index],
              dx: _kWander[index % _kWander.length],
              previousDx: index == 0
                  ? null
                  : _kWander[(index - 1) % _kWander.length],
              isCurrent: index == currentIndex,
              isLocked: index > currentIndex,
              unlockedBy: index == 0 ? null : courses[index - 1].courseName,
              note: notes[courses[index].courseName],
              onProgressChanged: () => setState(() {}),
            ),
          );
        },
      ),
    );
  }
}

/// One node plus the connector that reaches it from the previous node.
class _PathStep extends StatelessWidget {
  const _PathStep({
    required this.course,
    required this.dx,
    required this.previousDx,
    required this.isCurrent,
    required this.isLocked,
    required this.unlockedBy,
    required this.note,
    required this.onProgressChanged,
  });

  final Course course;
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
            height: _kGap,
            width: double.infinity,
            child: CustomPaint(
              painter: _ConnectorPainter(from: previousDx!, to: dx),
            ),
          ),
        Stack(
          alignment: Alignment.center,
          children: [
            // The note goes on whichever side the path is not using, which is
            // exactly the space that otherwise sits empty.
            if (note != null)
              Align(
                alignment: Alignment(dx > 0 ? -1 : 1, 0),
                child: _TrailNoteButton(note: note!, pointsRight: dx > 0),
              ),
            Align(
              alignment: Alignment(dx, 0),
              child: CourseNode(
                course,
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

/// Mala perched beside the path, collapsed to a small chiclet.
///
/// The note itself stays folded away until tapped: a wall of text beside every
/// node drowns out the path it is meant to decorate.
class _TrailNoteButton extends StatefulWidget {
  const _TrailNoteButton({required this.note, required this.pointsRight});

  final TrailNote note;

  /// True when the chiclet sits left of the node, so Mala turns to face it.
  final bool pointsRight;

  @override
  State<_TrailNoteButton> createState() => _TrailNoteButtonState();
}

class _TrailNoteButtonState extends State<_TrailNoteButton> {
  static const double _size = 54;
  static const double _lip = 4;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => _showTrailNote(context, widget.note, widget.pointsRight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SizedBox(
          width: _size,
          height: _size + _lip,
          child: Stack(
            children: [
              Positioned(
                top: _lip,
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFDFDA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 90),
                curve: Curves.easeOut,
                top: _pressed ? _lip : 0,
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Transform.flip(
                      flipX: widget.pointsRight,
                      child: Image.asset(
                        widget.note.image,
                        width: 34,
                        height: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pops the note open with a little spring, so tapping Mala feels like she
/// leaned in to tell you something.
void _showTrailNote(BuildContext context, TrailNote note, bool pointsRight) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, __) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.82, end: 1).animate(curved),
          child: _TrailNoteDialog(note: note, pointsRight: pointsRight),
        ),
      );
    },
  );
}

class _TrailNoteDialog extends StatelessWidget {
  const _TrailNoteDialog({required this.note, required this.pointsRight});

  final TrailNote note;
  final bool pointsRight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.flip(
                  flipX: pointsRight,
                  child: Image.asset(note.image, width: 86, height: 86),
                ),
                const SizedBox(height: 16),
                Text(
                  note.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: VarnamalaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 22),
                ChicletAnimatedButton(
                  width: double.infinity,
                  height: 46,
                  backgroundColor: VarnamalaTheme.peacockTeal,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A dashed curve from the previous node down to this one. Dashes keep the path
/// present without competing with the nodes for attention.
class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({required this.from, required this.to});

  final double from;
  final double to;

  @override
  void paint(Canvas canvas, Size size) {
    // Alignment.x maps -1..1 across the space left over beside the node.
    final half = (size.width - kNodeSize) / 2;
    final start = Offset(size.width / 2 + from * half, 0);
    final end = Offset(size.width / 2 + to * half, size.height);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx, start.dy + size.height * 0.55,
        end.dx, end.dy - size.height * 0.55,
        end.dx, end.dy,
      );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = VarnamalaTheme.peacockTeal.withValues(alpha: 0.18);

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
  bool shouldRepaint(_ConnectorPainter old) =>
      old.from != from || old.to != to;
}

/// Shown when a language's content could not be read, so the learner is told
/// what happened instead of being quietly handed a different language.
class _UnavailableNotice extends StatelessWidget {
  const _UnavailableNotice({required this.language});

  final TargetLanguage language;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty_rounded,
                size: 44, color: VarnamalaTheme.textHint),
            const SizedBox(height: 16),
            Text(
              '${languageInfo(language).englishName} is not ready yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Its lessons are still being written. Pick another language for now.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: VarnamalaTheme.textHint,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              VarnamalaTheme.peacockTeal.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading courses...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: VarnamalaTheme.textHint,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
