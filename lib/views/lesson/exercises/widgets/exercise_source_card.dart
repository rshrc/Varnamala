import 'package:flutter/material.dart';
import 'package:words625/views/theme.dart';

class ExerciseSourceCard extends StatelessWidget {
  const ExerciseSourceCard({
    required this.label,
    required this.text,
    super.key,
  });

  final String label;
  final String text;

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
