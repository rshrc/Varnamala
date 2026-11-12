import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/core/identity.dart';

part 'leaderboard_entry.freezed.dart';

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String userId,
    required String name,
    required String profileImage,
    required int score,
    required int leagueXp,
    required String league,
    required List<String> languages,
    String? preferredLanguage,
    @Default({}) Map<String, String> leagueByLanguage,
    @Default({}) Map<String, int> leagueXpByLanguage,
    @Default(false) bool excludedFromLeagues,
  }) = _LeaderboardEntry;

  const LeaderboardEntry._();

  int get effectiveLeagueXp => leagueXp == 0 && score > 0 ? score : leagueXp;

  String leagueFor(String language) {
    final scoped = leagueByLanguage[language];
    if (scoped != null && scoped.trim().isNotEmpty) return scoped;
    return league;
  }

  int leagueXpFor(String language) {
    final scoped = leagueXpByLanguage[language];
    if (scoped != null) return scoped;
    if (leagueXpByLanguage.isNotEmpty) return 0;

    final home =
        preferredLanguage ?? (languages.length == 1 ? languages.single : null);
    return home == null || home == language ? effectiveLeagueXp : 0;
  }

  LeaderboardEntry withLeagueXp(String language, int xp) =>
      copyWith(leagueXpByLanguage: {...leagueXpByLanguage, language: xp});

  factory LeaderboardEntry.fromMap(String userId, Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: userId,
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
      excludedFromLeagues: map['excludedFromLeagues'] as bool? ?? false,
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
