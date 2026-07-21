// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/league_provider.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/domain/league.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/identicon.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: LeagueProvider.leagues.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _LeagueHeader(controller: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: LeagueProvider.leagues
                .map((league) => _LeagueLeaderboardList(league: league))
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _LeagueLeaderboardList extends StatefulWidget {
  final String league;

  const _LeagueLeaderboardList({required this.league});

  @override
  State<_LeagueLeaderboardList> createState() => _LeagueLeaderboardListState();
}

class _LeagueLeaderboardListState extends State<_LeagueLeaderboardList> {
  int? _previousRank;
  int? _currentRank;
  bool _showRankClimb = false;

  void _updateRank(List<LeaderboardEntry> users) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final rank = users.indexWhere((user) => user.userId == uid);
    if (rank == -1) return;
    final oneBasedRank = rank + 1;

    if (_previousRank != null && oneBasedRank < _previousRank!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _currentRank = oneBasedRank;
          _showRankClimb = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() => _showRankClimb = false);
        });
      });
    } else {
      _currentRank = oneBasedRank;
    }

    _previousRank = oneBasedRank;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeaderboardEntry>>(
      stream: context.read<LeagueProvider>().getLeagueLeaderboard(widget.league),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: VarnamalaTheme.peacockTeal,
              strokeWidth: 3,
            ),
          );
        }

        final users = snapshot.data ?? const <LeaderboardEntry>[];
        _updateRank(users);
        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users in ${widget.league.toTitleCase} yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: VarnamalaTheme.textHint),
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _LeaderboardTile(rank: index + 1, user: user);
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedSlide(
                offset: _showRankClimb ? Offset.zero : const Offset(0, -1.4),
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _showRankClimb ? 1 : 0,
                  duration: const Duration(milliseconds: 280),
                  child: _RankClimbCard(rank: _currentRank ?? 0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RankClimbCard extends StatelessWidget {
  final int rank;

  const _RankClimbCard({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: VarnamalaTheme.success.withValues(alpha: 0.5)),
        boxShadow: VarnamalaTheme.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up_rounded, color: VarnamalaTheme.successDark),
          const SizedBox(width: 8),
          Text(
            'You climbed to #$rank',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: VarnamalaTheme.successDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _LeagueHeader extends StatelessWidget {
  final TabController controller;

  const _LeagueHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B2FBE), Color(0xFF9B59B6)],
        ),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: VarnamalaTheme.leagueAmethyst.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Weekly League XP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: controller,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.75),
            indicatorColor: Colors.white,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: LeagueProvider.leagues
                .map((league) => Tab(text: league.toTitleCase))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry user;

  const _LeaderboardTile({required this.rank, required this.user});

  @override
  Widget build(BuildContext context) {
    final isTopTen = rank <= 10;
    final isBottomFive = rank > 25;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        border: Border.all(
          color: isTopTen
              ? VarnamalaTheme.success.withValues(alpha: 0.45)
              : isBottomFive
                  ? VarnamalaTheme.error.withValues(alpha: 0.28)
                  : const Color(0xFFEEF2F1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isTopTen
                    ? VarnamalaTheme.successDark
                    : isBottomFive
                        ? VarnamalaTheme.error
                        : VarnamalaTheme.textHint,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Generated from the avatar seed, so opening the leaderboard never
          // fetches anyone's Google photo.
          Identicon(
            seed: user.profileImage.isEmpty ? user.userId : user.profileImage,
            size: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.shield_rounded,
                      size: 14,
                      color: VarnamalaTheme.leagueAmethyst,
                    ),
                  ],
                ),
                if (user.languages.isNotEmpty)
                  Text(
                    user.languages.join(', ').toTitleCase,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: VarnamalaTheme.peacockTeal,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: VarnamalaTheme.peacockTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
            ),
            child: Text(
              '${user.effectiveLeagueXp} XP',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: VarnamalaTheme.peacockTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
