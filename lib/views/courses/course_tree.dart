// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/course_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/courses/components/course_node.dart';
import 'package:words625/views/courses/components/course_path_step.dart';
import 'package:words625/views/courses/components/course_tree_layout.dart';
import 'package:words625/views/courses/components/course_tree_status.dart';
import 'package:words625/views/courses/components/course_tree_tools.dart';
import 'package:words625/views/theme.dart';

/// Courses open from the very first launch: First words, and the Basics
/// sentences it feeds. Learning a word list and then never using it is not
/// learning a language, so the two arrive together.
const int kFreeCourseCount = 2;

/// The furthest course the path is open to, given which courses are finished.
///
/// Driven by the *last* completed course rather than the first unfinished one,
/// and that distinction is load-bearing. Taking the first unfinished course
/// means inserting a course anywhere ahead of a learner's progress drops the
/// watermark to that course and re-locks everything they have already
/// finished - including making their completed nodes untappable, since
/// [CoursePathStep] checks the lock before it checks completion.
int pathUnlockedThrough(List<bool> completed) => math.max(
      completed.lastIndexOf(true) + 1,
      kFreeCourseCount - 1,
    );

bool pathCourseIsLocked({
  required int courseIndex,
  required int unlockedThrough,
  required bool unlockAll,
}) =>
    !unlockAll && courseIndex > unlockedThrough;

class CourseTree extends StatefulWidget {
  const CourseTree({Key? key}) : super(key: key);

  @override
  State<CourseTree> createState() => CourseTreeState();
}

class CourseTreeState extends State<CourseTree> {
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
      decoration: BoxDecoration(gradient: context.appPathGradient),
      child: Consumer<CourseProvider>(
        builder: (context, courseState, _) {
          if (courseState.hasFailed) {
            return CourseUnavailableNotice(
              language: courseState.failedLanguage!,
            );
          }

          final groups = courseState.courses;
          if (groups == null) {
            return const Center(child: CourseLoadingIndicator());
          }

          // The manifest groups courses into rows; the path only needs their
          // order, and lays them out one per step so the wander stays readable.
          final courses = [for (final group in groups) ...group];
          if (courses.isEmpty) return const SizedBox.shrink();

          final notes = courseRepository
              .notes(context.read<LanguageProvider>().selectedLanguage);

          // Read once per course: courseIsComplete goes to preferences, and
          // both the watermark and the current node need the same answer.
          final completed = [
            for (final course in courses) courseIsComplete(course),
          ];

          // How far the path is open, so it is something you unlock rather
          // than a menu you pick from.
          final unlockedThrough = pathUnlockedThrough(completed);

          // The "you are here" node: the first course not yet finished, never
          // beyond what is actually open.
          final firstUnfinished = completed.indexOf(false);
          final currentIndex = firstUnfinished == -1
              ? courses.length
              : math.min(firstUnfinished, unlockedThrough);

          return PreferenceBuilder<bool>(
            preference: getIt<AppPrefs>().preferences.getBool(
                  PrefsConstants.unlockAllLevels,
                  defaultValue: false,
                ),
            builder: (context, unlockAll) {
              // Only the free-navigation notice sits above the path now.
              // Flashcards moved to the Practice tab: a side tool above the
              // first node pushed the course itself below the fold.
              final headerCount = unlockAll ? 1 : 0;
              // The path wanders left and right of centre by a fraction of
              // whatever width it is given, so an unbounded one flings its
              // nodes to opposite edges of a desktop window. Holding it to a
              // phone-width column keeps the walk readable at any size.
              // The column is applied per item rather than around the whole
              // list on purpose: bounding the scroll view itself puts its
              // scrollbar at the edge of a 420px column, floating in the middle
              // of a desktop window next to the nodes. The list stays full
              // width so the scrollbar rides the window edge where it belongs,
              // and only the contents are narrowed.
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 48),
                itemCount: courses.length + headerCount,
                itemBuilder: (context, index) => ContentBounds(
                  maxWidth: ContentWidth.path,
                  gutter: false,
                  child: Builder(builder: (context) {
                    if (unlockAll && index == 0) {
                      return const UnlockedCoursePathNotice();
                    }

                    final courseIndex = index - headerCount;
                    return CoursePathStep(
                      course: courses[courseIndex],
                      pathIndex: courseIndex,
                      dx: coursePathWander[
                          courseIndex % coursePathWander.length],
                      previousDx: courseIndex == 0
                          ? null
                          : coursePathWander[
                              (courseIndex - 1) % coursePathWander.length],
                      isCurrent: courseIndex == currentIndex,
                      isLocked: pathCourseIsLocked(
                        courseIndex: courseIndex,
                        unlockedThrough: unlockedThrough,
                        unlockAll: unlockAll,
                      ),
                      unlockedBy: courseIndex < kFreeCourseCount
                          ? null
                          : courses[courseIndex - 1].courseName,
                      note: notes[courses[courseIndex].courseName],
                      onProgressChanged: () => setState(() {}),
                    );
                  }),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
