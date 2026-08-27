// Flutter imports:

// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:words625/views/home/mala_welcomes.dart';
import 'package:words625/views/theme.dart';

class CenterDisplay extends StatelessWidget {
  const CenterDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MalaWelcomes(),
          const SizedBox(height: 24),
          Text(
            'Varnamala',
            style: GoogleFonts.nunito(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: AnimatedTextKit(
              animatedTexts: [
                FadeAnimatedText(
                  'Reclaiming Language Learning',
                  textStyle: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  duration: const Duration(milliseconds: 1000),
                ),
                FadeAnimatedText(
                  'Learn Kannada • ಕಲಿಯಿರಿ',
                  textStyle: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  duration: const Duration(milliseconds: 1000),
                ),
                FadeAnimatedText(
                  'Learn Tamil • படியுங்கள்',
                  textStyle: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  duration: const Duration(milliseconds: 1000),
                ),
                FadeAnimatedText(
                  'Learn Telugu • నేర్చుకోండి',
                  textStyle: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  duration: const Duration(milliseconds: 1000),
                ),
                FadeAnimatedText(
                  'Learn Malayalam • പഠിക്കൂ',
                  textStyle: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  duration: const Duration(milliseconds: 1000),
                ),
                FadeAnimatedText(
                  'Free. Forever.',
                  textStyle: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: VarnamalaTheme.error, // Highlight "Free"
                  ),
                  duration: const Duration(milliseconds: 2500),
                ),
              ],
              repeatForever: true,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "No hearts to lose. No energy to refill.\nJust pure learning.",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
