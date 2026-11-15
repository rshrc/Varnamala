import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/courses/katha.dart';
import 'package:words625/views/katha/shelf/widgets/katha_info_sheet.dart';
import 'package:words625/views/theme.dart';

class KathaShelfHeader extends StatelessWidget {
  const KathaShelfHeader({super.key, required this.language});

  final TargetLanguage? language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      // A solid accent: its derived text colour is checked against it in
      // every palette (theme_contrast_test), which a gradient would not be.
      decoration: BoxDecoration(
        color: context.appAccent,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
      ),
      clipBehavior: Clip.antiAlias,
      child: Builder(
        builder: (context) {
          final on = context.appOn(context.appAccent);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -18,
                bottom: -26,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 120,
                  color: on.withValues(alpha: 0.1),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dev in the City',
                    style: GoogleFonts.literata(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: on,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Watch, listen, and follow Dev through the city while '
                          'picking up Kannada in context.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: on.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        key: const ValueKey('katha-info'),
                        onPressed: () => showKathaInfoSheet(context),
                        tooltip: 'How Katha works',
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          foregroundColor: on,
                          backgroundColor: on.withValues(alpha: 0.12),
                        ),
                        icon: const Icon(Icons.info_outline_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    language == null
                        ? '${KathaCatalogue.episodes.length} episodes'
                        : '${KathaCatalogue.episodes.length} episodes · ${language!.name.toTitleCase}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: on,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
