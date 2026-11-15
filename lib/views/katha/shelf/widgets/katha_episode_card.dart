import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:words625/courses/katha.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/beta_badge.dart';

class KathaEpisodeCard extends StatelessWidget {
  const KathaEpisodeCard({
    super.key,
    required this.number,
    required this.story,
    required this.onOpen,
  });

  final int number;
  final KathaEpisode story;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = story.telling.strings['${story.scene.id}.title'];
    final colour = context.appColors.courseColor(number - 1);
    final lines = story.telling.lines.length;
    return Material(
      color: context.appElevatedSurface,
      borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colour,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$number',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: context.appOn(colour),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title == null
                          ? 'Episode $number'
                          : KathaSpelling.casual.show(title.roman),
                      style: GoogleFonts.literata(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: context.appTextPrimary,
                      ),
                    ),
                    if (title?.gloss != null)
                      Text(
                        title!.gloss!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.appTextSecondary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '$lines lines · voiced',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: context.appTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (story.telling.isBeta) const BetaBadge(compact: true),
              const SizedBox(width: 4),
              Icon(Icons.play_circle_rounded, color: colour, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
