// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/characters/character_drawing.dart';
import 'package:words625/views/courses/course_tree.dart';
import 'package:words625/views/flashcards/flashcards_page.dart';
import 'package:words625/views/lesson/lesson_screen.dart';
import 'package:words625/views/match/match_page.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/beta_badge.dart';

/// Every screen worth showing somebody, reachable without signing in.
///
/// The screens themselves live behind an auth guard, which is right for
/// learners and impossible for a headless browser taking README screenshots or
/// for anyone being shown the app for thirty seconds. None of these screens
/// actually need an account - they read bundled course JSON and local
/// preferences - so this route assembles them directly.
///
/// Driven by `tool/screenshots/capture.mjs`.
@RoutePage()
class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  TargetLanguage _language = TargetLanguage.kannada;
  bool _busy = false;

  /// The screens below read the chosen language from preferences and from
  /// [LanguageProvider], so both have to agree before anything is opened.
  Future<void> _use(TargetLanguage language) async {
    setState(() => _language = language);
    await getIt<AppPrefs>()
        .setString(PrefsConstants.currentLanguage, language.name);
    if (!mounted) return;
    context.read<LanguageProvider>().setLanguage(language);
  }

  Future<void> _openLesson({required String courseId}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final groups = await courseRepository.courses(_language,
          firstName: 'Rishi');
      final course = groups
          .expand((group) => group)
          .firstWhere((course) => course.courseId == courseId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LessonPage(course: course)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _push(Widget page) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => page),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Showcase'),
            SizedBox(width: 8),
            BetaBadge(compact: true),
          ],
        ),
      ),
      body: SafeArea(
        child: ContentBounds(
          maxWidth: ContentWidth.feed,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text(
                'LANGUAGE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final language in TargetLanguage.values)
                    ChoiceChip(
                      label: Text(language.name.toTitleCase),
                      selected: _language == language,
                      onSelected: (_) => _use(language),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              _Entry(
                icon: Icons.route_rounded,
                colour: context.appSuccess,
                title: 'The path',
                subtitle: 'Sixteen courses, First words first',
                onTap: () => _push(
                  const Scaffold(body: SafeArea(child: CourseTree())),
                ),
              ),
              _Entry(
                icon: Icons.abc_rounded,
                colour: context.appViolet,
                title: 'First words lesson',
                subtitle: 'Pictures, audio, and typing the word',
                onTap: () => _openLesson(courseId: 'words'),
              ),
              _Entry(
                icon: Icons.chat_bubble_rounded,
                colour: context.appInfo,
                title: 'Sentence lesson',
                subtitle: 'Word banks, ordering, and blanks',
                onTap: () => _openLesson(courseId: 'basics'),
              ),
              _Entry(
                icon: Icons.draw_rounded,
                colour: context.appAccent,
                title: 'Script writing',
                subtitle: 'Trace the letters of the alphabet',
                onTap: () => _push(const CharacterPracticeScreen()),
              ),
              _Entry(
                icon: Icons.bolt_rounded,
                colour: context.appWarning,
                title: 'Match Madness',
                subtitle: 'Pair words against the clock',
                onTap: () => _push(const MatchPage()),
              ),
              _Entry(
                icon: Icons.style_rounded,
                colour: context.appViolet,
                title: 'Flashcard review',
                subtitle: 'Spaced repetition over your vocabulary',
                onTap: () => _push(FlashcardsPage(language: _language)),
              ),
              if (_busy) ...[
                const SizedBox(height: 20),
                Center(
                  child: CircularProgressIndicator(color: context.appAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.colour,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color colour;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: context.appBorder),
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colour.withValues(alpha: 0.14),
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusMedium),
                  ),
                  child: Icon(icon, color: colour),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: context.appTextSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
