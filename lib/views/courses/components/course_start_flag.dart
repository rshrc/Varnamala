import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/resting_loop.dart';

/// The bobbing "START" flag over the course the learner should do next.
class CourseStartFlag extends StatefulWidget {
  const CourseStartFlag({super.key});

  @override
  State<CourseStartFlag> createState() => CourseStartFlagState();
}

class CourseStartFlagState extends State<CourseStartFlag>
    with SingleTickerProviderStateMixin {
  /// Two bobs per burst, then rest. See [RestingLoop] for why it rests.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final RestingLoop _loop = RestingLoop(_controller);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop.stop();
    } else {
      _loop.start();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Moved with a transform, never with padding: padding changes the flag's
    // height, which re-lays out the node, its list item and the whole path
    // below it on every frame of the bob.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 0 -> 1 -> 0 twice, starting and ending at rest.
          final bob = (1 - math.cos(_controller.value * 4 * math.pi)) / 2;
          return Transform.translate(offset: Offset(0, bob * 3), child: child);
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: context.appAccent,
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
            ),
            child: Text(
              'START',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
