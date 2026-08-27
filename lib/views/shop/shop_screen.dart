// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/game_provider.dart';
import 'package:words625/application/gems_provider.dart';
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/views/auth/components/logout_button.dart';
import 'package:words625/views/theme.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: context.read<GameProvider>().getUserGameStateStream(),
      builder: (context, snapshot) {
        final gameState = snapshot.data ?? const <String, dynamic>{};
        final repairRequired =
            gameState['streakRepairRequired'] as bool? ?? false;
        final repairProgress =
            (gameState['streakRepairProgress'] as num? ?? 0).toInt();
        final repairTarget = (gameState['streakRepairTarget'] as num? ??
                GameProvider.defaultStreakRepairTarget)
            .toInt();
        final followRewardClaimed =
            gameState['followRewardClaimed'] as bool? ?? false;
        final validatedShareCount =
            (gameState['validatedShareCount'] as num? ?? 0).toInt();
        final claimedShareCount =
            (gameState['claimedShareCount'] as num? ?? 0).toInt();
        final canClaimShare = validatedShareCount > claimedShareCount;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Learn To Repair',
                icon: Icons.local_fire_department_rounded,
                iconColor: Color(0xFFFF9500),
              ),
            ),
            SliverToBoxAdapter(
              child: ShopItem(
                icon: Icons.ac_unit_rounded,
                iconColor: const Color(0xFF42A5F5),
                label: 'Streak Repair',
                description: repairRequired
                    ? 'Answer more questions and challenges to repair your streak.'
                    : 'Your streak is healthy. Keep learning daily.',
                buttonLabel: repairRequired
                    ? '$repairProgress / $repairTarget'
                    : 'ACTIVE',
                enabled: false,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  color: context.appInfo,
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusMedium),
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusMedium),
                    onTap: () => context.router.push(const MatchWordsRoute()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Try Match Madness',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Community Rewards',
                icon: Icons.bolt_rounded,
                iconColor: VarnamalaTheme.warning,
              ),
            ),
            SliverToBoxAdapter(
              child: ShopItem(
                icon: Icons.person_add_alt_rounded,
                iconColor: const Color(0xFF66BB6A),
                label: 'Follow Reward',
                description:
                    'Follow learners to claim a one-time community gem reward.',
                buttonLabel: followRewardClaimed ? 'CLAIMED' : 'CLAIM',
                enabled: !followRewardClaimed,
                onTap: followRewardClaimed
                    ? null
                    : () =>
                        _handleCommunityClaim(context, CommunityAction.follow),
              ),
            ),
            SliverToBoxAdapter(
              child: ShopItem(
                icon: Icons.flash_on_rounded,
                iconColor: const Color(0xFFAB47BC),
                label: 'Share Reward',
                description:
                    'Claim only after share validation (server-validated shares).',
                buttonLabel: canClaimShare ? 'CLAIM' : 'PENDING VALIDATION',
                enabled: canClaimShare,
                onTap: canClaimShare
                    ? () => _handleCommunityClaim(
                        context, CommunityAction.validatedShare)
                    : null,
              ),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Outfits',
                icon: Icons.checkroom_rounded,
                iconColor: VarnamalaTheme.leagueAmethyst,
              ),
            ),
            const SliverToBoxAdapter(
              child: ShopItem(
                icon: Icons.workspace_premium_rounded,
                iconColor: Color(0xFF5C6BC0),
                label: 'Formal Attire',
                description: "Learn in style. Mala has always been sharp.",
                buttonLabel: 'COMING SOON',
                enabled: false,
              ),
            ),
            const SliverToBoxAdapter(
              child: ShopItem(
                icon: Icons.diamond_rounded,
                iconColor: Color(0xFFAB47BC),
                label: 'Luxury Tracksuit',
                description: 'Mala will love the luxury feathers.',
                buttonLabel: 'COMING SOON',
                enabled: false,
              ),
            ),
            const SliverToBoxAdapter(
              child: ShopItem(
                icon: Icons.auto_awesome_rounded,
                iconColor: Color(0xFFEF5350),
                label: 'Super Mala',
                description: 'Turn Mala into a fearless feathered Guru.',
                buttonLabel: 'COMING SOON',
                enabled: false,
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: LogoutButton(),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        );
      },
    );
  }

  Future<void> _handleCommunityClaim(
    BuildContext context,
    CommunityAction action,
  ) async {
    final success =
        await context.read<GemsProvider>().claimCommunityReward(action);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Reward claimed. Keep learning and contributing.'
              : 'Validation pending or already claimed.',
        ),
        backgroundColor: success ? context.appSuccess : context.appDanger,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: VarnamalaTheme.adaptiveAccent(context, iconColor),
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class ShopItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onTap;
  final bool enabled;

  const ShopItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    this.buttonLabel,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = VarnamalaTheme.adaptiveAccent(context, iconColor);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appTextSecondary,
                        height: 1.3,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    if (buttonLabel != null)
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: enabled ? onTap : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: enabled
                                ? context.appAccent
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            foregroundColor: enabled
                                ? Theme.of(context).colorScheme.onPrimary
                                : context.appTextSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(
                            buttonLabel!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
