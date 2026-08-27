// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/domain/community/comment.dart';

/// The discussion attached to each course, plus the "this looks wrong" reports
/// that come out of it.
///
/// Learners catch mistakes that no amount of validation will: a translation
/// that is technically right but that nobody says, a romanization that does not
/// match how a word sounds where they live. This is how that reaches us.
class CommunityProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// commentId -> +1 or -1, for the thread currently open.
  Map<String, int> myVotes = {};
  String? _watchedThread;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Stable id for a course's thread. Course titles are shared across languages,
  /// so the language has to be part of the key.
  static String threadId(TargetLanguage language, String courseName) {
    final slug = courseName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return '${language.name}_$slug';
  }

  /// Counters the achievement catalogue reads.
  Future<void> _bumpOwnStat(String field, {int by = 1}) async {
    final uid = currentUserId;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({field: FieldValue.increment(by)}, SetOptions(merge: true));
    } catch (error) {
      logger.e('Could not bump $field: $error');
    }
  }

  CollectionReference<Map<String, dynamic>> _comments(String thread) =>
      _firestore
          .collection('communityThreads')
          .doc(thread)
          .collection('comments');

  /// One document holds all of this user's votes in a thread, so opening a
  /// thread costs a single read instead of one per comment.
  DocumentReference<Map<String, dynamic>>? _voterDoc(String thread) {
    final uid = currentUserId;
    if (uid == null) return null;
    return _firestore
        .collection('communityThreads')
        .doc(thread)
        .collection('voters')
        .doc(uid);
  }

  Stream<List<CommunityComment>> watch(String thread) {
    return _comments(thread)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(CommunityComment.fromDoc)
            .toList(growable: false));
  }

  /// Loads which way this user already voted in [thread].
  Future<void> loadMyVotes(String thread) async {
    if (_watchedThread == thread) return;
    _watchedThread = thread;
    myVotes = {};
    notifyListeners();

    final doc = _voterDoc(thread);
    if (doc == null) return;
    try {
      final snapshot = await doc.get();
      myVotes = (snapshot.data() ?? const {}).map(
        (commentId, value) => MapEntry(commentId, (value as num).toInt()),
      );
      notifyListeners();
    } catch (error) {
      logger.e('Could not load votes: $error');
    }
  }

  Future<String?> post({
    required String thread,
    required String text,
    required String handle,
    required String avatarSeed,
    String? parentId,
  }) async {
    final uid = currentUserId;
    if (uid == null) return 'Sign in to join the discussion.';

    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > 600) return 'Keep it under 600 characters.';

    try {
      await _comments(thread).add({
        'authorId': uid,
        'handle': handle,
        'avatarSeed': avatarSeed,
        'text': trimmed,
        'parentId': parentId,
        'score': 0,
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _bumpOwnStat('commentsPosted');
      return null;
    } catch (error, stackTrace) {
      logger.e('Could not post comment', error: error, stackTrace: stackTrace);
      return 'Could not post. Try again.';
    }
  }

  /// Applies [value] (+1 or -1). Voting the same way twice clears the vote, the
  /// way every forum works.
  Future<void> vote(String thread, String commentId, int value) async {
    final voterDoc = _voterDoc(thread);
    if (voterDoc == null) return;

    final previous = myVotes[commentId] ?? 0;
    final next = previous == value ? 0 : value;
    final delta = next - previous;
    if (delta == 0) return;

    // Optimistic: the tap should feel instant even on a slow connection.
    if (next == 0) {
      myVotes.remove(commentId);
    } else {
      myVotes[commentId] = next;
    }
    notifyListeners();

    try {
      await _firestore.runTransaction((transaction) async {
        final commentRef = _comments(thread).doc(commentId);
        final snapshot = await transaction.get(commentRef);
        if (!snapshot.exists) return;

        final score = (snapshot.data()?['score'] as num? ?? 0).toInt();
        transaction.update(commentRef, {'score': score + delta});

        // Upvotes on your comment count towards the Explainer badges. Only
        // other people's votes, and only the upward direction.
        final authorId = snapshot.data()?['authorId'] as String?;
        if (authorId != null && authorId != currentUserId && delta != 0) {
          transaction.set(
            _firestore.collection('users').doc(authorId),
            {'helpfulVotes': FieldValue.increment(delta > 0 ? 1 : -1)},
            SetOptions(merge: true),
          );
        }
        transaction.set(
          voterDoc,
          {commentId: next == 0 ? FieldValue.delete() : next},
          SetOptions(merge: true),
        );
      });
    } catch (error, stackTrace) {
      logger.e('Could not vote', error: error, stackTrace: stackTrace);
      // Put the local state back the way it was.
      if (previous == 0) {
        myVotes.remove(commentId);
      } else {
        myVotes[commentId] = previous;
      }
      notifyListeners();
    }
  }

  /// Soft delete: the text goes, the node stays so replies underneath it are
  /// not orphaned.
  Future<void> deleteOwn(String thread, CommunityComment comment) async {
    if (comment.authorId != currentUserId) return;
    try {
      await _comments(thread).doc(comment.id).update({
        'isDeleted': true,
        'text': '',
        'handle': 'Learner',
        'avatarSeed': comment.id,
      });
    } catch (error, stackTrace) {
      logger.e('Could not delete comment',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Files a correction request. Kept in its own collection so it can be
  /// triaged without wading through the discussion.
  Future<String?> reportContent({
    required TargetLanguage language,
    required String courseName,
    required ReportReason reason,
    required String detail,
    String? commentId,
    String? sentence,
  }) async {
    final uid = currentUserId;
    if (uid == null) return 'Sign in to report a mistake.';

    try {
      await _firestore.collection('contentReports').add({
        'language': language.name,
        'course': courseName,
        'thread': threadId(language, courseName),
        'reason': reason.name,
        'reasonLabel': reason.label,
        'detail': detail.trim(),
        // The exact line the learner was looking at, captured automatically so
        // a report is actionable without them having to describe it.
        'sentence': sentence,
        'commentId': commentId,
        'reportedBy': uid,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _bumpOwnStat('reportsFiled');
      return null;
    } catch (error, stackTrace) {
      logger.e('Could not file report', error: error, stackTrace: stackTrace);
      return 'Could not send. Try again.';
    }
  }
}
