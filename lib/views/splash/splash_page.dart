// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:words625/views/theme.dart';
import 'components/splash_background_painter.dart';

// Project imports:
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/views/onboarding/onboarding_screen.dart';
import 'components/center_display.dart';
import 'components/get_started_button.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? await auth.authStateChanges().first;

    if (user != null && mounted) {
      context.router.replace(const HomeRoute());
    }
  }

  void _openIntroduction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                                foregroundColor: VarnamalaTheme.peacockTeal,
                                backgroundColor: VarnamalaTheme.peacockTeal
                                    .withValues(alpha: 0.08),
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
                            GetStartedButton(
                              label: 'SIGN IN WITH GOOGLE',
                              width: MediaQuery.sizeOf(context).width - 48,
                            ),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Sign in securely to save and sync your learning progress.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: VarnamalaTheme.textSecondary,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
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
