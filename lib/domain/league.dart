// Project imports:
import 'package:words625/core/identity.dart';

class League {
  final String id;
  final String name;
  final int tier;

  const League({
    required this.id,
    required this.name,
    required this.tier,
  });
}

class LeaderboardEntry {
  final String userId;
  final String name;
  final String profileImage;
  final int score;
  final int leagueXp;
  final String league;
  final List<String> languages;

  /// The language this learner is studying now, and the one their legacy
  /// league standing is attributed to. Null on accounts that predate it.
  final String? preferredLanguage;

  /// Tier per language. Empty on accounts that have not opened the app since
  /// leagues became language-scoped.
  final Map<String, String> leagueByLanguage;

  /// League-cycle XP per language, likewise.
  final Map<String, int> leagueXpByLanguage;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.profileImage,
    required this.score,
    required this.leagueXp,
    required this.league,
    required this.languages,
    this.preferredLanguage,
    this.leagueByLanguage = const {},
    this.leagueXpByLanguage = const {},
  });

  int get effectiveLeagueXp {
    if (leagueXp == 0 && score > 0) {
      return score;
    }
    return leagueXp;
  }

  /// This learner's tier in [language].
  ///
  /// Falls back to the account-wide tier they already had, so a learner who
  /// has not opened the app since leagues were split by language keeps their
  /// standing rather than appearing to have been demoted to Bronze.
  String leagueFor(String language) {
    final scoped = leagueByLanguage[language];
    if (scoped != null && scoped.trim().isNotEmpty) return scoped;
    return league;
  }

  /// This learner's league XP in [language].
  ///
  /// The account-wide total is claimed by exactly one language - the one they
  /// were studying when the split happened - because it was earned before the
  /// app could tell which language it belonged to. Crediting it to every
  /// language would put a Hindi learner's XP on the Tamil board.
  int leagueXpFor(String language) {
    final scoped = leagueXpByLanguage[language];
    if (scoped != null) return scoped;
    if (leagueXpByLanguage.isNotEmpty) return 0;

    final home =
        preferredLanguage ?? (languages.length == 1 ? languages.single : null);
    return home == null || home == language ? effectiveLeagueXp : 0;
  }

  factory LeaderboardEntry.fromMap(String userId, Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: userId,
      // Public identity only. `name` and `profileImage` are the Google
      // account's and are deliberately not read here — see lib/core/identity.dart.
      name: displayHandle(
        storedHandle: map['handle'] as String?,
        userId: userId,
      ),
      profileImage: map['avatarSeed'] as String? ?? userId,
      score: (map['score'] as num? ?? 0).toInt(),
      leagueXp: (map['leagueXp'] as num? ?? 0).toInt(),
      league: map['league'] as String? ?? 'bronze',
      languages: ((map['languages'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      preferredLanguage: map['preferredLanguage'] as String?,
      leagueByLanguage: _stringMap(map['leagueByLanguage']),
      leagueXpByLanguage: _intMap(map['leagueXpByLanguage']),
    );
  }
}

Map<String, String> _stringMap(dynamic value) {
  if (value is! Map) return const {};
  return {
    for (final entry in value.entries)
      if (entry.key is String && entry.value is String)
        entry.key as String: entry.value as String,
  };
}

Map<String, int> _intMap(dynamic value) {
  if (value is! Map) return const {};
  return {
    for (final entry in value.entries)
      if (entry.key is String && entry.value is num)
        entry.key as String: (entry.value as num).toInt(),
  };
}
