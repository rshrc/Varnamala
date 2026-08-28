// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:countup/countup.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// Project imports:
import 'package:words625/application/game_provider.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/core/language_info.dart';
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/debug/interactive_lesson_demo_page.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/gems_display.dart';
import 'package:words625/views/widgets/hearts_display.dart';
import 'package:words625/views/widgets/loader.dart';
import 'package:words625/views/widgets/patreon_button.dart';

class StatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StatAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60,
      leading: const LanguageSelector(),
      title: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScoreCard(), // Removed initial padding
            Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
            Streak(),
            Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
            GemsDisplay(),
          ],
        ),
      ),
      actions: [
        if (kDebugMode)
          IconButton(
            tooltip: 'Open interactive lesson lab',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const InteractiveLessonDemoPage(),
              ),
            ),
            icon: Icon(Icons.science_rounded, color: context.appViolet),
          ),
        const PatreonButton(),
        const HeartsDisplay(),
      ],
    );
  }
}

class Streak extends StatelessWidget {
  const Streak({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.appWarning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded,
              color: context.appWarning, size: 20),
          const SizedBox(width: 4),
          StreamBuilder<int>(
            stream: context.read<GameProvider>().getUserStreakStream(),
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              if (snapshot.hasError) {
                return const Text('0');
              }
              return Countup(
                begin: 0,
                end: snapshot.data?.toDouble() ?? 0,
                duration: const Duration(milliseconds: 1000),
                separator: ',',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: context.appWarning,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.appWarning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, color: context.appWarning, size: 20),
          const SizedBox(width: 4),
          StreamBuilder<int>(
            stream: context.read<GameProvider>().getUserScoreStream(),
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              if (snapshot.hasError) {
                return const Text('0');
              }
              return Countup(
                begin: 0,
                end: snapshot.data?.toDouble() ?? 0,
                duration: const Duration(milliseconds: 1000),
                separator: ',',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: context.appWarning,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferenceBuilder<String>(
      preference: getIt<AppPrefs>().currentLanguage,
      builder: (context, currentLanguage) {
        return GestureDetector(
          onTap: () {
            context.router.push(const LangChoiceRoute());
          },
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              width: 42,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 2,
                  color: context.appInfo.withValues(alpha: 0.55),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SvgPicture.asset(
                languageInfoByName(currentLanguage).emblem,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
