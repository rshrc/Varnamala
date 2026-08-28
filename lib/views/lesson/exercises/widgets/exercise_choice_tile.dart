import 'package:flutter/material.dart';
import 'package:words625/views/theme.dart';

class ExerciseChoiceTile extends StatelessWidget {
  const ExerciseChoiceTile({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? context.appInfo.withValues(alpha: 0.12)
            : context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
              border: Border.all(
                color: selected ? context.appInfo : context.appBorder,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected ? context.appInfo : context.appTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
