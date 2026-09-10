// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/language_provider.dart';
import 'package:words625/application/league_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/core/responsive.dart';
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
    _tabController =
        TabController(length: LeagueProvider.leagues.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A league is per language: a Tamil learner competes with Tamil learners.
    // Watched rather than read once, so switching language rebuilds the board.
    final language = context.watch<LanguageProvider>().selectedLanguage;

    return ContentBounds(
      maxWidth: ContentWidth.feed,
      child: Column(
        children: [
          const SizedBox(height: 12),
          _LeagueHeader(controller: _tabController, language: language),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: LeagueProvider.leagues
                  .map((league) => _LeagueLeaderboardList(
                        league: league,
                        language: language,
                      ))
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueLeaderboardList extends StatefulWidget {
  final String league;
  final TargetLanguage language;

  const _LeagueLeaderboardList({
    required this.league,
    required this.language,
  });

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
      stream: context.read<LeagueProvider>().getLeagueLeaderboard(
            widget.league,
            widget.language.name,
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: context.appAccent,
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
                  ?.copyWith(color: context.appTextSecondary),
            ),
          );
        }

        final uid = FirebaseAuth.instance.currentUser?.uid;
        final myIndex = users.indexWhere((user) => user.userId == uid);
        final visible = users.take(LeagueProvider.boardSize).toList();
        // A learner below the cut still gets their own row, pinned under the
        // board, so the leaderboard always answers "where am I".
        final showPinnedSelf = myIndex >= visible.length;

        return Stack(
          children: [
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              itemCount: visible.length + 1 + (showPinnedSelf ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _YourHandleNote(
                    handle: myIndex == -1 ? null : users[myIndex].name,
                  );
                }
                final position = index - 1;
                if (position < visible.length) {
                  final user = visible[position];
                  return _LeaderboardTile(
                    rank: position + 1,
                    user: user,
                    isMe: user.userId == uid,
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _LeaderboardTile(
                    rank: myIndex + 1,
                    user: users[myIndex],
                    isMe: true,
                  ),
                );
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
        color: context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: context.appWarning.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: context.appShadowTint.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, color: context.appWarning),
          const SizedBox(width: 8),
          Text(
            'You climbed to #$rank',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.appWarning,
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
  final TargetLanguage language;

  const _LeagueHeader({required this.controller, required this.language});

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
            color: context.appViolet.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              // Naming the language matters: without it the board looks like
              // it lost everyone the moment it stopped being one global list.
              Flexible(
                child: Text(
                  '${language.name.toTitleCase} League XP',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
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
  final bool isMe;

  const _LeaderboardTile({
    required this.rank,
    required this.user,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTopTen = rank <= 10;
    final isBottomFive = rank > 25;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? context.appAccent.withValues(alpha: 0.10)
            : context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        border: Border.all(
          width: isMe ? 2 : 1,
          color: isMe
              ? context.appAccent
              : isTopTen
                  ? context.appWarning.withValues(alpha: 0.55)
                  : isBottomFive
                      ? context.appDanger.withValues(alpha: 0.45)
                      : context.appBorder,
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
                    ? context.appWarning
                    : isBottomFive
                        ? context.appDanger
                        : context.appTextSecondary,
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
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: context.appAccent,
                          borderRadius: BorderRadius.circular(
                            VarnamalaTheme.radiusRound,
                          ),
                        ),
                        child: Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Icon(
                      Icons.shield_rounded,
                      size: 14,
                      color: context.appViolet,
                    ),
                  ],
                ),
                if (user.languages.isNotEmpty)
                  Text(
                    user.languages.join(', ').toTitleCase,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appInfo,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.appSuccess.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
            ),
            child: Text(
              '${user.effectiveLeagueXp} XP',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.appSuccess,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains why nobody on this board is called what their friends call them.
///
/// Varnamala shows a derived handle rather than a real name (see
/// `lib/core/identity.dart`), which is right for privacy but leaves learners
/// hunting for a friend who is listed under a name they have never seen. The
/// fix is not to expose names: it is to tell each learner their own handle, so
/// they can say "look for me as Chetan".
class _YourHandleNote extends StatelessWidget {
  const _YourHandleNote({required this.handle});

  final String? handle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.appInfo.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        border: Border.all(color: context.appInfo.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.badge_outlined, size: 18, color: context.appInfo),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Everyone here is shown by handle, not by name. ',
                  ),
                  if (handle == null)
                    const TextSpan(text: 'Finish a lesson to join the board.')
                  else ...[
                    const TextSpan(text: 'You appear as '),
                    TextSpan(
                      text: handle,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: context.appInfo,
                      ),
                    ),
                    const TextSpan(text: ' — share that to find each other.'),
                  ],
                ],
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.appTextSecondary,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
