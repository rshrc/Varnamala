// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/domain/league.dart';

@injectable
class LeagueProvider extends ChangeNotifier {
  static const List<String> leagues = [
    'bronze',
    'silver',
    'gold',
    'amethyst',
    'pearl',
    'ruby',
    'emerald',
    'diamond',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<String> getUserLeagueStream(String language) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(leagues.first);
    }

    return _firestore.collection('users').doc(userId).snapshots().map(
          (snapshot) => LeaderboardEntry.fromMap(
            userId,
            snapshot.data() ?? const <String, dynamic>{},
          ).leagueFor(language),
        );
  }

  Stream<int> getUserLeagueXpStream(String language) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore.collection('users').doc(userId).snapshots().map(
          (snapshot) => LeaderboardEntry.fromMap(
            userId,
            snapshot.data() ?? const <String, dynamic>{},
          ).leagueXpFor(language),
        );
  }

  /// How many users are pulled down before ranking. The window has to be
  /// ordered (see [getLeagueLeaderboard]) for this to mean "the top N".
  static const int _candidatePoolSize = 300;

  /// How many places each league's board shows.
  static const int boardSize = 30;

  Stream<List<LeaderboardEntry>> getLeagueLeaderboard(
    String league,
    String language,
  ) {
    return _firestore
        .collection('users')
        // Filtered in the query rather than after it. A learner competes with
        // people learning the same language, and Tamil has far fewer learners
        // than Hindi - so taking a global top-300 slice and then keeping the
        // Tamil ones would leave that board nearly empty while excluding
        // active Tamil learners who sit outside the global top 300.
        .where('languages', arrayContains: language)
        // Ordering is not a nicety here. Without it Firestore returns
        // documents by ID, so the pool was an arbitrary slice of accounts
        // keyed on random UIDs and an active learner could sit outside it
        // forever, no matter how much XP they earned. Ordering by score makes
        // the pool the top scorers, which is the only slice worth ranking.
        //
        // `score` rather than `leagueXp` because every account has had a
        // `score` since sign-up, and Firestore drops documents that lack the
        // field being ordered on - which would hide exactly the older accounts
        // that have not opened the app since `leagueXp` was introduced.
        .orderBy('score', descending: true)
        .limit(_candidatePoolSize)
        .snapshots()
        .map((snapshot) => rankForLeague(
              snapshot.docs
                  .map((doc) => LeaderboardEntry.fromMap(doc.id, doc.data()))
                  .toList(),
              league,
              language,
            ));
  }

  /// Picks and orders every entry in [league] who is learning [language].
  ///
  /// Returns the whole ranked league rather than just the visible places, so
  /// a learner sitting below the cut can still be shown their own standing.
  /// Pure, so the ranking rules can be tested without Firestore.
  static List<LeaderboardEntry> rankForLeague(
    List<LeaderboardEntry> entries,
    String league,
    String language,
  ) {
    final users = entries.where((entry) {
      // Belt and braces: the query already filters by language, but this is
      // also called on locally assembled lists.
      if (entry.languages.isNotEmpty && !entry.languages.contains(language)) {
        return false;
      }

      final userLeague = entry.leagueFor(language).trim();
      if (league == leagues.first) {
        // Backward-compatible default: users without an explicit league, or
        // with one we no longer recognise, appear in Bronze.
        return userLeague.isEmpty ||
            userLeague == leagues.first ||
            !leagues.contains(userLeague);
      }
      return userLeague == league;
    }).toList();

    users.sort((a, b) {
      final byLeagueXp =
          b.leagueXpFor(language).compareTo(a.leagueXpFor(language));
      if (byLeagueXp != 0) return byLeagueXp;
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      // A stable tie-break, so equal learners do not swap places on every
      // snapshot the stream delivers.
      return a.userId.compareTo(b.userId);
    });

    return users;
  }
}
