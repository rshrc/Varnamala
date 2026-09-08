// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/views/theme.dart';

/// One entry of the home shell's navigation, shared by the bottom bar the
/// phone gets and the side rail wider windows get, so the two can never drift
/// apart on order, labels, or colour.
class HomeDestination {
  const HomeDestination({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;

  /// Resolved against the current theme, so each tab keeps its accent in both
  /// light and dark.
  final Color Function(BuildContext context) color;
}

const List<HomeDestination> homeDestinations = [
  HomeDestination(
    icon: Icons.school_rounded,
    label: 'Learn',
    color: _success,
  ),
  HomeDestination(
    icon: Icons.translate_rounded,
    label: 'Script',
    color: _info,
  ),
  HomeDestination(
    icon: Icons.person_rounded,
    label: 'Profile',
    color: _violet,
  ),
  HomeDestination(
    icon: Icons.emoji_events_rounded,
    label: 'Leagues',
    color: _warning,
  ),
  HomeDestination(
    icon: Icons.storefront_rounded,
    label: 'Shop',
    color: _danger,
  ),
];

Color _success(BuildContext context) => context.appSuccess;

Color _info(BuildContext context) => context.appInfo;

Color _violet(BuildContext context) => context.appViolet;

Color _warning(BuildContext context) => context.appWarning;

Color _danger(BuildContext context) => context.appDanger;

/// The colour a destination's icon and label rest at when it is not selected.
Color homeDestinationRestingColor(BuildContext context, Color color) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Color.lerp(color, context.appTextSecondary, isDark ? 0.38 : 0.55)!;
}
