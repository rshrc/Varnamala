import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/views/theme.dart';

/// Mala perched beside the path, collapsed to a small chiclet.
///
/// The note itself stays folded away until tapped: a wall of text beside every
/// node drowns out the path it is meant to decorate.
class TrailNoteButton extends StatefulWidget {
  const TrailNoteButton({
    required this.note,
    required this.pointsRight,
    super.key,
  });

  final TrailNote note;

  /// True when the chiclet sits left of the node, so Mala turns to face it.
  final bool pointsRight;

  @override
  State<TrailNoteButton> createState() => TrailNoteButtonState();
}

class TrailNoteButtonState extends State<TrailNoteButton> {
  static const double buttonSize = 54;
  static const double buttonLip = 4;

  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      onTap: () => showTrailNote(context, widget.note, widget.pointsRight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SizedBox(
          width: buttonSize,
          height: buttonSize + buttonLip,
          child: Stack(
            children: [
              Positioned(
                top: buttonLip,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 90),
                curve: Curves.easeOut,
                top: pressed ? buttonLip : 0,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Transform.flip(
                      flipX: widget.pointsRight,
                      child: Image.asset(
                        widget.note.image,
                        width: 34,
                        height: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pops the note open with a little spring, so tapping Mala feels like she
/// leaned in to tell you something.
void showTrailNote(BuildContext context, TrailNote note, bool pointsRight) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, __) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.82, end: 1).animate(curved),
          child: TrailNoteDialog(note: note, pointsRight: pointsRight),
        ),
      );
    },
  );
}

class TrailNoteDialog extends StatelessWidget {
  const TrailNoteDialog({
    required this.note,
    required this.pointsRight,
    super.key,
  });

  final TrailNote note;
  final bool pointsRight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.flip(
                  flipX: pointsRight,
                  child: Image.asset(note.image, width: 86, height: 86),
                ),
                const SizedBox(height: 16),
                Text(
                  note.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: context.appTextPrimary,
                  ),
                ),
                const SizedBox(height: 22),
                ChicletAnimatedButton(
                  width: double.infinity,
                  height: 46,
                  backgroundColor: context.appAccent,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Got it',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
