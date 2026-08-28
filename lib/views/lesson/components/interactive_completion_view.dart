import 'package:flutter/material.dart';
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/application/lesson/interactive_course_progress.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/views/theme.dart';

class InteractiveCompletionView extends StatelessWidget {
  const InteractiveCompletionView({
    required this.course,
    required this.stage,
    required this.isReplay,
    required this.completion,
    super.key,
  });

  final Course course;
  final LessonStageKind stage;
  final bool isReplay;
  final InteractiveProgressAdvance? completion;

  @override
  Widget build(BuildContext context) {
    final courseComplete = completion?.courseCompleted ?? false;
    final title = isReplay
        ? 'Practice complete!'
        : courseComplete
            ? 'Course complete!'
            : '${stage.label} complete!';
    final subtitle = isReplay
        ? 'Replay this course whenever you want.'
        : courseComplete
            ? '${course.courseName} is now golden.'
            : stage == LessonStageKind.recall
                ? 'The next unit is ready.'
                : '${LessonStageKind.values[stage.index + 1].label} is ready.';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: context.appWarning.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: context.appWarning, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: context.appWarning.withValues(alpha: 0.3),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: context.appWarning,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.appTextSecondary,
                      ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'CONTINUE ON PATH',
                      style: TextStyle(fontWeight: FontWeight.w900),
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
