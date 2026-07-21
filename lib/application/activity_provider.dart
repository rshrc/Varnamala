// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:words625/core/identity.dart';
import 'package:words625/core/logger.dart';

/// Something a learner did that others can see and applaud.
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.userId,
    required this.handle,
    required this.avatarSeed,
    required this.title,
    required this.hiFives,
    required this.givers,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String handle;
  final String avatarSeed;

  /// What they did, already written out: "reached a 30 day streak".
  final String title;

  final int hiFives;

  /// Who has already applauded, so the button can show as spent.
  final List<String> givers;

  final DateTime? createdAt;

  factory ActivityItem.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final userId = data['userId'] as String? ?? '';
    return ActivityItem(
      id: doc.id,
      userId: userId,
      handle: displayHandle(
        storedHandle: data['handle'] as String?,
        userId: userId,
      ),
      avatarSeed: data['avatarSeed'] as String? ?? userId,
      title: data['title'] as String? ?? 'did something',
      hiFives: (data['hiFives'] as num? ?? 0).toInt(),
      givers: ((data['givers'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(growable: false),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// The feed of what other learners have just achieved, and the one thing you
/// can do about it: send a hi-five.
///
/// Deliberately the *only* way to contact another learner. There is no inbox,
/// no direct message, no reply — a stranger can acknowledge your streak and
/// nothing more. Unsolicited messaging is how language apps become a place
/// women and beginners quietly stop using.
class ActivityProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _activity =>
      _firestore.collection('activity');

  /// The most recent things anyone has achieved.
  Stream<List<ActivityItem>> watchFeed({int limit = 60}) {
    return _activity
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ActivityItem.fromDoc).toList(growable: false));
  }

  /// Publishes an achievement to the feed.
  Future<void> publish({
    required String title,
    required String handle,
    required String avatarSeed,
  }) async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      await _activity.add({
        'userId': userId,
        'handle': handle,
        'avatarSeed': avatarSeed,
        'title': title,
        'hiFives': 0,
        'givers': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      logger.e('Could not publish activity: $error');
    }
  }

  bool hasHiFived(ActivityItem item) =>
      currentUserId != null && item.givers.contains(currentUserId);

  /// Sends a hi-five. One per person per achievement, and it cannot be taken
  /// back — applause should not be something you can hold over someone.
  Future<void> sendHiFive(ActivityItem item) async {
    final userId = currentUserId;
    if (userId == null || userId == item.userId) return;
    if (item.givers.contains(userId)) return;

    try {
      final batch = _firestore.batch();
      batch.update(_activity.doc(item.id), {
        'hiFives': FieldValue.increment(1),
        'givers': FieldValue.arrayUnion([userId]),
      });
      batch.set(
        _firestore.collection('users').doc(userId),
        {'hiFivesSent': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
      batch.set(
        _firestore.collection('users').doc(item.userId),
        {'hiFivesReceived': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
      await batch.commit();
      notifyListeners();
    } catch (error, stackTrace) {
      logger.e('Could not send hi-five', error: error, stackTrace: stackTrace);
    }
  }
}
