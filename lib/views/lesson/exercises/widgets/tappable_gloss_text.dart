import 'package:flutter/material.dart';
import 'package:words625/application/game_provider.dart';
import 'package:words625/courses/word_dictionary.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/views/theme.dart';

typedef WordMeaningLookup = String? Function(String word);

/// Target-language text whose individual words reveal their dictionary gloss
/// on tap, matching the interaction used by the original lesson renderer.
class TappableGlossText extends StatelessWidget {
  const TappableGlossText({
    required this.text,
    required this.style,
    this.meaningLookup,
    this.onMeaningOpened,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final WordMeaningLookup? meaningLookup;
  final VoidCallback? onMeaningOpened;

  void recordMeaningOpened() {
    onMeaningOpened?.call();
    if (getIt.isRegistered<GameProvider>()) {
      getIt<GameProvider>().bumpStat('wordsTapped');
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = text.trim().split(RegExp(r'\s+'));
    final lookup = meaningLookup ?? getWordMeaning;

    return RichText(
      text: TextSpan(
        children: [
          for (var index = 0; index < words.length; index++) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Tooltip(
                key: ValueKey('gloss-$index-${words[index]}'),
                message: lookup(words[index]) ?? 'No meaning yet',
                triggerMode: TooltipTriggerMode.tap,
                enableFeedback: true,
                onTriggered: recordMeaningOpened,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: lookup(words[index]) == null
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  words[index],
                  style: style?.copyWith(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                    decorationThickness: 2,
                    decorationColor: context.appAccent.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
            if (index < words.length - 1) const TextSpan(text: ' '),
          ],
        ],
      ),
    );
  }
}
