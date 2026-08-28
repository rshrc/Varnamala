import 'package:flutter/material.dart';
import 'package:words625/views/theme.dart';

/// The speech bubble clipped to the side of a node.
///
/// A long press alone would be invisible — nobody discovers a gesture that
/// nothing on screen hints at. This is the visible way in, and it doubles as a
/// sign that a discussion exists at all.
class CourseDiscussionBadge extends StatelessWidget {
  const CourseDiscussionBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open course discussion',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: context.appSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.forum_rounded,
            size: 14,
            color: context.appInfo,
          ),
        ),
      ),
    );
  }
}
