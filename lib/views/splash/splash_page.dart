// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/service/demo_lesson_service.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/language_preference_service.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/debug/interactive_lesson_demo_page.dart';
import 'package:words625/views/onboarding/onboarding_screen.dart';
import 'package:words625/views/splash/demo_lesson_page.dart';
import 'package:words625/views/theme.dart';
import 'components/center_display.dart';
import 'components/get_started_button.dart';
import 'components/splash_background_painter.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  final DemoLessonService _demoService = DemoLessonService();
  bool _loadingDemo = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? await auth.authStateChanges().first;

    if (user != null && mounted) {
      final selection = await LanguagePreferenceService(getIt<AppPrefs>())
          .restoreForUser(user.uid);
      if (!mounted) return;
      if (selection == null) {
        await context.router.replace(const LangChoiceRoute());
      } else {
        await context.router.replace(const HomeRoute());
      }
    }
  }

  void _openIntroduction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }

  void _openInteractiveLab() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const InteractiveLessonDemoPage(),
      ),
    );
  }

  Future<void> _openDemo() async {
    if (_loadingDemo) return;
    setState(() => _loadingDemo = true);
    try {
      final question = await _demoService.loadRandomQuestion();
      await _demoService.recordStart();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DemoLessonPage(
            initialQuestion: question,
            service: _demoService,
          ),
        ),
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the demo. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingDemo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background with warm curved layers
          CustomPaint(
            painter: SplashBackgroundPainter(),
            size: Size.infinite,
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CenterDisplay(),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: _openIntroduction,
                              style: TextButton.styleFrom(
                                foregroundColor: context.appViolet,
                                backgroundColor:
                                    context.appViolet.withValues(alpha: 0.14),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 11,
                                ),
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              icon: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 17,
                              ),
                              label: const Text('What is Varnamala?'),
                            ),
                            const SizedBox(height: 12),
                            if (kDebugMode) ...[
                              FilledButton.tonalIcon(
                                onPressed: _openInteractiveLab,
                                icon: const Icon(Icons.science_rounded),
                                label: const Text('OPEN INTERACTIVE LAB'),
                              ),
                              const SizedBox(height: 12),
                            ],
                            OutlinedButton.icon(
                              onPressed: _loadingDemo ? null : _openDemo,
                              icon: _loadingDemo
                                  ? const SizedBox.square(
                                      dimension: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow_rounded),
                              label: Text(
                                _demoService.count == 0
                                    ? 'TRY A QUICK DEMO'
                                    : 'TRY A QUICK DEMO · ${_demoService.count} PLAYED',
                              ),
                            ),
                            const SizedBox(height: 12),
                            GetStartedButton(
                              label: 'SIGN IN WITH GOOGLE',
                              width: MediaQuery.sizeOf(context).width - 48,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Sign in securely to save and sync your learning progress.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 12, height: 1.35),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
