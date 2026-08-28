import 'package:flutter/material.dart';
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/views/theme.dart';

typedef CoursePracticeSelection = ({int unitIndex, int stageIndex});

Future<CoursePracticeSelection?> showCoursePracticePicker(
  BuildContext context,
  Course course,
) {
  final totalUnits = course.levels?.length ?? 0;
  final totalLessons = totalUnits * LessonStageKind.values.length;
  return showModalBottomSheet<CoursePracticeSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appBorder,
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusRound),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFFFB51B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practise ${course.courseName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Text(
                        'Replay any of the $totalLessons lessons, as often as you like.',
                        style: TextStyle(color: context.appTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.12,
                ),
                itemCount: totalLessons,
                itemBuilder: (context, lessonIndex) {
                  final unitIndex =
                      lessonIndex ~/ LessonStageKind.values.length;
                  final stageIndex =
                      lessonIndex % LessonStageKind.values.length;
                  final stage = LessonStageKind.values[stageIndex];
                  return InkWell(
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusMedium),
                    onTap: () => Navigator.of(context).pop(
                      (unitIndex: unitIndex, stageIndex: stageIndex),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC83D).withValues(alpha: 0.13),
                        borderRadius:
                            BorderRadius.circular(VarnamalaTheme.radiusMedium),
                        border: Border.all(
                          color:
                              const Color(0xFFE6A51D).withValues(alpha: 0.55),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${lessonIndex + 1}',
                            style: const TextStyle(
                              color: Color(0xFF9B6500),
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'U${unitIndex + 1} · ${stage.label}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.appTextSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
