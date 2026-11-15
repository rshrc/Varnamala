import 'package:flutter/material.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/courses/katha.dart';
import 'package:words625/views/theme.dart';

/// The learner's language has no stories yet: say so, and offer the ones
/// that are told.
class KathaNotToldYet extends StatelessWidget {
  const KathaNotToldYet({
    super.key,
    required this.language,
    required this.chosen,
    required this.onChoose,
  });

  final TargetLanguage language;
  final String? chosen;
  final ValueChanged<String> onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appElevatedSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stories in ${language.name.toTitleCase} are on the way.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Season one is told in Kannada and Hindi so far. Read one of those meanwhile:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.appTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final code in KathaLanguages.toldIn)
                ChoiceChip(
                  label: Text(KathaLanguages.byCode[code]!.name.toTitleCase),
                  selected: chosen == code,
                  onSelected: (_) => onChoose(code),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
