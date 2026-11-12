// Flutter imports:
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:words625/views/theme.dart';

class ChooseLanguageAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const ChooseLanguageAppbar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(75);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: context.router.canPop()
          ? Padding(
              padding: const EdgeInsets.only(left: 15),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: context.appInfo, size: 32),
                onPressed: () => context.router.maybePop(),
              ),
            )
          : null,
    );
  }
}
