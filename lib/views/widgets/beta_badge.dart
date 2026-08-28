// Flutter imports:
import 'package:flutter/material.dart';

/// A compact status marker for usable features that are still changing.
///
/// Keep this off the core learning path. A beta marker is most useful when it
/// tells learners which individual experiences may still move or misbehave.
class BetaBadge extends StatelessWidget {
  const BetaBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Beta feature — your feedback helps us improve it',
      child: Semantics(
        label: 'Beta feature',
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 5 : 7,
              vertical: compact ? 2 : 3,
            ),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: colors.secondary.withValues(alpha: 0.42),
              ),
            ),
            child: Text(
              'BETA',
              style: TextStyle(
                color: colors.onSecondaryContainer,
                fontSize: compact ? 8 : 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
