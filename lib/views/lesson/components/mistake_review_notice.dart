import 'package:flutter/material.dart';
import 'package:words625/views/theme.dart';

class MistakeReviewNotice extends StatelessWidget {
  const MistakeReviewNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Mistake review. This exercise revisits something you missed earlier.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.appWarning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          border: Border.all(
            color: context.appWarning.withValues(alpha: 0.48),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.replay_rounded, color: context.appWarning),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MISTAKE REVIEW',
                    style: TextStyle(
                      color: context.appWarning,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('This revisits something you missed earlier.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
