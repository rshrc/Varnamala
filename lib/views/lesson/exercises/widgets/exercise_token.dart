import 'package:flutter/material.dart';
import 'package:words625/domain/exercise/interactive_exercise.dart';
import 'package:words625/views/theme.dart';

class DraggableExerciseToken extends StatefulWidget {
  const DraggableExerciseToken({
    required this.token,
    required this.onTap,
    required this.semanticHint,
    this.selected = false,
    super.key,
  });

  final ExerciseToken token;
  final VoidCallback onTap;
  final String semanticHint;
  final bool selected;

  @override
  State<DraggableExerciseToken> createState() => DraggableExerciseTokenState();
}

class DraggableExerciseTokenState extends State<DraggableExerciseToken> {
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    final chip = ExerciseTokenChip(
      text: widget.token.text,
      selected: widget.selected,
      onTap: widget.onTap,
      semanticHint: widget.semanticHint,
    );
    return Draggable<String>(
      data: widget.token.id,
      dragAnchorStrategy: childDragAnchorStrategy,
      rootOverlay: true,
      onDragStarted: () => setState(() => dragging = true),
      onDragEnd: (_) {
        if (mounted) setState(() => dragging = false);
      },
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.035,
          child: ExerciseTokenChip(
            text: widget.token.text,
            selected: true,
            semanticHint: 'Dragging ${widget.token.text}',
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.16, child: chip),
      child: MouseRegion(
        cursor:
            dragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
        child: AnimatedScale(
          scale: dragging ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: chip,
        ),
      ),
    );
  }
}

class SettledExerciseToken extends StatelessWidget {
  const SettledExerciseToken({
    required this.animate,
    required this.child,
    super.key,
  });

  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final settled = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.72 + (0.28 * settled),
          child: Transform.scale(
            scale: 0.94 + (0.06 * settled),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ExerciseTokenChip extends StatelessWidget {
  const ExerciseTokenChip({
    required this.text,
    required this.semanticHint,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String text;
  final String semanticHint;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: text,
      hint: semanticHint,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? context.appInfo.withValues(alpha: 0.16)
              : context.appSurface,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
          border: Border.all(
            color: selected ? context.appInfo : context.appBorder,
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: context.appInfo.withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
            child: Container(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
