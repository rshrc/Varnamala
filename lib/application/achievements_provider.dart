// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/domain/achievement.dart';
import 'package:words625/domain/achievement_catalogue.dart';

@injectable
class AchievementsProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Every badge, defined in lib/domain/achievement_catalogue.dart.
  static const List<Achievement> allAchievements = achievementCatalogue;

  static final Map<String, Achievement> _achievementById = {
    for (final achievement in allAchievements) achievement.id: achievement,
  };

  Stream<List<String>> getUnlockedAchievements() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(const <String>[]);

    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data() ?? <String, dynamic>{};
      return (data['achievements'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false);
    });
  }

  Future<bool> checkAndUnlock(String achievementId) async {
    final achievement = _achievementById[achievementId];
    if (achievement == null) return false;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final docRef = _firestore.collection('users').doc(userId);

    final unlocked = await _firestore.runTransaction<bool>((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return false;

      final data = doc.data() ?? <String, dynamic>{};
      final unlocked =
          (data['achievements'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toSet();

      if (!unlocked.add(achievementId)) {
        return false;
      }

      // TODO: Logic for gem rewards based on achievement tier
      // For now using simplified flat rate or calculating based on previous logic
      final gems =
          (data['gems'] as num? ?? 0).toInt() + 50; // Placeholder 50 gems
      transaction.update(docRef, {
        'achievements': unlocked.toList(growable: false),
        'gems': gems,
      });

      return true;
    });

    if (unlocked) {
      await _publishToFeed(achievement);
      notifyListeners();
    }
    return unlocked;
  }

  /// Puts the unlock on the public activity feed so other learners can send a
  /// hi-five. Uses the public handle only — never the account name.
  Future<void> _publishToFeed(Achievement achievement) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      final user = await _firestore.collection('users').doc(userId).get();
      final data = user.data() ?? const <String, dynamic>{};
      await _firestore.collection('activity').add({
        'userId': userId,
        'handle': data['handle'] as String? ?? '',
        'avatarSeed': data['avatarSeed'] as String? ?? userId,
        'title': 'earned ${achievement.title} — ${achievement.description}',
        'hiFives': 0,
        'givers': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      debugPrint('Could not publish achievement to feed: $error');
    }
  }

  Future<void> checkLessonMilestones({
    required int lessonsCompleted,
    required int perfectLessons,
  }) async {
    // Check Champion (lessons)
    final champion = _achievementById['champion'];
    if (champion != null) {
      if (lessonsCompleted >= 10)
        await checkAndUnlock('champion'); // Simplified for now
    }

    // Check Sharpshooter (perfect lessons)
    final sharpshooter = _achievementById['sharpshooter'];
    if (sharpshooter != null) {
      if (perfectLessons >= 1) await checkAndUnlock('sharpshooter');
    }
  }

  Future<void> checkLeagueAchievement(String league) async {
    // Implement league checking when league achievements are fully defined
  }
}
