import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:words625/core/stable_hash.dart';
import 'package:words625/courses/course_repository.dart';
import 'package:words625/views/theme.dart';

/// Where one Mala sits beside the path.
///
/// Every note used to be pinned to the exact edge of the column at exactly its
/// node's height, at one size, so a column of them read as a rigid grid rather
/// than a character wandering alongside the walk. These offsets break that up.
/// They are derived from the note itself, so a given Mala always perches in
/// the same spot instead of hopping about on every rebuild.
class TrailNotePerch {
  const TrailNotePerch({
    required this.xFactor,
    required this.yFactor,
    required this.scale,
    required this.angle,
  });

  /// How far towards the edge of the column, 0.8-1.0 of the way out.
  final double xFactor;

  /// Above or below the node's centre line.
  final double yFactor;

  final double scale;

  /// A few degrees of tilt, so nothing sits perfectly square.
  final double angle;
}

TrailNotePerch trailNotePerch(String seed) {
  final hash = stableHash32(seed);
  // Four independent fractions out of one hash.
  double fraction(int shift) => ((hash >> shift) & 0xff) / 255;

  return TrailNotePerch(
    xFactor: 0.80 + fraction(0) * 0.20,
    yFactor: -0.45 + fraction(8) * 0.78,
    scale: 0.86 + fraction(16) * 0.22,
    angle: (fraction(24) - 0.5) * 0.22,
  );
}

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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: buttonSize,
          height: buttonSize + buttonLip,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // A soft round halo rather than a hard card: Mala should read as
              // perched beside the path, not filed in a box.
              Positioned(
                top: buttonLip,
                left: 0,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appViolet.withValues(alpha: 0.13),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOut,
                top: pressed ? buttonLip : 0,
                left: 0,
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: Center(
                    // Slightly larger than the halo, so she breaks its outline
                    // instead of being contained by it.
                    child: Transform.flip(
                      flipX: widget.pointsRight,
                      child: Image.asset(
                        widget.note.image,
                        width: 46,
                        height: 46,
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
    // The card is built once here rather than inside the transition. Building
    // it in `transitionBuilder` rebuilt the whole dialog - image, shadow and
    // all - on every frame of the open animation, which is what made tapping
    // Mala feel sluggish.
    pageBuilder: (context, _, __) =>
        TrailNoteDialog(note: note, pointsRight: pointsRight),
    transitionBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.82, end: 1).animate(curved),
          child: child,
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        // A note is a couple of sentences; stretched across a desktop window it
        // reads as a banner. And on a short window - a phone in landscape - a
        // long note has to be able to scroll rather than overflow.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusXLarge),
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
        ),
      ),
    );
  }
}
