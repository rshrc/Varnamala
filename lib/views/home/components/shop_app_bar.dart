// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/views/widgets/gems_display.dart';
import 'package:words625/views/widgets/beta_badge.dart';

class ShopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShopAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Shop',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 7),
          const BetaBadge(compact: true),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: GemsDisplay(),
        ),
      ],
    );
  }
}
