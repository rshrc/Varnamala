// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/language_provider.dart';
import 'package:words625/application/level_provider.dart';
import 'package:words625/views/courses/components/community_sheet.dart';
import 'package:words625/views/theme.dart';

class LessonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LessonAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: context.appDanger,
            size: 26,
          ),
          onPressed: () {
            context.read<LessonProvider>().reset();
            Navigator.pop(context);
          },
        ),
      ),
      title: Consumer<LessonProvider>(
        builder: (context, lessonProvider, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
            child: LinearProgressIndicator(
              value: lessonProvider.percent,
              minHeight: 10,
              backgroundColor: context.appBorder,
              valueColor: AlwaysStoppedAnimation<Color>(context.appSuccess),
            ),
          );
        },
      ),
      centerTitle: true,
      actions: [
        // Reporting belongs here rather than on the course: from inside a
        // lesson the exact sentence can be attached automatically, so the
        // learner does not have to describe which line was wrong.
        Consumer<LessonProvider>(
          builder: (context, lesson, _) {
            final question = lesson.currentQuestion;
            final course = lesson.currentCourse;
            if (question?.sentence == null || course == null) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'Report a mistake in this question',
              icon: Icon(Icons.flag_outlined,
                  color: context.appWarning, size: 22),
              onPressed: () => showReportSheet(
                context,
                language: context.read<LanguageProvider>().selectedLanguage,
                courseName: course.courseName,
                sentence: question!.sentence,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
