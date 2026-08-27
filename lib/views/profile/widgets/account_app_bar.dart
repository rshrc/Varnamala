// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/identity_provider.dart';
import 'package:words625/views/profile/widgets/edit_identity_sheet.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/identicon.dart';

class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(0);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// The learner's own account card.
///
/// Shows the public handle and generated avatar — the same thing everyone else
/// sees — rather than the Google name, email and photo it used to print. See
/// `lib/core/identity.dart` for why.
class AccountWidget extends StatelessWidget {
  const AccountWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final identity = context.watch<IdentityProvider>();
    final handle = identity.handle ?? 'Learner';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
        border: Border.all(color: context.appBorder),
      ),
      child: Row(
        children: [
          Identicon(seed: identity.avatarSeed ?? handle, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  handle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Only this is shown to others',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appTextSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit handle and avatar',
            icon: Icon(Icons.edit_rounded, color: context.appInfo),
            onPressed: () => showEditIdentitySheet(context),
          ),
        ],
      ),
    );
  }
}
