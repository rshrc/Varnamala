// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/beta_badge.dart';

class LeaderboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LeaderboardAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: context.appWarning, size: 24),
          const SizedBox(width: 8),
          Text(
            'Leaderboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 7),
          const BetaBadge(compact: true),
        ],
      ),
    );
  }
}
