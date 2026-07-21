// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

/// One message in a course's discussion.
///
/// The author is stored as their public handle and avatar seed, copied in at
/// write time — a comment must never be able to surface the Google account
/// behind it, even if someone reads the raw documents.
class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.authorId,
    required this.handle,
    required this.avatarSeed,
    required this.text,
    required this.parentId,
    required this.score,
    required this.isDeleted,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String handle;
  final String avatarSeed;
  final String text;

  /// Null for a top-level comment, otherwise the comment being replied to.
  final String? parentId;

  final int score;

  /// Deleted comments are kept as tombstones so their replies still make sense.
  final bool isDeleted;

  final DateTime? createdAt;

  bool get isReply => parentId != null;

  factory CommunityComment.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CommunityComment(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      handle: data['handle'] as String? ?? 'Learner',
      avatarSeed: data['avatarSeed'] as String? ?? doc.id,
      text: data['text'] as String? ?? '',
      parentId: data['parentId'] as String?,
      score: (data['score'] as num? ?? 0).toInt(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// A learner flagging lesson content as wrong, for someone to review.
enum ReportReason {
  wrongTranslation('The translation is wrong'),
  unnaturalPhrasing('No one actually says it this way'),
  wrongRomanization('The spelling does not match the sound'),
  wrongAnswer('The marked answer is not correct'),
  other('Something else');

  const ReportReason(this.label);

  final String label;
}
