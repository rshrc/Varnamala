// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/language_provider.dart';
import 'package:words625/application/lesson/interactive_course_progress.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/views/courses/components/community_sheet.dart';
import 'package:words625/views/courses/components/course_discussion_badge.dart';
import 'package:words625/views/courses/components/course_node_face.dart';
import 'package:words625/views/courses/components/course_practice_picker.dart';
import 'package:words625/views/courses/components/course_start_flag.dart';
import 'package:words625/views/courses/components/golden_course_shine.dart';
import 'package:words625/views/theme.dart';

export 'package:words625/views/courses/components/course_node_layout.dart';

/// How many generated Discover, Build, and Recall lessons are complete.
int courseProgress(Course course) =>
    const InteractiveCourseProgress().read(course).completedPlayableLessons;

bool courseIsComplete(Course course) =>
    const InteractiveCourseProgress().read(course).isComplete;

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
  State<CourseNode> createState() => CourseNodeState();
}

class CourseNodeState extends State<CourseNode> {
  bool pressed = false;

  Future<void> openLesson() async {
    if (widget.isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.appElevatedSurface,
            content: Text(
              widget.unlockedBy == null
                  ? 'Finish the course before this one to unlock it.'
                  : 'Finish ${widget.unlockedBy!.toTitleCase} to unlock this.',
            ),
          ),
        );
      return;
    }

    if (courseIsComplete(widget.course)) {
      final selection = await showCoursePracticePicker(context, widget.course);
      if (selection == null || !mounted) return;
      await context.router.push(
        LessonRoute(
          course: widget.course,
          unitIndex: selection.unitIndex,
          stageIndex: selection.stageIndex,
          isReplay: true,
        ),
      );
    } else {
      await context.router.push(LessonRoute(course: widget.course));
    }
    if (!mounted) return;
    setState(() {});
    widget.onReturn?.call();
  }

  void openCommunity() {
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
    final complete = courseIsComplete(widget.course);
    final progress = const InteractiveCourseProgress().read(widget.course);
    final color = complete
        ? const Color(0xFFFFC83D)
        : widget.isLocked
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : widget.course.color != null
                ? VarnamalaTheme.adaptiveAccent(
                    context,
                    Color(widget.course.color!),
                  )
                : context.appInfo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isCurrent) const CourseStartFlag(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Semantics(
              button: true,
              label: complete
                  ? '${widget.course.courseName}, course complete. Tap to practise any lesson.'
                  : null,
              child: GestureDetector(
                onTapDown: (_) => setState(() => pressed = true),
                onTapUp: (_) => setState(() => pressed = false),
                onTapCancel: () => setState(() => pressed = false),
                onTap: openLesson,
                // Long press is the shortcut; the badge below is how anyone
                // finds out the discussion exists in the first place.
                onLongPress: openCommunity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (complete) const GoldenCourseShine(),
                    CourseNodeFace(
                      course: widget.course,
                      color: color,
                      pressed: pressed,
                      locked: widget.isLocked,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -4,
              top: 2,
              child: CourseDiscussionBadge(onTap: openCommunity),
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
                ? context.appTextSecondary
                : widget.isCurrent
                    ? context.appTextPrimary
                    : context.appTextSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          complete
              ? '${progress.totalPlayableLessons} lessons · practise anytime'
              : '${progress.completedPlayableLessons + 1} of ${progress.totalPlayableLessons} lessons',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                complete ? const Color(0xFFB27700) : context.appTextSecondary,
            fontSize: 10,
            fontWeight: complete ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
