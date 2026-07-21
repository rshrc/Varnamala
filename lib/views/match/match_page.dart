// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:chiclet/chiclet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/game_provider.dart';
import 'package:words625/application/match_provider.dart';
import 'package:words625/views/theme.dart';

/// Match Madness: an endless run where the clock is the only thing standing
/// between you and a bigger score.
class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  MatchMode? _mode;
  bool _scoreBanked = false;

  // Held directly rather than read from context, so the score can still be
  // banked while the route is on its way out.
  GameProvider? _game;
  MatchProvider? _match;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game = context.read<GameProvider>();
    _match = context.read<MatchProvider>();
  }

  /// XP earned in Match Madness counts like any other lesson: it goes through
  /// the same transaction that also advances the streak and daily goal.
  ///
  /// Called on every way out of the game — running out of time, closing the
  /// screen, swiping back — because quitting a good run and losing the points
  /// would feel like a bug.
  Future<void> _bankScore() async {
    final match = _match;
    if (_scoreBanked || match == null || match.score <= 0) return;
    _scoreBanked = true;
    final game = _game;
    if (game == null) return;
    await game.incrementScore(match.score);
    // Feeds the Match Madness badges.
    await game.bumpStat('matchGamesPlayed');
    await game.bumpStat('matchRoundsCleared', by: match.round);
    await game.recordBest('matchBestScore', match.score);
    await game.recordBest('matchBestCombo', match.bestCombo);
  }

  void _play(MatchMode mode) {
    setState(() {
      _mode = mode;
      _scoreBanked = false;
    });
    _match?.start(mode);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _bankScore();
      },
      child: Scaffold(
        backgroundColor: VarnamalaTheme.scaffoldBackground,
        body: SafeArea(
          child: _mode == null
              ? _ModePicker(onPick: _play)
              : Consumer<MatchProvider>(
                  builder: (context, match, _) {
                    if (!match.isReady) return const _NotEnoughContent();
                    if (match.isGameOver) {
                      // Bank as soon as the clock stops, so the total on the
                      // results screen is already safely stored.
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _bankScore());
                      return _GameOver(
                        match: match,
                        onPlayAgain: () => _play(match.mode),
                        onExit: () => Navigator.of(context).pop(),
                      );
                    }
                    return _Board(match: match);
                  },
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mode picker
// ---------------------------------------------------------------------------

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.onPick});

  final ValueChanged<MatchMode> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 28),
              color: VarnamalaTheme.textHint,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          Text(
            'Match Madness',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: VarnamalaTheme.peacockTeal,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Clear a round to buy more time.\nThe clock never gets kinder.',
            textAlign: TextAlign.center,
            style: TextStyle(color: VarnamalaTheme.textHint, height: 1.4),
          ),
          const SizedBox(height: 36),
          for (final mode in MatchMode.values) ...[
            _ModeCard(mode: mode, onTap: () => onPick(mode)),
            const SizedBox(height: 16),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onTap});

  final MatchMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWords = mode == MatchMode.words;
    final colour =
        isWords ? VarnamalaTheme.peacockTeal : VarnamalaTheme.peacockCyan;

    return ChicletAnimatedButton(
      width: double.infinity,
      height: 96,
      backgroundColor: colour,
      borderRadius: 20,
      onPressed: onTap,
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(
            isWords ? Icons.translate_rounded : Icons.abc_rounded,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(width: 18),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mode.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mode.blurb,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The board
// ---------------------------------------------------------------------------

class _Board extends StatelessWidget {
  const _Board({required this.match});

  final MatchProvider match;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _HeaderBar(match: match),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Column(
                        items: match.prompts,
                        selected: match.selectedPrompt,
                        matched: match.matchedPrompts,
                        onTap: match.selectPrompt,
                        missPulse: match.missPulse,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Column(
                        items: match.answers,
                        selected: match.selectedAnswer,
                        matched: match.matchedAnswers,
                        onTap: match.selectAnswer,
                        missPulse: match.missPulse,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // A round clear is the reward moment — say so loudly.
        if (match.roundPulse > 0)
          IgnorePointer(
            child: Center(
              child: _RoundBanner(
                key: ValueKey('round-${match.roundPulse}'),
                round: match.round,
                seconds: match.secondsRemaining,
              ),
            ),
          ),
      ],
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.match});

  final MatchProvider match;

  @override
  Widget build(BuildContext context) {
    final low = match.isRunningLow;
    final fraction =
        (match.secondsRemaining / MatchProvider.startingSeconds).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: VarnamalaTheme.textHint,
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Round ${match.round + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: VarnamalaTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              _ScorePill(match: match),
            ],
          ),
          const SizedBox(height: 10),
          // Timer bar: it drains, and turns to alarm colours near the end.
          ClipRRect(
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: fraction, end: fraction),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor: VarnamalaTheme.textHint.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation<Color>(
                  low ? VarnamalaTheme.error : VarnamalaTheme.peacockTurquoise,
                ),
              ),
            ),
          )
              .animate(target: low ? 1 : 0)
              .shimmer(duration: 900.ms, color: VarnamalaTheme.errorLight),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${match.secondsRemaining}s',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: low ? VarnamalaTheme.error : VarnamalaTheme.textHint,
                ),
              ),
              if (match.multiplier > 1)
                Text(
                  '${match.multiplier}x  ·  ${match.combo} in a row',
                  key: ValueKey('combo-${match.combo}'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: VarnamalaTheme.warning,
                  ),
                ).animate().scale(
                      duration: 220.ms,
                      begin: const Offset(1.25, 1.25),
                      end: const Offset(1, 1),
                      curve: Curves.easeOut,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.match});

  final MatchProvider match;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: VarnamalaTheme.peacockTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
          ),
          child: Text(
            '${match.score}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: VarnamalaTheme.peacockTeal,
            ),
          ),
        ),
        // Points fly off the pill each time a pair lands.
        if (match.matchPulse > 0)
          Positioned(
            top: -6,
            child: IgnorePointer(
              child: Text(
                '+${match.lastMatchPoints}',
                key: ValueKey('pop-${match.matchPulse}'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: VarnamalaTheme.warning,
                ),
              )
                  .animate()
                  .moveY(begin: 0, end: -26, duration: 620.ms, curve: Curves.easeOut)
                  .fadeOut(duration: 620.ms),
            ),
          ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.items,
    required this.selected,
    required this.matched,
    required this.onTap,
    required this.missPulse,
  });

  final List<String> items;
  final String? selected;
  final Set<String> matched;
  final ValueChanged<String> onTap;
  final int missPulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var slot = 0; slot < items.length; slot++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            // Each row is a fixed slot. When its pair is cleared the old tile
            // shrinks away and the replacement grows in, rather than the whole
            // board blinking to a new arrangement.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.72, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: _Tile(
                key: ValueKey(items[slot]),
                label: items[slot],
                isSelected: selected == items[slot],
                isMatched: matched.contains(items[slot]),
                missPulse: missPulse,
                onTap: () => onTap(items[slot]),
              ),
            ),
          ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isMatched,
    required this.missPulse,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isMatched;
  final int missPulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = isMatched
        ? VarnamalaTheme.peacockTurquoise
        : isSelected
            ? VarnamalaTheme.peacockTeal
            : const Color(0xFFE3E8EA);

    Widget tile = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        // One height for both columns so the two lists read as rows rather than
        // two ragged stacks.
        height: 66,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          // A solid fill on a match, not a tint — the moment should be
          // unmistakable at a glance.
          color: isMatched
              ? VarnamalaTheme.peacockTurquoise
              : isSelected
                  ? VarnamalaTheme.peacockTeal.withValues(alpha: 0.08)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: isSelected ? 2.5 : 1.6),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isMatched ? Colors.white : VarnamalaTheme.textPrimary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isMatched) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                    .animate()
                    .scale(
                      duration: 260.ms,
                      begin: const Offset(0, 0),
                      curve: Curves.easeOutBack,
                    ),
              ],
            ],
          ),
        ),
      ),
    );

    if (isMatched) {
      // A quick squash-and-stretch reads as "locked in" far better than a
      // single ease.
      tile = tile
          .animate()
          .scale(
            duration: 130.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.06, 1.06),
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            duration: 220.ms,
            begin: const Offset(1, 1),
            end: const Offset(0.97, 0.97),
            curve: Curves.easeInOut,
          );
    } else if (isSelected) {
      // Only the tiles you actually picked shake on a wrong pair.
      tile = tile.animate(key: ValueKey('miss-$missPulse')).shakeX(
            duration: 320.ms,
            amount: 5,
          );
    }
    return tile;
  }
}

class _RoundBanner extends StatelessWidget {
  const _RoundBanner({
    super.key,
    required this.round,
    required this.seconds,
  });

  final int round;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      decoration: BoxDecoration(
        color: VarnamalaTheme.peacockTeal,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Round $round cleared',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'more time on the clock',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    )
        .animate()
        .scale(duration: 260.ms, begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack)
        .then(delay: 500.ms)
        .fadeOut(duration: 320.ms)
        .moveY(end: -20, duration: 320.ms);
  }
}

// ---------------------------------------------------------------------------
// End states
// ---------------------------------------------------------------------------

class _GameOver extends StatelessWidget {
  const _GameOver({
    required this.match,
    required this.onPlayAgain,
    required this.onExit,
  });

  final MatchProvider match;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded,
                size: 76, color: VarnamalaTheme.success)
                .animate()
                .scale(duration: 420.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 12),
            Text(
              "Time's up",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 20),
            _Stat(label: 'Score', value: '${match.score}'),
            _Stat(label: 'Rounds cleared', value: '${match.round}'),
            _Stat(label: 'Pairs matched', value: '${match.totalMatches}'),
            _Stat(label: 'Best streak', value: '${match.bestCombo}'),
            const SizedBox(height: 28),
            ChicletAnimatedButton(
              width: double.infinity,
              height: 52,
              backgroundColor: VarnamalaTheme.peacockTeal,
              onPressed: onPlayAgain,
              child: const Text(
                'Play again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onExit,
              child: const Text('Done',
                  style: TextStyle(color: VarnamalaTheme.textHint)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: VarnamalaTheme.textHint)),
          Text(value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: VarnamalaTheme.peacockTeal,
              )),
        ],
      ),
    );
  }
}

class _NotEnoughContent extends StatelessWidget {
  const _NotEnoughContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'Open a course first so there are enough words to match.',
          textAlign: TextAlign.center,
          style: TextStyle(color: VarnamalaTheme.textHint, height: 1.4),
        ),
      ),
    );
  }
}
