import 'package:flutter/material.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/language_info.dart';
import 'package:words625/views/theme.dart';

/// Shown when a language's content could not be read, so the learner is told
/// what happened instead of being quietly handed a different language.
class CourseUnavailableNotice extends StatelessWidget {
  const CourseUnavailableNotice({required this.language, super.key});

  final TargetLanguage language;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty_rounded,
                size: 44, color: context.appInfo),
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
                    color: context.appTextSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseLoadingIndicator extends StatelessWidget {
  const CourseLoadingIndicator({super.key});

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
              context.appAccent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading courses...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.appTextSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
