// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/core/extensions.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/theme.dart';

class CharactersAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CharactersAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: PreferenceBuilder<String>(
        preference: getIt<AppPrefs>().currentLanguage,
        builder: (context, currentLanguage) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.translate_rounded, color: context.appInfo, size: 22),
              const SizedBox(width: 8),
              Text(
                '${currentLanguage.toTitleCase} Script',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
