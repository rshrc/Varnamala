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

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.profileImage,
    required this.score,
    required this.leagueXp,
    required this.league,
    required this.languages,
  });

  int get effectiveLeagueXp {
    if (leagueXp == 0 && score > 0) {
      return score;
    }
    return leagueXp;
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
    );
  }
}
