// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/league_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/domain/league.dart';
import 'package:words625/views/leaderboard/components/league_board.dart';
import 'package:words625/views/theme.dart';

/// The board, shown the moment a lesson ends, moving the learner into place.
///
/// The XP is already banked by the time this is built, so the standings that
/// arrive are the *new* ones. To show the climb rather than its result, the
/// panel rebuilds where the learner stood before the lesson - same board, their
/// XP minus what they just earned - holds that for a beat, and then lets the
/// real order take over. What the learner watches is their own row overtaking
/// the people they actually overtook.
class LeagueClimbPanel extends StatefulWidget {
  const LeagueClimbPanel({
    required this.language,
    required this.xpJustEarned,
    this.visiblePlaces = 5,
    super.key,
  });

  final TargetLanguage language;

  /// What this lesson was worth. Zero means there is nothing to animate.
  final int xpJustEarned;

  /// How many rows to show around the learner.
  final int visiblePlaces;

  @override
  State<LeagueClimbPanel> createState() => _LeagueClimbPanelState();
}

class _LeagueClimbPanelState extends State<LeagueClimbPanel> {
  bool _showFinal = false;

  @override
  void initState() {
    super.initState();
    // Long enough to read the old standings, short enough that nobody waits.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showFinal = true);
    });
  }

  /// The board as it stood before this lesson's XP landed.
  List<LeaderboardEntry> _before(
    List<LeaderboardEntry> after,
    String league,
    String? uid,
  ) {
    if (uid == null || widget.xpJustEarned <= 0) return after;
    final rewound = after.map((entry) {
      if (entry.userId != uid) return entry;
      final language = widget.language.name;
      return entry.withLeagueXp(
        language,
        (entry.leagueXpFor(language) - widget.xpJustEarned)
            .clamp(0, 1 << 30)
            .toInt(),
      );
    }).toList();

    return LeagueProvider.rankForLeague(rewound, league, widget.language.name);
  }

  /// A window around the learner, so a rank of 40 still shows the climb.
  List<LeaderboardEntry> _window(List<LeaderboardEntry> users, String? uid) {
    if (users.length <= widget.visiblePlaces) return users;
    final index = users.indexWhere((entry) => entry.userId == uid);
    if (index < 0) return users.take(widget.visiblePlaces).toList();
    final start = (index - (widget.visiblePlaces - 2))
        .clamp(0, users.length - widget.visiblePlaces);
    return users.sublist(start, start + widget.visiblePlaces);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<String>(
      stream: context
          .read<LeagueProvider>()
          .getUserLeagueStream(widget.language.name),
      builder: (context, leagueSnapshot) {
        final league = leagueSnapshot.data;
        if (league == null) return const SizedBox.shrink();
        return _board(context, league, uid);
      },
    );
  }

  Widget _board(BuildContext context, String league, String? uid) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: context
          .read<LeagueProvider>()
          .getLeagueLeaderboard(league, widget.language.name),
      builder: (context, snapshot) {
        final users = snapshot.data ?? const <LeaderboardEntry>[];
        if (users.isEmpty) return const SizedBox.shrink();

        final finalOrder = users;
        final order =
            _showFinal ? finalOrder : _before(finalOrder, league, uid);
        final rows = _window(order, uid);
        final myRank = finalOrder.indexWhere((entry) => entry.userId == uid);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_rounded,
                    color: context.appWarning, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${widget.language.name.toUpperCase()} LEAGUE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.appTextSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                ),
                const Spacer(),
                if (myRank >= 0)
                  Text(
                    '#${myRank + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.appWarning,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LeagueBoard(
              users: rows,
              language: widget.language,
              myUserId: uid,
              celebrate: true,
            ),
          ],
        );
      },
    );
  }
}
