// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/core/responsive.dart';
import 'package:words625/views/profile/widgets/widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContentBounds(
      maxWidth: ContentWidth.feed,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverToBoxAdapter(child: FriendUpdates()),
          const SliverToBoxAdapter(child: Statistics()),
          const SliverToBoxAdapter(child: FriendSuggestions()),
          const SliverToBoxAdapter(child: SocialFriends()),
          const SliverToBoxAdapter(child: Achievements()),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AccountWidget(),
    );
  }
}
