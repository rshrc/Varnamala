// Flutter imports:
import 'package:flutter/material.dart';

import 'package:words625/views/theme.dart';

class LoginAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LoginAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      title: Text(
        'Enter your details',
        style: TextStyle(
          color: context.appTextSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: context.appDanger,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
