// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/application/game_provider.dart';
import 'package:words625/application/league_provider.dart';
import 'package:words625/domain/league.dart';

LeaderboardEntry entry(
  String id, {
  int score = 0,
  int leagueXp = 0,
  String league = 'bronze',
  List<String> languages = const [],
  String? preferredLanguage,
  Map<String, String> leagueByLanguage = const {},
  Map<String, int> leagueXpByLanguage = const {},
}) =>
    LeaderboardEntry(
      userId: id,
      name: id,
      profileImage: id,
      score: score,
      leagueXp: leagueXp,
      league: league,
      languages: languages,
      preferredLanguage: preferredLanguage,
      leagueByLanguage: leagueByLanguage,
      leagueXpByLanguage: leagueXpByLanguage,
    );

void main() {
  group('a league is per language', () {
    test('only learners of that language are ranked', () {
      final ranked = LeagueProvider.rankForLeague([
        entry('tamil-learner',
            languages: ['tamil'], leagueXpByLanguage: {'tamil': 100}),
        entry('hindi-learner',
            languages: ['hindi'], leagueXpByLanguage: {'hindi': 900}),
        entry('both',
            languages: ['tamil', 'hindi'],
            leagueXpByLanguage: {'tamil': 50, 'hindi': 800}),
      ], 'bronze', 'tamil');

      expect(
        ranked.map((e) => e.userId).toList(),
        ['tamil-learner', 'both'],
        reason: 'a Hindi-only learner has no place on the Tamil board',
      );
    });

    test('XP earned in another language does not rank you here', () {
      // The complaint: one board, one XP pool, so somebody grinding Hindi
      // outranked the people actually learning Tamil.
      final ranked = LeagueProvider.rankForLeague([
        entry('tamil-grinder',
            languages: ['tamil', 'hindi'],
            leagueXpByLanguage: {'tamil': 400, 'hindi': 0}),
        entry('hindi-grinder',
            languages: ['tamil', 'hindi'],
            leagueXpByLanguage: {'tamil': 10, 'hindi': 5000}),
      ], 'bronze', 'tamil');

      expect(ranked.first.userId, 'tamil-grinder');
    });

    test('the same learner holds a different rank in each language', () {
      final people = [
        entry('a',
            languages: ['tamil', 'hindi'],
            leagueXpByLanguage: {'tamil': 10, 'hindi': 900}),
        entry('b',
            languages: ['tamil', 'hindi'],
            leagueXpByLanguage: {'tamil': 900, 'hindi': 10}),
      ];

      expect(
          LeagueProvider.rankForLeague(people, 'bronze', 'tamil').first.userId,
          'b');
      expect(
          LeagueProvider.rankForLeague(people, 'bronze', 'hindi').first.userId,
          'a');
    });

    test('tiers are read per language', () {
      final ranked = LeagueProvider.rankForLeague([
        entry('gold-in-tamil',
            languages: ['tamil'],
            league: 'bronze',
            leagueByLanguage: {'tamil': 'gold'},
            leagueXpByLanguage: {'tamil': 5}),
      ], 'gold', 'tamil');

      expect(ranked.map((e) => e.userId), ['gold-in-tamil']);
    });
  });

  group('nobody loses what they had', () {
    test('an account with no per-language data keeps its tier everywhere', () {
      // They have not opened the app since the split. Showing them Bronze
      // would read as a demotion they never earned.
      final legacy = entry('legacy',
          league: 'emerald', leagueXp: 700, languages: ['tamil']);

      expect(legacy.leagueFor('tamil'), 'emerald');
      expect(legacy.leagueFor('hindi'), 'emerald');
    });

    test('legacy XP is claimed by the language they were studying', () {
      final legacy = entry('legacy',
          leagueXp: 700,
          languages: ['tamil', 'hindi'],
          preferredLanguage: 'tamil');

      expect(legacy.leagueXpFor('tamil'), 700);
      expect(
        legacy.leagueXpFor('hindi'),
        0,
        reason: 'crediting it to both would double-count XP earned once',
      );
    });

    test('a single-language account needs no preferredLanguage to keep its XP',
        () {
      final legacy = entry('legacy', leagueXp: 700, languages: ['odia']);
      expect(legacy.leagueXpFor('odia'), 700);
    });

    test('an account predating leagueXp still ranks on its score', () {
      final legacy = entry('legacy', score: 900, languages: ['tamil']);
      expect(legacy.leagueXpFor('tamil'), 900);
    });

    test('once migrated, the legacy total stops being counted again', () {
      final migrated = entry('migrated',
          leagueXp: 700,
          score: 900,
          languages: ['tamil', 'hindi'],
          preferredLanguage: 'tamil',
          leagueXpByLanguage: {'tamil': 700, 'hindi': 0});

      expect(migrated.leagueXpFor('tamil'), 700);
      expect(migrated.leagueXpFor('hindi'), 0);
    });
  });

  group('the migration written on first launch', () {
    test('carries the tier to every language and the XP to one', () {
      final updates = GameProvider.languageLeagueMigration(
        {
          'league': 'ruby',
          'languages': ['tamil', 'hindi'],
          'preferredLanguage': 'hindi',
        },
        initialLeagueXp: 450,
      );

      expect(updates['leagueByLanguage'], {'tamil': 'ruby', 'hindi': 'ruby'});
      expect(updates['leagueXpByLanguage'], {'tamil': 0, 'hindi': 450});
      expect(updates['leagueLanguageMigrated'], isTrue);
    });

    test('backfills languages from preferredLanguage', () {
      // The board query filters on `languages`; an empty array would drop the
      // account off every leaderboard it belongs on.
      final updates = GameProvider.languageLeagueMigration(
        {'preferredLanguage': 'odia', 'league': 'bronze'},
        initialLeagueXp: 20,
      );

      expect(updates['languages'], ['odia']);
      expect(updates['leagueXpByLanguage'], {'odia': 20});
    });

    test('runs once and then leaves the standings alone', () {
      final updates = GameProvider.languageLeagueMigration(
        {
          'league': 'gold',
          'languages': ['tamil'],
          'preferredLanguage': 'tamil',
          'leagueLanguageMigrated': true,
        },
        initialLeagueXp: 999,
      );

      expect(updates.containsKey('leagueXpByLanguage'), isFalse);
      expect(updates.containsKey('leagueByLanguage'), isFalse);
    });

    test('a language added later is still backfilled after migration', () {
      final updates = GameProvider.languageLeagueMigration(
        {
          'league': 'gold',
          'languages': ['tamil'],
          'preferredLanguage': 'telugu',
          'leagueLanguageMigrated': true,
        },
        initialLeagueXp: 999,
      );

      expect(updates['languages'], containsAll(['tamil', 'telugu']));
    });

    test('an account with no language at all is left intact', () {
      final updates = GameProvider.languageLeagueMigration(
        {'league': 'bronze'},
        initialLeagueXp: 30,
      );

      expect(updates['leagueByLanguage'], isEmpty);
      expect(updates['leagueXpByLanguage'], isEmpty);
    });
  });
}
