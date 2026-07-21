// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:words625/core/identity.dart';
import 'package:words625/views/theme.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final String targetUserProfileImage;

  const FollowButton({
    Key? key,
    required this.targetUserId,
    required this.targetUserName,
    required this.targetUserProfileImage,
  }) : super(key: key);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  Future<void> _checkIfFollowing() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final followingDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(widget.targetUserId)
        .get();

    setState(() {
      _isFollowing = followingDoc.exists;
    });
  }

  Future<void> _toggleFollow() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final targetUserDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.targetUserId);

    if (_isFollowing) {
      await userDoc.collection('following').doc(widget.targetUserId).delete();
      await targetUserDoc.collection('followers').doc(currentUserId).delete();
      // Keeps the Friendly badge honest when someone unfollows.
      await userDoc.set(
        {'friendsCount': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );
      setState(() => _isFollowing = false);
    } else {
      final currentUserSnapshot = await userDoc.get();
      final currentUserData = currentUserSnapshot.data();
      if (currentUserData == null) return;

      await userDoc.collection('following').doc(widget.targetUserId).set({
        'name': widget.targetUserName,
        'profileImage': widget.targetUserProfileImage,
        'followedAt': FieldValue.serverTimestamp(),
      });

      await targetUserDoc.collection('followers').doc(currentUserId).set({
        'name': displayHandle(
          storedHandle: currentUserData['handle'] as String?,
          userId: currentUserId,
        ),
        'profileImage': currentUserData['avatarSeed'] ?? '',
        'followedAt': FieldValue.serverTimestamp(),
      });

      await userDoc.set(
        {'friendsCount': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
      setState(() => _isFollowing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Material(
        color: _isFollowing
            ? Colors.transparent
            : VarnamalaTheme.peacockTeal,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
        child: InkWell(
          onTap: _toggleFollow,
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: _isFollowing
                ? BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusSmall),
                    border: Border.all(color: VarnamalaTheme.textHint),
                  )
                : null,
            child: Center(
              child: Text(
                _isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  color: _isFollowing
                      ? VarnamalaTheme.textSecondary
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
