// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:words625/views/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      eyebrow: 'MEET VARNAMALA',
      title: 'A language app built for everyone',
      description:
          'Varnamala is an open-source Flutter app for Android, iOS, and the web. Learn with short lessons that fit into your day.',
      icon: Icons.auto_stories_rounded,
      color: VarnamalaTheme.peacockTeal,
    ),
    _OnboardingPageData(
      eyebrow: 'MORE THAN FLASH CARDS',
      title: 'Read, write, listen, and play',
      description:
          'Build everyday vocabulary, practise native scripts, play learning games, follow your progress, and learn alongside a community.',
      icon: Icons.draw_rounded,
      color: VarnamalaTheme.peacockDeep,
    ),
    _OnboardingPageData(
      eyebrow: 'WHY VARNAMALA?',
      title: 'Languages deserve better',
      description:
          'We focus on Tamil, Kannada, Telugu, Malayalam, Hindi, Bengali, Odia, Nepali, Assamese, and more. No pay-to-win—just open, community-driven education.',
      icon: Icons.volunteer_activism_rounded,
      color: VarnamalaTheme.error,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close tour',
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  Text(
                    'Varnamala',
                    style: GoogleFonts.nunito(
                      color: context.appAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 48,
                    child: !isLastPage
                        ? TextButton(
                            onPressed: () => _goToPage(_pages.length - 1),
                            child: const Text('Skip'),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _TourPage(data: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  Semantics(
                    label: 'Tour page ${_currentPage + 1} of ${_pages.length}',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 28 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? context.appAccent
                                : context.appBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: isLastPage
                          ? () => Navigator.of(context).pop()
                          : () => _goToPage(_currentPage + 1),
                      iconAlignment: IconAlignment.end,
                      icon: Icon(
                        isLastPage
                            ? Icons.login_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        isLastPage ? 'Back to sign in' : 'Next',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage > 0 && !isLastPage)
                    TextButton(
                      onPressed: () => _goToPage(_currentPage - 1),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _TourPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final accent = VarnamalaTheme.adaptiveAccent(context, data.color);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.34),
                  ),
                ),
                child: Icon(data.icon, size: 70, color: accent),
              ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 36),
              Text(
                data.eyebrow,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 10),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  color: context.appTextPrimary,
                  height: 1.15,
                ),
              ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.12),
              const SizedBox(height: 16),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  color: context.appTextSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _OnboardingPageData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
