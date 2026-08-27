// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/views/theme.dart';

class ExploreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExploreAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(55);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 120,
      backgroundColor: context.appSurface,
      elevation: 1.5,
      centerTitle: true,
      title: Text(
        'News Feed',
        style: TextStyle(
          color: context.appTextPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
