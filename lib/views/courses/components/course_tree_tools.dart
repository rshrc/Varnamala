import 'package:flutter/material.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/views/flashcards/flashcards_page.dart';
import 'package:words625/views/settings/settings_page.dart';
import 'package:words625/views/theme.dart';

class CourseLearnTools extends StatelessWidget {
  const CourseLearnTools({required this.language, super.key});

  final TargetLanguage language;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            border: Border.all(color: context.appBorder),
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.appViolet.withValues(alpha: 0.14),
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusMedium),
                ),
                child: Icon(Icons.style_rounded, color: context.appViolet),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusMedium),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FlashcardsPage(language: language),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flashcard review',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Spaced repetition for your vocabulary',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Open flashcards',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FlashcardsPage(language: language),
                  ),
                ),
                icon:
                    Icon(Icons.arrow_forward_rounded, color: context.appViolet),
              ),
              IconButton(
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
                icon: Icon(Icons.settings_rounded, color: context.appWarning),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UnlockedCoursePathNotice extends StatelessWidget {
  const UnlockedCoursePathNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: context.appWarning.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          border: Border.all(
            color: context.appWarning.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_open_rounded, color: context.appWarning),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Free navigation is on. Completion still follows your real progress.',
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
              child: const Text('MANAGE'),
            ),
          ],
        ),
      ),
    );
  }
}
