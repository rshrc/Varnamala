// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Project imports:
import 'package:words625/core/extensions.dart';
import 'package:words625/core/identity.dart';
import 'package:words625/views/profile/widgets/follow_button.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/identicon.dart';

class FriendSuggestions extends StatelessWidget {
  const FriendSuggestions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              Icon(Icons.person_add_rounded,
                  color: context.appSuccess, size: 22),
              const SizedBox(width: 8),
              Text(
                'Friend Suggestions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: context.height * 0.22,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: context.appAccent, strokeWidth: 3));
              }

              final currentUser = FirebaseAuth.instance.currentUser;

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text('No suggestions yet',
                      style: Theme.of(context).textTheme.bodyMedium),
                );
              }
              final friends = snapshot.data!.docs;
              friends.shuffle();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friendData =
                      friends[index].data() as Map<String, dynamic>;
                  final targetUserId = friends[index].id;

                  return _FriendCard(
                    image: friendData['avatarSeed'] ?? targetUserId,
                    name: displayHandle(
                      storedHandle: friendData['handle'] as String?,
                      userId: targetUserId,
                    ),
                    targetUserId: targetUserId,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FriendCard extends StatelessWidget {
  final String image;
  final String name;
  final String targetUserId;

  const _FriendCard({
    required this.image,
    required this.name,
    required this.targetUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: context.width * 0.36,
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Identicon(seed: image.isEmpty ? name : image, size: 48),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          FollowButton(
            targetUserId: targetUserId,
            targetUserName: name,
            targetUserProfileImage: image,
          ),
        ],
      ),
    );
  }
}

class BigTitle extends StatelessWidget {
  final String text;
  const BigTitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
