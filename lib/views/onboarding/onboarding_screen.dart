// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:words625/core/external_links.dart';
import 'package:words625/views/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: "Reclaiming Language Learning",
      description:
          "Remember when learning was about knowledge, not maximizing ad revenue? No hearts. No energy. No pay-to-win. Just pure, open-source education.",
      icon: Icons.public,
      color: VarnamalaTheme.peacockTeal,
    ),
    _OnboardingPageData(
      title: "Real Communication",
      description:
          "While others teach High Valyrian and Klingon, we focus on connecting humanity. Hindi, Kannada, Tamil, Native American languages - languages spoken by billions, ignored by corporate apps.",
      icon: Icons.translate,
      color: VarnamalaTheme.peacockDeep,
    ),
    _OnboardingPageData(
      title: "A Cooperative Mission",
      description:
          "Choose your own path. Join a community that helps each other. This is an open-source project meant to replace corporate greed with a more learned world.",
      icon: Icons.volunteer_activism,
      color: VarnamalaTheme.error, // Using a warm color for heart/community
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: data.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            data.icon,
                            size: 80,
                            color: data.color,
                          ),
                        )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 40),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: VarnamalaTheme.textPrimary,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            color: VarnamalaTheme.textSecondary,
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? VarnamalaTheme.peacockTeal
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_currentPage == _pages.length - 1) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => launchPatreon(context, source: 'onboarding'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF424D), // Patreon color
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Support on Patreon",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: VarnamalaTheme.peacockTeal,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Start Learning",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: VarnamalaTheme.peacockTeal,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VarnamalaTheme.peacockTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
