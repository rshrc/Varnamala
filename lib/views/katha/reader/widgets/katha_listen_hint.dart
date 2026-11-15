import 'package:flutter/material.dart';
import 'package:words625/views/theme.dart';

/// Shown in place of the lines while the words are hidden.
class KathaListenHint extends StatelessWidget {
  const KathaListenHint({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'No words: just listen and watch.\nCan you tell what is happening?',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: context.appTextSecondary),
      ),
    ),
  );
}
