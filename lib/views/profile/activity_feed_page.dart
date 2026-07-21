// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/activity_provider.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/identicon.dart';

/// What other learners have just pulled off, and a hi-five button.
///
/// There is nothing else to press. See [ActivityProvider] for why.
class ActivityFeedPage extends StatelessWidget {
  const ActivityFeedPage({Key? key}) : super(key: key);

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const ActivityFeedPage(),
      );

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: VarnamalaTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Friend updates'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<ActivityItem>>(
        stream: activity.watchFeed(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: VarnamalaTheme.peacockTeal, strokeWidth: 3),
            );
          }

          final items = snapshot.data ?? const <ActivityItem>[];
          if (items.isEmpty) return const _EmptyFeed();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _ActivityCard(item: items[index]),
          );
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final activity = context.read<ActivityProvider>();
    final isMine = item.userId == activity.currentUserId;
    final alreadySent = activity.hasHiFived(item);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: const Color(0xFFEEF2F1)),
      ),
      child: Row(
        children: [
          Identicon(seed: item.avatarSeed, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMine ? 'You' : item.handle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
                const SizedBox(height: 2),
                Text(
                  item.title,
                  style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: VarnamalaTheme.textSecondary),
                ),
                if (item.hiFives > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${item.hiFives} hi-five${item.hiFives == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: VarnamalaTheme.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isMine) _HiFiveButton(item: item, alreadySent: alreadySent),
        ],
      ),
    );
  }
}

class _HiFiveButton extends StatelessWidget {
  const _HiFiveButton({required this.item, required this.alreadySent});

  final ActivityItem item;
  final bool alreadySent;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: alreadySent
          ? null
          : () => context.read<ActivityProvider>().sendHiFive(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: alreadySent
              ? VarnamalaTheme.peacockTeal.withValues(alpha: 0.12)
              : VarnamalaTheme.peacockTeal,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.front_hand_rounded,
              size: 18,
              color: alreadySent ? VarnamalaTheme.peacockTeal : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              alreadySent ? 'Sent' : 'Hi-five',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: alreadySent ? VarnamalaTheme.peacockTeal : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    // A small kick on the way in, so sending one feels like something.
    return alreadySent
        ? button
        : button.animate(onPlay: (c) => c.stop()).scale(duration: 200.ms);
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 44),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.front_hand_rounded,
                size: 46, color: VarnamalaTheme.textHint),
            SizedBox(height: 14),
            Text(
              'Nothing yet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              'When someone earns a badge it shows up here, and you can send '
              'them a hi-five.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: VarnamalaTheme.textHint, fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
