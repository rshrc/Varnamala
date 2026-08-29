import 'package:flutter/material.dart';
import 'package:words625/views/lesson/exercises/widgets/tappable_gloss_text.dart';
import 'package:words625/views/theme.dart';

class ExerciseSourceCard extends StatelessWidget {
  const ExerciseSourceCard({
    required this.label,
    required this.text,
    this.showWordMeanings = false,
    super.key,
  });

  final String label;
  final String text;
  final bool showWordMeanings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appInfo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: context.appInfo.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.appInfo,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 8),
          if (showWordMeanings)
            TappableGlossText(
              text: text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
            )
          else
            Text(
              text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
            ),
        ],
      ),
    );
  }
}
