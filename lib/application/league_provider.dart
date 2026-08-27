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

  Stream<String> getUserLeagueStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(leagues.first);
    }

    return _firestore.collection('users').doc(userId).snapshots().map(
        (snapshot) => snapshot.data()?['league'] as String? ?? leagues.first);
  }

  Stream<int> getUserLeagueXpStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final value = snapshot.data()?['leagueXp'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    });
  }

  Stream<List<LeaderboardEntry>> getLeagueLeaderboard(String league) {
    return _firestore
        .collection('users')
        .limit(500)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => LeaderboardEntry.fromMap(doc.id, doc.data()))
          .where((entry) {
        final userLeague =
            entry.league.trim().isEmpty ? leagues.first : entry.league;
        if (league == leagues.first) {
          // Backward-compatible default: users without explicit league appear in Bronze.
          return userLeague == leagues.first || !leagues.contains(userLeague);
        }
        return userLeague == league;
      }).toList();

      users.sort((a, b) {
        final byLeagueXp = b.effectiveLeagueXp.compareTo(a.effectiveLeagueXp);
        if (byLeagueXp != 0) return byLeagueXp;
        return b.score.compareTo(a.score);
      });

      if (users.length > 30) {
        return users.sublist(0, 30);
      }
      return users;
    });
  }
}
