import 'package:flutter_test/flutter_test.dart';
import 'package:words625/application/league_provider.dart';
import 'package:words625/core/identity.dart';
import 'package:words625/domain/league.dart';

LeaderboardEntry _entry(
  String id, {
  int score = 0,
  int leagueXp = 0,
  String league = 'bronze',
  List<String> languages = const ['tamil'],
}) =>
    LeaderboardEntry(
      userId: id,
      name: id,
      profileImage: id,
      score: score,
      leagueXp: leagueXp,
      league: league,
      languages: languages,
    );

void main() {
  test('an active learner outranks everyone with less XP', () {
    // The bug this guards: a recent joiner with real XP was missing from the
    // board entirely, because the pool was fetched in document-ID order and
    // she fell outside it. Ranking must depend on XP, never on user id.
    final ranked = LeagueProvider.rankForLeague([
      _entry('zzz-late-joiner', score: 2000, leagueXp: 2000),
      _entry('aaa-early-signup', score: 10, leagueXp: 10),
      _entry('bbb-early-signup', score: 500, leagueXp: 500),
    ], 'bronze', 'tamil');

    expect(ranked.map((e) => e.userId).toList(),
        ['zzz-late-joiner', 'bbb-early-signup', 'aaa-early-signup']);
  });

  test('accounts predating leagueXp rank on their score', () {
    final ranked = LeagueProvider.rankForLeague([
      _entry('new', score: 300, leagueXp: 300),
      _entry('legacy', score: 900), // never opened the app since leagueXp
    ], 'bronze', 'tamil');

    expect(ranked.first.userId, 'legacy');
  });

  test('bronze absorbs users with no league or an unknown one', () {
    final ranked = LeagueProvider.rankForLeague([
      _entry('blank', score: 5, league: ''),
      _entry('unknown', score: 6, league: 'obsidian'),
      _entry('explicit', score: 7, league: 'bronze'),
      _entry('elsewhere', score: 8, league: 'gold'),
    ], 'bronze', 'tamil');

    expect(
        ranked.map((e) => e.userId).toList(), ['explicit', 'unknown', 'blank']);
  });

  test('a named league takes only its own members', () {
    final ranked = LeagueProvider.rankForLeague([
      _entry('a', score: 5, league: 'gold'),
      _entry('b', score: 9, league: 'bronze'),
      _entry('c', score: 7, league: 'gold'),
    ], 'gold', 'tamil');

    expect(ranked.map((e) => e.userId).toList(), ['c', 'a']);
  });

  test('everyone in the league is ranked, so no one is invisible', () {
    // The whole league comes back, not just the visible places: a learner
    // below the cut still needs to be shown where they actually stand.
    final ranked = LeagueProvider.rankForLeague([
      for (var i = 0; i < 40; i++) _entry('user-$i', score: 100),
    ], 'bronze', 'tamil');

    expect(ranked.length, 40);
    expect(LeagueProvider.boardSize, lessThan(ranked.length));
    // Every entry ties on XP, so ordering falls back to something stable
    // rather than reshuffling on each snapshot.
    final ids = ranked.map((e) => e.userId).toList();
    final sorted = [...ids]..sort();
    expect(ids, sorted);
  });

  group('finding a friend on the board', () {
    test('a real name is never what appears on the leaderboard', () {
      // Why "I cannot see my friend Sache" is usually not a missing row: the
      // board shows a derived handle, so she is listed under something her
      // friends have never seen.
      final entry = LeaderboardEntry.fromMap('uid-chetana', const {
        'handle': 'Chetan',
        'score': 2000,
        'league': 'bronze',
      });

      expect(entry.name, 'Chetan');
      expect(entry.name, isNot(contains('Sache')));
      // And she still ranks on her XP.
      expect(
        LeagueProvider.rankForLeague([
          entry,
          _entry('someone', score: 10),
        ], 'bronze', 'tamil')
            .first
            .userId,
        'uid-chetana',
      );
    });

    test('an account with no handle yet still gets a stable, distinct name',
        () {
      final entry = LeaderboardEntry.fromMap(
          'uid-no-handle', const {'score': 2000, 'league': 'bronze'});

      expect(entry.name, isNotEmpty);
      expect(entry.name, isNot('Learner'));
      // Stable between snapshots, so a friend does not rename every refresh.
      expect(entry.name, generatedHandle('uid-no-handle'));
    });
  });
}
