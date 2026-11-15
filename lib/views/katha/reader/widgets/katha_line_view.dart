import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/reader/widgets/katha_word_gloss.dart';
import 'package:words625/views/theme.dart';

/// Where a line sits relative to the one being read.
enum KathaLineState { past, current, upcoming }

/// Which side of the page a line sits on: the side its speaker stands on in
/// the picture, so the words come from where the person is. Narration sits
/// in the middle.
enum KathaLineSide { left, right, centre }

/// One beat's sentence, in English letters, under the spotlight.
///
/// The spotlight has two layers: the whole line fades by where it sits (past
/// 45%, current full, upcoming 25%), and inside the current line a soft band
/// sits behind the phrase chunk being read, which trains reading in phrases
/// rather than word by word.
///
/// Words linked to something in the picture carry a thin underline in that
/// object's colour, and tapping one plays its cue.
class KathaLineView extends StatelessWidget {
  const KathaLineView({
    required this.speaker,
    required this.line,
    required this.state,
    this.side = KathaLineSide.left,
    this.showSpeaker = true,
    required this.activeChunk,
    required this.spelling,
    required this.linkColorFor,
    required this.onWordTap,
    this.onWordHeld,
    this.showTranslation = true,
    super.key,
  });

  final String speaker;
  final KathaLine line;
  final KathaLineState state;
  final KathaLineSide side;

  /// False when the line before is the same person's: one name heads a run
  /// of their lines, the way a chat groups messages.
  final bool showSpeaker;

  /// Index into [KathaLine.chunks] of the phrase being read; only meaningful
  /// for the current line.
  final int activeChunk;
  final KathaSpelling spelling;
  final Color? Function(String cue) linkColorFor;
  final void Function(KathaToken token) onWordTap;

  /// A long press: the meaning shows, and this says the word.
  final void Function(KathaToken token)? onWordHeld;

  /// The faint English line beneath the words.
  final bool showTranslation;

  static const _opacity = {
    KathaLineState.past: 0.45,
    KathaLineState.current: 1.0,
    KathaLineState.upcoming: 0.25,
  };

  @override
  Widget build(BuildContext context) {
    final punctuation = line.trailingPunctuation();
    final reading = GoogleFonts.literata(
      fontSize: 21,
      height: 1.6,
      color: context.appTextPrimary,
      fontWeight: FontWeight.w500,
    );

    final (cross, wrap, textAlign) = switch (side) {
      KathaLineSide.left => (
        CrossAxisAlignment.start,
        WrapAlignment.start,
        TextAlign.start,
      ),
      KathaLineSide.right => (
        CrossAxisAlignment.end,
        WrapAlignment.end,
        TextAlign.end,
      ),
      KathaLineSide.centre => (
        CrossAxisAlignment.center,
        WrapAlignment.center,
        TextAlign.center,
      ),
    };

    return AnimatedOpacity(
      opacity: _opacity[state]!,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Padding(
        padding: EdgeInsets.only(
          top: showSpeaker ? 8 : 0,
          bottom: 2,
          left: side == KathaLineSide.right ? 40 : 0,
          right: side == KathaLineSide.left ? 40 : 0,
        ),
        child: Column(
          crossAxisAlignment: cross,
          children: [
            if (showSpeaker && speaker.isNotEmpty)
              Text(
                speaker,
                textAlign: textAlign,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            Wrap(
              alignment: wrap,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var c = 0; c < line.chunks.length; c++)
                  _Chunk(
                    active: state == KathaLineState.current && c == activeChunk,
                    children: [
                      for (final (i, index) in line.chunks[c].indexed)
                        _Word(
                          token: line.tokens[index],
                          spelling: spelling,
                          text:
                              spelling.show(line.tokens[index].roman) +
                              punctuation[index] +
                              (i < line.chunks[c].length - 1 ? ' ' : ''),
                          style: side == KathaLineSide.centre
                              ? reading.copyWith(fontStyle: FontStyle.italic)
                              : reading,
                          link: line.tokens[index].cue == null
                              ? null
                              : linkColorFor(line.tokens[index].cue!),
                          onTap: () => onWordTap(line.tokens[index]),
                          onHeld: onWordHeld == null
                              ? null
                              : () => onWordHeld!(line.tokens[index]),
                        ),
                    ],
                  ),
              ],
            ),
            if (showTranslation && line.translation != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                child: Text(
                  line.translation!,
                  textAlign: textAlign,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appTextSecondary.withValues(alpha: 0.75),
                    height: 1.3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Chunk extends StatelessWidget {
  const _Chunk({required this.active, required this.children});

  final bool active;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active
            ? context.appWarning.withValues(alpha: 0.2)
            : context.appWarning.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _Word extends StatelessWidget {
  const _Word({
    required this.token,
    required this.spelling,
    required this.text,
    required this.style,
    required this.link,
    required this.onTap,
    this.onHeld,
  });

  final KathaToken token;
  final KathaSpelling spelling;
  final String text;
  final TextStyle style;
  final Color? link;
  final VoidCallback onTap;
  final VoidCallback? onHeld;

  @override
  Widget build(BuildContext context) {
    // The meaning, on a long press (phone) or a hover (web). Tapping stays
    // what it was - hear the word, see its picture move - so peeking at a
    // gloss is a separate, deliberate act.
    return Tooltip(
      richMessage: kathaGloss(token, spelling),
      triggerMode: TooltipTriggerMode.longPress,
      // Fires on the long press only; a hover shows the meaning silently.
      onTriggered: onHeld,
      waitDuration: const Duration(milliseconds: 350),
      showDuration: const Duration(seconds: 4),
      preferBelow: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Text(
          text,
          style: link == null
              ? style
              : style.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: link,
                  decorationThickness: 2,
                ),
        ),
      ),
    );
  }
}
