import 'package:flutter/material.dart';
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
import 'package:words625/views/theme.dart';

class ExerciseChoiceTile extends StatelessWidget {
  const ExerciseChoiceTile({
    required this.text,
    required this.selected,
    required this.onTap,
    this.mark = AnswerMark.none,
    super.key,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  /// Set once the answer has been checked, so the tile itself carries the
  /// verdict instead of leaving it all to the band at the bottom of the screen.
  final AnswerMark mark;

  @override
  Widget build(BuildContext context) {
    final marked = mark.color(context);
    final accent = marked ?? (selected ? context.appInfo : null);
    final radius = BorderRadius.circular(VarnamalaTheme.radiusMedium);

    return Semantics(
      button: true,
      selected: selected,
      label: mark.semanticLabel == null ? null : '$text. ${mark.semanticLabel}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: accent == null
              ? context.appSurface
              // A marked tile carries more fill than a merely selected one:
              // the verdict has to be readable from across the room.
              : accent.withValues(alpha: mark.isMarked ? 0.20 : 0.12),
          borderRadius: radius,
          border: Border.all(
            color: accent ?? context.appBorder,
            width: accent == null ? 1.5 : 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: accent ?? context.appTextPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (mark.icon case final icon?) ...[
                    const SizedBox(width: 10),
                    Icon(icon, color: marked, size: 22),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
