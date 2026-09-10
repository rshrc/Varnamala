// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/core/extensions.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/domain/league.dart';
import 'package:words625/views/leaderboard/components/league_board.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/beta_badge.dart';

/// A board of invented learners, for demonstrating the climb.
///
/// The real leaderboard cannot be used for this: maintainer accounts are
/// deliberately excluded from the standings, so the person most likely to be
/// showing the app to somebody is the one person who cannot appear on it.
/// These names are fictional and clearly marked as such.
@RoutePage()
class LeagueDemoPage extends StatefulWidget {
  const LeagueDemoPage({super.key});

  @override
  State<LeagueDemoPage> createState() => _LeagueDemoPageState();
}

const String _me = 'demo-you';

class _LeagueDemoPageState extends State<LeagueDemoPage> {
  TargetLanguage _language = TargetLanguage.kannada;

  /// The learner's XP. Everything else is fixed, so raising this is what makes
  /// the board reorder.
  int _myXp = 40;

  static const List<(String, int)> _rivals = [
    ('Meghana', 410),
    ('Arjun', 355),
    ('Priya', 290),
    ('Fahad', 245),
    ('Lakshmi', 180),
    ('Nikhil', 120),
    ('Reshma', 75),
    ('Sathish', 30),
  ];

  List<LeaderboardEntry> get _board {
    final entries = <LeaderboardEntry>[
      for (final (name, xp) in _rivals)
        LeaderboardEntry(
          userId: 'demo-${name.toLowerCase()}',
          name: name,
          profileImage: 'demo-${name.toLowerCase()}',
          score: xp,
          leagueXp: xp,
          league: 'bronze',
          languages: [_language.name],
          leagueXpByLanguage: {_language.name: xp},
        ),
      LeaderboardEntry(
        userId: _me,
        name: 'You',
        profileImage: _me,
        score: _myXp,
        leagueXp: _myXp,
        league: 'bronze',
        languages: [_language.name],
        leagueXpByLanguage: {_language.name: _myXp},
      ),
    ];
    entries.sort((a, b) {
      final byXp = b
          .leagueXpFor(_language.name)
          .compareTo(a.leagueXpFor(_language.name));
      return byXp != 0 ? byXp : a.userId.compareTo(b.userId);
    });
    return entries;
  }

  int get _myRank => _board.indexWhere((entry) => entry.userId == _me) + 1;

  void _finishLesson() => setState(() => _myXp += 85);

  void _reset() => setState(() => _myXp = 40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('League lab'),
            SizedBox(width: 8),
            BetaBadge(compact: true),
          ],
        ),
      ),
      body: SafeArea(
        child: ContentBounds(
          maxWidth: ContentWidth.feed,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _Notice(rank: _myRank, xp: _myXp),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final language in [
                    TargetLanguage.kannada,
                    TargetLanguage.tamil,
                    TargetLanguage.hindi,
                  ])
                    ChoiceChip(
                      label: Text(language.name.toTitleCase),
                      selected: _language == language,
                      onSelected: (_) => setState(() => _language = language),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              LeagueBoard(
                users: _board,
                language: _language,
                myUserId: _me,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _finishLesson,
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('Finish a lesson  +85 XP'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.rank, required this.xp});

  final int rank;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: context.appWarning.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        border: Border.all(color: context.appWarning.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.science_rounded, color: context.appWarning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Invented learners, for showing the climb. '
              'You are #$rank on $xp XP.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
