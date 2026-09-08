// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

/// Window size classes, following the Material 3 breakpoints.
///
/// The app is drawn for a phone-width column; everything wider is treated as
/// "a phone column plus space around it" rather than as a canvas to stretch
/// into, which is what keeps a lesson readable on a 27" monitor.
enum Breakpoint {
  /// Phones, and any window narrow enough to behave like one.
  compact,

  /// Large phones in landscape, small tablets, iPad in portrait.
  medium,

  /// iPad in landscape, small desktop windows.
  expanded,

  /// Desktop.
  large;

  static Breakpoint of(double width) {
    if (width < 600) return Breakpoint.compact;
    if (width < 840) return Breakpoint.medium;
    if (width < 1200) return Breakpoint.expanded;
    return Breakpoint.large;
  }

  bool get isCompact => this == Breakpoint.compact;

  /// True once there is room to put navigation down the side instead of along
  /// the bottom, and to keep it there while the learner scrolls.
  bool get hasSideNavigation => index >= Breakpoint.expanded.index;

  /// The side rail only shows its labels when the window can spare the width.
  bool get hasExtendedSideNavigation => this == Breakpoint.large;

  /// Breathing room between the content column and the window edge.
  double get gutter => switch (this) {
        Breakpoint.compact => 0,
        Breakpoint.medium => 24,
        Breakpoint.expanded => 32,
        Breakpoint.large => 40,
      };
}

/// How wide a column of each kind of content is allowed to get.
///
/// These are reading measures, not screen fractions: a line of lesson text
/// stays the same comfortable length whether the window is 800px or 2000px.
abstract final class ContentWidth {
  /// Prose, forms, settings, and lesson exercises — one focused column.
  static const double column = 560;

  /// The course path. Tighter than [column] because the nodes wander to the
  /// left and right of centre, and a wide column flings them apart.
  static const double path = 420;

  /// Lists and feeds of cards: leaderboard rows, shop items, profile sections.
  static const double feed = 720;

  /// Grids that genuinely benefit from more columns, like the language picker.
  static const double grid = 900;
}

extension ResponsiveContext on BuildContext {
  /// The size class of the current window.
  Breakpoint get breakpoint => Breakpoint.of(MediaQuery.sizeOf(this).width);

  bool get isCompact => breakpoint.isCompact;
}

/// Keeps a modal bottom sheet a panel instead of a band stretched across a
/// desktop window. Flutter centres a sheet whose width is constrained, so
/// passing this to `showModalBottomSheet` is all a sheet needs.
const BoxConstraints kSheetConstraints =
    BoxConstraints(maxWidth: ContentWidth.column);

/// Centres [child] in a column no wider than [maxWidth].
///
/// On a phone this is a no-op beyond the gutter, so wrapping a screen in it
/// costs nothing on the layout it was originally designed for. A scrollable
/// can be wrapped directly: it still gets the full height and only its
/// contents are narrowed, so the scrollbar stays where the content is.
class ContentBounds extends StatelessWidget {
  const ContentBounds({
    required this.child,
    this.maxWidth = ContentWidth.column,
    this.gutter = true,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  /// Whether to inset the column from the window edge on wider windows.
  final bool gutter;

  @override
  Widget build(BuildContext context) {
    final padding = gutter ? context.breakpoint.gutter : 0.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // The column is sized tightly rather than merely capped, so content
        // laid out to fill a phone screen fills the column the same way
        // instead of collapsing onto its intrinsic width.
        final available = constraints.maxWidth - padding * 2;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: math.min(available, maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
