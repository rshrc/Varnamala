import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/views/theme.dart';

Future<void> showKathaInfoSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    constraints: kSheetConstraints,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) =>
          KathaInfoSheet(scrollController: scrollController),
    ),
  );
}

class KathaInfoSheet extends StatelessWidget {
  const KathaInfoSheet({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: context.appSurface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: context.appBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.appAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: context.appAccent,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A story you can learn from',
              style: GoogleFonts.literata(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: context.appTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Katha teaches Kannada through a serial story instead of a stack '
              'of drills. Each episode lets you see the moment, hear the line, '
              'and read along before asking you to remember anything.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: context.appTextSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const _LearningPoint(
              icon: Icons.image_rounded,
              title: 'See what the words mean',
              body:
                  'The illustrated scene shows who is speaking, what changed, '
                  'and why the line matters. Meaning comes first; translation '
                  'does not have to do all the work.',
            ),
            const _LearningPoint(
              icon: Icons.volume_up_rounded,
              title: 'Hear the whole exchange',
              body:
                  'Listen to the dialogue, replay a line, and connect its sound '
                  'to the action on screen. The voices belong to the scene, not '
                  'to a disconnected pronunciation exercise.',
            ),
            const _LearningPoint(
              icon: Icons.text_fields_rounded,
              title: 'Read without getting stuck',
              body:
                  'Follow the Kannada with a roman reading. Press a word when '
                  'you want its meaning, its parts, or where it came from, then '
                  'return to the story.',
            ),
            const _LearningPoint(
              icon: Icons.route_rounded,
              title: 'Remember the situation',
              body:
                  'People and places carry across episodes, so words return '
                  'with a face, a voice, and a moment attached. That context is '
                  'what makes them easier to recall later.',
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(
                  VarnamalaTheme.radiusMedium,
                ),
              ),
              child: Text(
                'No hearts and no lives. Pause, replay, or read the episode at '
                'your own pace.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.router.maybePop(),
              child: const Text('Back to episodes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningPoint extends StatelessWidget {
  const _LearningPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: context.appAccent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.appTextSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
