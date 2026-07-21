// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/views/profile/activity_feed_page.dart';
import 'package:words625/views/theme.dart';

class FriendUpdates extends StatelessWidget {
  const FriendUpdates({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        border: Border.all(color: const Color(0xFFEEF2F1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              Navigator.of(context).push(ActivityFeedPage.route()),
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusSmall),
                  ),
                  child: const Icon(Icons.celebration_rounded,
                      color: Color(0xFFFF9500), size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  'Friend updates',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    size: 22, color: VarnamalaTheme.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
