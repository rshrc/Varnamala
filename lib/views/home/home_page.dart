// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

// Package imports:
import 'package:auto_route/annotations.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/game_provider.dart';
import 'package:words625/application/gems_provider.dart';
import 'package:words625/application/hearts_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/views/characters/character_drawing.dart';
import 'package:words625/views/characters/characters_app_bar.dart';
import 'package:words625/views/courses/course_tree.dart';
import 'package:words625/views/home/components/components.dart';
import 'package:words625/views/leaderboard/leaderboard_page.dart';
import 'package:words625/views/profile/profile_screen.dart';
import 'package:words625/views/shop/shop_screen.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/onboarding/onboarding_screen.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  /// Drives the app bar and bottom bar out of the way while the learner is
  /// scrolling down, and brings them straight back on the first upward flick.
  late final AnimationController _chrome = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  @override
  void dispose() {
    _chrome.dispose();
    super.dispose();
  }

  bool _onScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    switch (notification.direction) {
      case ScrollDirection.reverse:
        // Only give the chrome up once there is something to scroll back to,
        // otherwise a short list flickers it away on the first drag.
        if (notification.metrics.pixels > 24) _chrome.reverse();
      case ScrollDirection.forward:
        _chrome.forward();
      case ScrollDirection.idle:
        break;
    }
    return false;
  }

  final screens = [
    const CourseTree(),
    const CharacterPracticeScreen(),
    const ProfilePage(),
    const LeaderboardPage(),
    const ShopPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSession();
    });
  }

  initSession() async {
    context.read<LanguageProvider>().initLanguage();
    final gameProvider = context.read<GameProvider>();
    final heartsProvider = context.read<HeartsProvider>();
    final gemsProvider = context.read<GemsProvider>();

    await gameProvider.ensureUserGameFields();
    await gemsProvider.ensureGemsInitialized();
    await heartsProvider.ensureHeartsInitialized();
    await heartsProvider.refillHeart();
    final streakResult = await gameProvider.checkStreakOnAppOpen();

    if (!mounted) return;
    if (streakResult == StreakCheckResult.broken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your streak was broken. Start again today.'),
          backgroundColor: VarnamalaTheme.error,
        ),
      );
    } else if (streakResult == StreakCheckResult.freezeConsumed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Streak Freeze protected your streak.'),
        ),
      );
    }
  }

  final List<PreferredSizeWidget> appBars = [
    const StatAppBar(),
    const CharactersAppBar(),
    const ProfileAppBar(),
    const LeaderboardAppBar(),
    const ShopAppBar(),
  ];

  @override
  Widget build(BuildContext context) {
    final bar = appBars[currentIndex];

    return AnimatedBuilder(
      animation: _chrome,
      builder: (context, body) {
        final t = Curves.easeOut.transform(_chrome.value);
        return Scaffold(
          backgroundColor: currentIndex == 0
              ? VarnamalaTheme.scaffoldBackground
              : Colors.white,
          // Both bars collapse towards the screen edge they live on, so the
          // course path grows into the space instead of sliding under them.
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(bar.preferredSize.height * t),
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: t,
                child: bar,
              ),
            ),
          ),
          bottomNavigationBar: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: t,
              child: BottomNavigator(
                currentIndex: currentIndex,
                onPress: onBottomNavigatorTapped,
              ),
            ),
          ),
          body: body,
          floatingActionButton: currentIndex == 0 && kDebugMode
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const OnboardingScreen()),
                    );
                  },
                  label: const Text("Test Onboarding"),
                  icon: const Icon(Icons.start),
                  backgroundColor: VarnamalaTheme.peacockTeal,
                )
              : null,
        );
      },
      // Built once and handed to the builder, so scrolling only repaints the
      // two bars rather than rebuilding the whole course path each frame.
      child: NotificationListener<UserScrollNotification>(
        onNotification: _onScroll,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: screens[currentIndex],
        ),
      ),
    );
  }

  void onBottomNavigatorTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    // A new tab always starts with its chrome showing.
    _chrome.forward();
  }
}

class CharacterLearningPage extends StatelessWidget {
  const CharacterLearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CharacterPracticeScreen();
  }
}
