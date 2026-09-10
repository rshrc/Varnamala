// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
import 'package:words625/views/theme.dart';

/// One picture in a grid of choices.
///
/// The sibling of `ExerciseChoiceTile` for word courses: same verdict
/// behaviour and the same 44x44 floor on the tap target, but the answer is a
/// drawing rather than a line of text.
class ExercisePictureTile extends StatelessWidget {
  const ExercisePictureTile({
    required this.art,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showLabel = false,
    this.mark = AnswerMark.none,
    super.key,
  });

  /// Asset path of the illustration.
  final String art;

  /// What the picture shows, in English. Always the semantic label, and shown
  /// under the picture when [showLabel] is set.
  final String label;

  /// Kept off while the learner is meant to read the picture rather than the
  /// word under it.
  final bool showLabel;

  final bool selected;
  final VoidCallback onTap;
  final AnswerMark mark;

  @override
  Widget build(BuildContext context) {
    final marked = mark.color(context);
    final accent = marked ?? (selected ? context.appInfo : null);
    final radius = BorderRadius.circular(VarnamalaTheme.radiusMedium);

    return Semantics(
      button: true,
      selected: selected,
      image: true,
      label:
          mark.semanticLabel == null ? label : '$label. ${mark.semanticLabel}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: accent == null
              ? context.appSurface
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      // The art is flat colour on transparency, so it reads on
                      // both a light and a dark card without a plate behind it.
                      child: SvgPicture.asset(
                        art,
                        // ExcludeSemantics: the tile above already announces
                        // the label, and the drawing has nothing to add.
                        excludeFromSemantics: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (showLabel) ...[
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: accent ?? context.appTextSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                  if (mark.icon case final icon?) ...[
                    const SizedBox(height: 6),
                    Icon(icon, color: marked, size: 20),
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
