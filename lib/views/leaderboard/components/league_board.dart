// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/domain/league.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/identicon.dart';

/// One row's height, including the gap under it.
///
/// Fixed on purpose. The board lays its rows out in a [Stack] so that a change
/// of order *moves* them, and a slide from one place to another needs both
/// places to be known before the rebuild. A ListView reordering its children
/// just swaps them between frames, which is exactly the thing that made a
/// climb invisible.
const double kLeagueRowHeight = 74;

/// The places that get their own colour and their own entrance.
const int kPodiumSize = 3;

/// A leaderboard whose rows move when the standings do.
class LeagueBoard extends StatefulWidget {
  const LeagueBoard({
    required this.users,
    required this.language,
    this.myUserId,
    this.celebrate = false,
    super.key,
  });

  final List<LeaderboardEntry> users;
  final TargetLanguage language;
  final String? myUserId;

  /// Plays the arrival sequence: rows drop in, then the learner's own row
  /// climbs to its place. For the moment after a lesson, not for every visit
  /// to the tab.
  final bool celebrate;

  @override
  State<LeagueBoard> createState() => _LeagueBoardState();
}

class _LeagueBoardState extends State<LeagueBoard> {
  /// Where each learner sat last time the board was built, so an improvement
  /// can be announced rather than silently applied.
  Map<String, int> _previousRanks = {};

  /// Rows whose position improved since the last build.
  Set<String> _climbed = {};

  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    _previousRanks = _ranksOf(widget.users);
    if (!widget.celebrate) {
      _arrived = true;
    } else {
      // One frame at the old positions, then the move. Without the delay the
      // list is built already in its final order and there is nothing to see.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _arrived = true);
      });
    }
  }

  @override
  void didUpdateWidget(LeagueBoard old) {
    super.didUpdateWidget(old);
    final next = _ranksOf(widget.users);
    final climbed = <String>{};
    next.forEach((userId, rank) {
      final before = _previousRanks[userId];
      if (before != null && rank < before) climbed.add(userId);
    });
    _previousRanks = next;
    if (climbed.isNotEmpty) setState(() => _climbed = climbed);
  }

  Map<String, int> _ranksOf(List<LeaderboardEntry> users) => {
        for (var index = 0; index < users.length; index++)
          users[index].userId: index,
      };

  @override
  Widget build(BuildContext context) {
    // A learner who has asked the system for less motion gets the standings,
    // not the show.
    final stillness = MediaQuery.disableAnimationsOf(context);
    final duration =
        stillness ? Duration.zero : const Duration(milliseconds: 620);

    return SizedBox(
      height: widget.users.length * kLeagueRowHeight,
      child: Stack(
        children: [
          for (var index = 0; index < widget.users.length; index++)
            AnimatedPositioned(
              key: ValueKey(widget.users[index].userId),
              duration: duration,
              // Overshoot slightly and settle: a row that eases to a stop
              // reads as sliding, one that springs reads as overtaking.
              curve: Curves.easeOutBack,
              left: 0,
              right: 0,
              top: _arrived
                  ? index * kLeagueRowHeight
                  // Everything starts one place lower and stacked, so the
                  // opening move is the board sorting itself out.
                  : (index + 1) * kLeagueRowHeight,
              height: kLeagueRowHeight,
              child: AnimatedOpacity(
                duration: duration,
                opacity: _arrived ? 1 : 0,
                child: LeagueRow(
                  rank: index + 1,
                  user: widget.users[index],
                  language: widget.language,
                  isMe: widget.users[index].userId == widget.myUserId,
                  justClimbed: _climbed.contains(widget.users[index].userId),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The colours of the three places, derived from the palette rather than
/// hardcoded, so a theme change takes the podium with it.
class PodiumColors {
  const PodiumColors._();

  static Color? forRank(BuildContext context, int rank) => switch (rank) {
        1 => context.appWarning,
        // Silver has no hue of its own; the palette's own neutral is the
        // honest version of it.
        2 => context.appTextSecondary,
        // Bronze is gold dragged towards red.
        3 => Color.lerp(context.appWarning, context.appDanger, 0.45),
        _ => null,
      };

  static IconData? iconForRank(int rank) => switch (rank) {
        1 => Icons.workspace_premium_rounded,
        2 || 3 => Icons.military_tech_rounded,
        _ => null,
      };
}

/// One learner's place on the board.
class LeagueRow extends StatelessWidget {
  const LeagueRow({
    required this.rank,
    required this.user,
    required this.language,
    this.isMe = false,
    this.justClimbed = false,
    super.key,
  });

  final int rank;
  final LeaderboardEntry user;
  final TargetLanguage language;
  final bool isMe;

  /// Whether this row moved up in the most recent update.
  final bool justClimbed;

  @override
  Widget build(BuildContext context) {
    final podium = PodiumColors.forRank(context, rank);
    final medal = PodiumColors.iconForRank(rank);
    final isBottomFive = rank > 25;

    final accent = isMe
        ? context.appAccent
        : podium ?? (isBottomFive ? context.appDanger : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? context.appAccent.withValues(alpha: 0.10)
              : podium != null
                  ? podium.withValues(alpha: 0.07)
                  : context.appSurface,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          border: Border.all(
            width: isMe || podium != null ? 2 : 1,
            color:
                accent?.withValues(alpha: isMe ? 1 : 0.55) ?? context.appBorder,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: medal != null
                  ? _Medal(rank: rank, colour: podium!)
                  : Text(
                      '$rank',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isBottomFive
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
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        _Pill(label: 'YOU', colour: context.appAccent),
                      ],
                      if (justClimbed) ...[
                        const SizedBox(width: 6),
                        _ClimbFlash(colour: context.appSuccess),
                      ],
                    ],
                  ),
                  if (user.languages.isNotEmpty)
                    Text(
                      user.languages.join(', ').toTitleCase,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.appInfo,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.appSuccess.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
              ),
              child: Text(
                '${user.leagueXpFor(language.name)} XP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.appSuccess,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The podium mark, with a different arrival for each place.
///
/// First place keeps turning; second and third settle and stop. The difference
/// is the point - three identical medals in three colours is a ranking, not a
/// podium.
class _Medal extends StatelessWidget {
  const _Medal({required this.rank, required this.colour});

  final int rank;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      PodiumColors.iconForRank(rank),
      color: colour,
      size: rank == 1 ? 26 : 22,
      semanticLabel: switch (rank) {
        1 => 'First place',
        2 => 'Second place',
        _ => 'Third place',
      },
    );

    if (MediaQuery.disableAnimationsOf(context)) return icon;

    return switch (rank) {
      // Gold rises and keeps a slow shine.
      1 => _Pulse(child: icon),
      // Silver and bronze pop in once, bronze a beat later, so the podium
      // resolves top-down instead of all at once.
      2 => _PopIn(delay: const Duration(milliseconds: 90), child: icon),
      _ => _PopIn(delay: const Duration(milliseconds: 180), child: icon),
    };
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  // Three beats and then still. A crown that never stops throbbing is a
  // distraction on a list somebody is trying to read, and an animation that
  // never ends also means the screen never settles.
  static const int _beats = 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 640 * _beats),
  )..forward();

  late final Animation<double> _scale = TweenSequence<double>([
    for (var beat = 0; beat < _beats; beat++) ...[
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.16)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.16, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ],
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}

class _PopIn extends StatelessWidget {
  const _PopIn({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Interval(
        delay.inMilliseconds / 600,
        1,
        curve: Curves.easeOutBack,
      ),
      builder: (context, value, child) => Transform.scale(
        scale: value.clamp(0.0, 1.4),
        child: child,
      ),
      child: child,
    );
  }
}

/// A brief "moved up" mark on a row that just overtook someone.
class _ClimbFlash extends StatelessWidget {
  const _ClimbFlash({required this.colour});

  final Color colour;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - value)),
          child: child,
        ),
      ),
      child: Icon(Icons.arrow_upward_rounded, size: 15, color: colour),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.colour});

  final String label;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          color: context.appOn(colour),
        ),
      ),
    );
  }
}
