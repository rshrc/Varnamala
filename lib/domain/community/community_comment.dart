import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_comment.freezed.dart';

/// One message in a course's discussion.
@freezed
abstract class CommunityComment with _$CommunityComment {
  const factory CommunityComment({
    required String id,
    required String authorId,
    required String handle,
    required String avatarSeed,
    required String text,
    required String? parentId,
    required int score,
    required bool isDeleted,
    required DateTime? createdAt,
  }) = _CommunityComment;

  const CommunityComment._();

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
