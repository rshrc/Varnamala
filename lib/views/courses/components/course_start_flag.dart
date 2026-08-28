import 'package:flutter/material.dart';
import 'package:words625/views/theme.dart';

/// The bobbing "START" flag over the course the learner should do next.
class CourseStartFlag extends StatefulWidget {
  const CourseStartFlag({super.key});

  @override
  State<CourseStartFlag> createState() => CourseStartFlagState();
}

class CourseStartFlagState extends State<CourseStartFlag>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Padding(
        padding: EdgeInsets.only(bottom: 6 - _controller.value * 3),
        child: child,
      ),
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
    );
  }
}
