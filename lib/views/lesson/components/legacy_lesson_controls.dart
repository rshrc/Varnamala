import 'dart:math';

import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:words625/application/level_provider.dart';
import 'package:words625/views/theme.dart';

class CheckButton extends StatelessWidget {
  const CheckButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Consumer<LessonProvider>(
        builder: (context, lessonState, child) {
          String title;
          Color backgroundColor;

          if (lessonState.answerState == AnswerState.correct ||
              lessonState.answerState == AnswerState.readyForNext) {
            title = "CONTINUE";
            backgroundColor = context.appSuccess;
          } else if (lessonState.answerState == AnswerState.incorrect) {
            title = "GOT IT";
            backgroundColor = context.appDanger;
          } else {
            title = "CHECK";
            backgroundColor = context.appAccent;
          }

          final isEnabled = lessonState.selectedAnswer != null;
          final disabledColor = Theme.of(context).disabledColor;

          return ChicletAnimatedButton(
            width: MediaQuery.of(context).size.width - 40,
            backgroundColor: isEnabled ? backgroundColor : disabledColor,
            onPressed: isEnabled
                ? () {
                    if (lessonState.answerState != AnswerState.readyForNext) {
                      final checkAnswer = lessonState.checkAnswer();
                      if (checkAnswer) {
                        if (lessonState.answerState == AnswerState.correct) {
                          lessonState
                              .changeAnswerState(AnswerState.readyForNext);
                        }
                      }
                    } else if (lessonState.answerState ==
                        AnswerState.readyForNext) {
                      lessonState.next(context);
                    }
                  }
                : null,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isEnabled
                    ? Theme.of(context).colorScheme.onPrimary
                    : context.appTextSecondary,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}

class LevelPlayerChoice extends StatelessWidget {
  const LevelPlayerChoice({super.key});

  @override
  Widget build(BuildContext context) {
    const styles = [
      _CelebrationStyle(
        icon: Icons.celebration_rounded,
        accent: VarnamalaTheme.peacockTurquoise,
        title: 'Level Complete!',
        subtitle: 'Brilliant focus. You cleared this level.',
      ),
      _CelebrationStyle(
        icon: Icons.flash_on_rounded,
        accent: VarnamalaTheme.warning,
        title: 'That Was Fast!',
        subtitle: 'You are climbing fast. Keep the streak alive.',
      ),
      _CelebrationStyle(
        icon: Icons.auto_awesome_rounded,
        accent: VarnamalaTheme.leagueAmethyst,
        title: 'Excellent Work!',
        subtitle: 'Every lesson gets you closer to mastery.',
      ),
    ];
    final style = styles[Random().nextInt(styles.length)];

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: style.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                style.icon,
                color: style.accent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              style.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              style.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                "Back to Courses",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCompletionPlayerChoice extends StatelessWidget {
  const CourseCompletionPlayerChoice({super.key});

  @override
  Widget build(BuildContext context) {
    const styles = [
      _CelebrationStyle(
        icon: Icons.emoji_events_rounded,
        accent: VarnamalaTheme.successDark,
        title: 'Course Complete!',
        subtitle: "You've mastered all the lessons.",
      ),
      _CelebrationStyle(
        icon: Icons.workspace_premium_rounded,
        accent: VarnamalaTheme.leagueRuby,
        title: 'Legendary Finish!',
        subtitle: 'That was a strong finish. Keep practicing.',
      ),
      _CelebrationStyle(
        icon: Icons.star_rounded,
        accent: VarnamalaTheme.peacockTeal,
        title: 'Mastery Unlocked!',
        subtitle: 'You completed the course with style.',
      ),
    ];
    final style = styles[Random().nextInt(styles.length)];

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: style.accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                style.icon,
                color: style.accent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              style.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              style.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Practice Again',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                "Back to Courses",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationStyle {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;

  const _CelebrationStyle({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });
}
