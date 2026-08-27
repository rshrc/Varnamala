// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:words625/core/identity.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/identicon.dart';

class SocialFriends extends StatelessWidget {
  const SocialFriends({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.group_rounded, color: context.appViolet, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Friends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
              border: Border.all(color: context.appBorder),
            ),
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.appAccent,
                    ),
                  );
                }

                final user = snapshot.data;

                if (user == null) {
                  return const Center(
                      child: Text('Please sign in to view friends'));
                }

                return ContainedTabBarView(
                  tabBarProperties: TabBarProperties(
                    indicatorColor: context.appAccent,
                    indicatorWeight: 3,
                    labelColor: context.appAccent,
                    unselectedLabelColor: context.appTextSecondary,
                  ),
                  tabs: const [
                    _TabLabel(text: 'FOLLOWING'),
                    _TabLabel(text: 'FOLLOWERS'),
                  ],
                  views: [
                    PaginatedFollowingList(userId: user.uid),
                    PaginatedFollowersList(userId: user.uid),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String text;
  const _TabLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    );
  }
}

class FriendItem extends StatelessWidget {
  final String image;
  final String name;
  final String xp;

  const FriendItem({
    Key? key,
    required this.image,
    required this.name,
    required this.xp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Identicon(seed: image.isEmpty ? name : image, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$xp XP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaginatedFollowersList extends StatefulWidget {
  final String userId;
  const PaginatedFollowersList({Key? key, required this.userId})
      : super(key: key);

  @override
  PaginatedFollowersListState createState() => PaginatedFollowersListState();
}

class PaginatedFollowersListState extends State<PaginatedFollowersList> {
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<DocumentSnapshot> _followers = [];

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchFollowers() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('followers')
        .orderBy('followedAt')
        .limit(_pageSize);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _lastDocument = snapshot.docs.last;
        _followers.addAll(snapshot.docs);
        if (snapshot.docs.length < _pageSize) _hasMore = false;
      });
    } else {
      _hasMore = false;
    }
    setState(() => _isLoadingMore = false);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) _fetchFollowers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_followers.isEmpty && !_isLoadingMore) {
      return Center(
        child: Text('No followers yet',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.appTextSecondary)),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: _followers.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 68, endIndent: 16),
      itemBuilder: (context, index) {
        if (index < _followers.length) {
          final data = _followers[index].data() as Map<String, dynamic>;
          final userId = _followers[index].id;
          return FriendItem(
            image: data['avatarSeed'] as String? ?? userId,
            name: displayHandle(
              storedHandle: data['handle'] as String?,
              userId: userId,
            ),
            xp: 'N/A',
          );
        }
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: context.appAccent)));
      },
    );
  }
}

class PaginatedFollowingList extends StatefulWidget {
  final String userId;
  const PaginatedFollowingList({Key? key, required this.userId})
      : super(key: key);

  @override
  PaginatedFollowingListState createState() => PaginatedFollowingListState();
}

class PaginatedFollowingListState extends State<PaginatedFollowingList> {
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<DocumentSnapshot> _following = [];

  @override
  void initState() {
    super.initState();
    _fetchFollowing();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchFollowing() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('following')
        .orderBy('followedAt')
        .limit(_pageSize);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _lastDocument = snapshot.docs.last;
        _following.addAll(snapshot.docs);
        if (snapshot.docs.length < _pageSize) _hasMore = false;
      });
    } else {
      _hasMore = false;
    }
    setState(() => _isLoadingMore = false);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) _fetchFollowing();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_following.isEmpty && !_isLoadingMore) {
      return Center(
        child: Text('Not following anyone yet',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.appTextSecondary)),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: _following.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 68, endIndent: 16),
      itemBuilder: (context, index) {
        if (index < _following.length) {
          final data = _following[index].data() as Map<String, dynamic>;
          final userId = _following[index].id;
          return FriendItem(
            image: data['avatarSeed'] as String? ?? userId,
            name: displayHandle(
              storedHandle: data['handle'] as String?,
              userId: userId,
            ),
            xp: 'N/A',
          );
        }
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: context.appAccent)));
      },
    );
  }
}
