// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/core/responsive.dart';
import 'package:words625/views/home/components/home_destinations.dart';
import 'package:words625/views/theme.dart';

class BottomNavigator extends StatelessWidget {
  final Function(int) onPress;
  final int currentIndex;

  const BottomNavigator({
    required this.currentIndex,
    required this.onPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: 64 + bottomPadding,
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurface,
          boxShadow: [
            BoxShadow(
              color: context.appShadowTint.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: bottomPadding),
        // On a tablet in portrait the bar is far wider than the five tabs
        // need, and spacing them across it leaves the thumb reaching. Keeping
        // them in a phone-width group holds them together in the middle.
        child: ContentBounds(
          maxWidth: ContentWidth.column,
          gutter: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Each tab takes an equal share rather than its natural width:
              // five labels at their own size overflow a narrow phone, and
              // overflow more readily still at large text sizes.
              for (var index = 0; index < homeDestinations.length; index++)
                Expanded(
                  child: _NavItem(
                    destination: homeDestinations[index],
                    isSelected: currentIndex == index,
                    onTap: () => onPress(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final HomeDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = destination.color(context);
    final restingIcon = homeDestinationRestingColor(context, color);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.18 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              destination.icon,
              size: 26,
              color: isSelected ? color : restingIcon,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : context.appTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
