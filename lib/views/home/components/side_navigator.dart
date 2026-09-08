// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/core/responsive.dart';
import 'package:words625/views/home/components/home_destinations.dart';
import 'package:words625/views/theme.dart';

/// The home shell's navigation on windows wide enough to spare the width:
/// a rail down the side rather than a bar along the bottom.
///
/// On a desktop or an iPad in landscape a bottom bar is both far from the
/// pointer and stretched across space it has no use for, so the same
/// destinations move to the leading edge and stay put while content scrolls.
/// Width of the rail's icon column.
///
/// [NavigationRail] centres each destination's icon inside this, so the
/// secondary entries below have to use the same number or they sit visibly
/// off-axis from the destinations above them.
const double _railIconColumnWidth = 80;

/// Width of the rail once it shows labels beside the icons.
const double _railExtendedWidth = 190;

class SideNavigator extends StatelessWidget {
  const SideNavigator({
    required this.currentIndex,
    required this.onPress,
    required this.onOpenFlashcards,
    required this.onOpenSettings,
    Key? key,
  }) : super(key: key);

  final int currentIndex;
  final Function(int) onPress;

  /// Secondary places the rail can reach. They are not tabs - each opens a
  /// page of its own - so they sit apart from the destinations, at the bottom
  /// where a rail has room that a bottom bar simply does not.
  final VoidCallback onOpenFlashcards;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final extended = context.breakpoint.hasExtendedSideNavigation;
    final selectedColor = homeDestinations[currentIndex].color(context);

    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        boxShadow: [
          BoxShadow(
            color: context.appShadowTint.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: currentIndex,
        onDestinationSelected: onPress,
        extended: extended,
        minWidth: _railIconColumnWidth,
        minExtendedWidth: _railExtendedWidth,
        labelType: extended
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.all,
        indicatorColor: selectedColor.withValues(alpha: isDark ? 0.18 : 0.1),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        ),
        // Only one destination is selected at a time, so the rail-wide
        // selected style can carry that destination's own accent.
        selectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selectedColor,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: context.appTextSecondary,
        ),
        destinations: [
          for (final destination in homeDestinations)
            _destination(context, destination),
        ],
        trailing: Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    indent: 12,
                    endIndent: 12,
                    height: 1,
                    color: context.appBorder,
                  ),
                  const SizedBox(height: 6),
                  _SecondaryRailItem(
                    icon: Icons.style_rounded,
                    label: 'Flashcards',
                    color: context.appViolet,
                    extended: extended,
                    onTap: onOpenFlashcards,
                  ),
                  const SizedBox(height: 4),
                  _SecondaryRailItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    color: context.appTextSecondary,
                    extended: extended,
                    onTap: onOpenSettings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  NavigationRailDestination _destination(
    BuildContext context,
    HomeDestination destination,
  ) {
    final color = destination.color(context);
    final resting = homeDestinationRestingColor(context, color);
    return NavigationRailDestination(
      icon: Icon(destination.icon, size: 26, color: resting),
      selectedIcon: Icon(destination.icon, size: 26, color: color),
      label: Text(destination.label),
    );
  }
}

/// A rail entry that opens a page rather than switching tab, so it never
/// competes with the destinations for the selected state.
class _SecondaryRailItem extends StatelessWidget {
  const _SecondaryRailItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.extended,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: extended ? '' : label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: extended
              // The icon sits in the same column the destinations use, so the
              // icons form one vertical line down the whole rail.
              // The width is stated rather than flexed: the rail lays its
              // trailing area out unbounded, so an Expanded here throws.
              ? SizedBox(
                  width: _railExtendedWidth,
                  child: Row(
                    children: [
                      SizedBox(
                        width: _railIconColumnWidth,
                        child:
                            Center(child: Icon(icon, size: 22, color: color)),
                      ),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.appTextSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                )
              : SizedBox(
                  width: _railIconColumnWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 22, color: color),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: context.appTextSecondary,
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
