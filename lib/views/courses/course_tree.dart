// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/course_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/courses/components/course_node.dart';
import 'package:words625/views/courses/components/course_path_step.dart';
import 'package:words625/views/courses/components/course_tree_layout.dart';
import 'package:words625/views/courses/components/course_tree_status.dart';
import 'package:words625/views/courses/components/course_tree_tools.dart';
import 'package:words625/views/theme.dart';

bool pathCourseIsLocked({
  required int courseIndex,
  required int currentIndex,
  required bool unlockAll,
}) =>
    !unlockAll && courseIndex > currentIndex;

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
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? VarnamalaTheme.darkCourseTreeGradient
            : VarnamalaTheme.courseTreeGradient,
      ),
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

          // The next course to do: the first one not yet finished. Everything
          // after it stays locked, so the path is something you open up rather
          // than a menu you pick from.
          final notes = courseRepository
              .notes(context.read<LanguageProvider>().selectedLanguage);

          final firstUnfinished =
              courses.indexWhere((course) => !courseIsComplete(course));
          final currentIndex =
              firstUnfinished == -1 ? courses.length : firstUnfinished;

          return PreferenceBuilder<bool>(
            preference: getIt<AppPrefs>().preferences.getBool(
                  PrefsConstants.unlockAllLevels,
                  defaultValue: false,
                ),
            builder: (context, unlockAll) {
              final headerCount = unlockAll ? 2 : 1;
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 48),
                itemCount: courses.length + headerCount,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CourseLearnTools(
                      language:
                          context.read<LanguageProvider>().selectedLanguage,
                    );
                  }
                  if (unlockAll && index == 1) {
                    return const UnlockedCoursePathNotice();
                  }

                  final courseIndex = index - headerCount;
                  return CoursePathStep(
                    course: courses[courseIndex],
                    dx: coursePathWander[courseIndex % coursePathWander.length],
                    previousDx: courseIndex == 0
                        ? null
                        : coursePathWander[
                            (courseIndex - 1) % coursePathWander.length],
                    isCurrent: courseIndex == currentIndex,
                    isLocked: pathCourseIsLocked(
                      courseIndex: courseIndex,
                      currentIndex: currentIndex,
                      unlockAll: unlockAll,
                    ),
                    unlockedBy: courseIndex == 0
                        ? null
                        : courses[courseIndex - 1].courseName,
                    note: notes[courses[courseIndex].courseName],
                    onProgressChanged: () => setState(() {}),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
