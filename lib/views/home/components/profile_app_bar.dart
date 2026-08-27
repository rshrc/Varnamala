// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:words625/views/settings/settings_page.dart';
import 'package:words625/views/theme.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Profile',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share_rounded, color: context.appInfo, size: 22),
          tooltip: 'Share',
          onPressed: () => _shareApp(context),
        ),
        IconButton(
          icon:
              Icon(Icons.settings_rounded, color: context.appWarning, size: 22),
          tooltip: 'Settings',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          ),
        ),
      ],
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    const text = 'Learn Indian languages for free with Varnamala — no hearts, '
        'no energy limits. https://github.com/rshrc/Varnamala';
    final box = context.findRenderObject() as RenderBox?;

    try {
      await SharePlus.instance.share(
        ShareParams(
          subject: 'Learn with Varnamala',
          text: text,
          sharePositionOrigin:
              box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share link copied to clipboard.')),
        );
      }
    }
  }
}
