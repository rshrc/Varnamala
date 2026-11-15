import 'package:flutter/material.dart';
import 'package:words625/views/widgets/beta_badge.dart';

/// The Stories tab's app bar.
class KathaShelfAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KathaShelfAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Stories',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 7),
          const BetaBadge(compact: true),
        ],
      ),
    );
  }
}
