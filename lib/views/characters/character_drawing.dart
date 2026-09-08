// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/character_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/core/utils.dart';
import 'package:words625/courses/alphabets/alphabets.dart';
import 'package:words625/application/game_provider.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/service/speech_service.dart';
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/views/theme.dart';

enum CharacterLearningMode {
  vowels,
  consonants,
  random,
}

class CharacterPracticeScreen extends StatefulWidget {
  const CharacterPracticeScreen({super.key});

  @override
  State<CharacterPracticeScreen> createState() =>
      _CharacterPracticeScreenState();
}

class _CharacterPracticeScreenState extends State<CharacterPracticeScreen> {
  late TargetLanguage targetLanguage;
  late Map<String, String> sounds;
  late Map<String, String> vowels;
  late Map<String, String> consonants;

  @override
  void initState() {
    super.initState();
    targetLanguage = context.read<LanguageProvider>().selectedLanguage;
    sounds = getLanguageSounds(targetLanguage);
    vowels = getLanguageVowels(targetLanguage);
    consonants = getLanguageConsonants(targetLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return ContentBounds(
      maxWidth: ContentWidth.grid,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Vowels section
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Vowels',
              subtitle: '${vowels.length} characters',
              icon: Icons.record_voice_over_rounded,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                // Four across on a phone, more as the window widens, instead of
                // four tiles inflated to the size of playing cards.
                maxCrossAxisExtent: 96,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = vowels.entries.elementAt(index);
                  return _CharacterTile(
                    character: entry.key,
                    pronunciation: entry.value,
                    color: context.appSuccess,
                  );
                },
                childCount: vowels.length,
              ),
            ),
          ),
          // Consonants section
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Consonants',
              subtitle: '${consonants.length} characters',
              icon: Icons.abc_rounded,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                // Four across on a phone, more as the window widens, instead of
                // four tiles inflated to the size of playing cards.
                maxCrossAxisExtent: 96,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = consonants.entries.elementAt(index);
                  return _CharacterTile(
                    character: entry.key,
                    pronunciation: entry.value,
                    color: context.appViolet,
                  );
                },
                childCount: consonants.length,
              ),
            ),
          ),
          // Practice buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              // The buttons stretch to fill their column, so they get a
              // narrower one than the character grid rather than running its
              // whole width.
              child: ContentBounds(
                maxWidth: ContentWidth.column,
                gutter: false,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _PracticeButton(
                      label: 'Learn Vowels',
                      icon: Icons.record_voice_over_rounded,
                      color: context.appSuccess,
                      onTap: () => context.router.push(
                          VowelAndConsonantLearningRoute(
                              mode: CharacterLearningMode.vowels)),
                    ),
                    const SizedBox(height: 10),
                    _PracticeButton(
                      label: 'Learn Consonants',
                      icon: Icons.abc_rounded,
                      color: context.appViolet,
                      onTap: () => context.router.push(
                          VowelAndConsonantLearningRoute(
                              mode: CharacterLearningMode.consonants)),
                    ),
                    const SizedBox(height: 10),
                    _PracticeButton(
                      label: 'Random Practice',
                      icon: Icons.shuffle_rounded,
                      color: context.appInfo,
                      onTap: () => context.router.push(
                          VowelAndConsonantLearningRoute(
                              mode: CharacterLearningMode.random)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: context.appInfo, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _CharacterTile extends StatelessWidget {
  final String character;
  final String pronunciation;
  final Color color;

  const _CharacterTile({
    required this.character,
    required this.pronunciation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = VarnamalaTheme.adaptiveAccent(context, color);
    return Material(
      color: context.appSurface,
      borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
      child: InkWell(
        // Tapping the tile opens the letter. Sound stays one tap away on the
        // badge below, because the old behaviour - the whole tile silently
        // being a play button - was undiscoverable.
        onTap: () => showCharacterSheet(
          context,
          character: character,
          pronunciation: pronunciation,
          color: color,
        ),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
            border: Border.all(color: context.appBorder),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      character,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pronunciation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.appTextSecondary,
                            fontSize: 11,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 26,
                    height: 26,
                  ),
                  tooltip: 'Hear $character',
                  onPressed: () {
                    getIt<SpeechService>().speak(pronunciation);
                    getIt<GameProvider>().bumpStat('lettersPracticed');
                  },
                  icon: Icon(
                    Icons.volume_up_rounded,
                    size: 15,
                    color: accent.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PracticeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = VarnamalaTheme.adaptiveAccent(context, color);
    return Material(
      color: context.appSurface,
      borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
            border: Border.all(
              color: accent.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RenderCharacter extends StatefulWidget {
  final String alphabet;
  final ValueNotifier<bool> shouldRebuild;

  const RenderCharacter(
      {super.key, required this.alphabet, required this.shouldRebuild});

  @override
  RenderCharacterState createState() => RenderCharacterState();
}

class RenderCharacterState extends State<RenderCharacter> {
  final List<List<Offset>> strokes = [];
  List<Offset> currentStroke = [];

  @override
  void initState() {
    super.initState();
    widget.shouldRebuild.addListener(() {
      setState(() {
        strokes.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AspectRatio(
        aspectRatio: 0.75,
        child: Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            border: Border.all(color: context.appBorder),
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
          ),
          child: Stack(
            children: [
              // The guide glyph is sized to whatever canvas it ends up in,
              // rather than a fixed 280px that spills out of a small one.
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  heightFactor: 0.7,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Opacity(
                      opacity: 0.08,
                      child: Text(
                        widget.alphabet,
                        style: TextStyle(
                          color: context.appAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: (details) {
                      currentStroke = [details.localPosition];
                      setState(() {
                        strokes.add(currentStroke);
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        if (currentStroke.isNotEmpty) {
                          final distance =
                              (currentStroke.last - details.localPosition)
                                  .distance;
                          if (distance > 8.0) {
                            currentStroke.add(details.localPosition);
                          }
                        } else {
                          currentStroke.add(details.localPosition);
                        }
                      });
                    },
                    onPanEnd: (details) {
                      currentStroke = [];
                    },
                    child: CustomPaint(
                      painter: CharacterPainter(
                        strokes: strokes,
                        color: context.appAccent,
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: context.appDanger.withValues(alpha: 0.14),
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusSmall),
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusSmall),
                    onTap: () {
                      setState(() {
                        strokes.clear();
                        currentStroke = [];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: context.appDanger,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@RoutePage()
class VowelAndConsonantLearningPage extends StatefulWidget {
  final CharacterLearningMode mode;

  /// Letter to open on. Lets a learner start where they are curious rather
  /// than always at the top of the alphabet.
  final String? startAt;

  const VowelAndConsonantLearningPage({
    super.key,
    required this.mode,
    this.startAt,
  });

  @override
  State<VowelAndConsonantLearningPage> createState() =>
      _VowelAndConsonantLearningPageState();
}

class _VowelAndConsonantLearningPageState
    extends State<VowelAndConsonantLearningPage> {
  late Map<String, String> charactersToLearn;
  late MapEntry currentCharacter;
  late TargetLanguage targetLanguage;
  late Map<String, String> sounds;
  late Map<String, String> vowels;
  late Map<String, String> consonants;

  final ValueNotifier<bool> shouldRebuildCharacter = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    targetLanguage = context.read<LanguageProvider>().selectedLanguage;
    sounds = getLanguageSounds(targetLanguage);
    vowels = getLanguageVowels(targetLanguage);
    consonants = getLanguageConsonants(targetLanguage);

    // A mutable copy: this screen removes each letter as it is learned, and
    // must never do that to the shared alphabet.
    charactersToLearn = switch (widget.mode) {
      CharacterLearningMode.vowels => Map.of(vowels),
      CharacterLearningMode.consonants => Map.of(consonants),
      CharacterLearningMode.random => shuffleMap(sounds),
    };
    // Open on the requested letter by moving it to the front, so the rest of
    // the set still follows it.
    final startAt = widget.startAt;
    if (startAt != null && charactersToLearn.containsKey(startAt)) {
      final value = charactersToLearn.remove(startAt) as String;
      charactersToLearn = {startAt: value, ...charactersToLearn};
    }
    currentCharacter = charactersToLearn.entries.first;
  }

  Set<MapEntry> visitedCharacters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: context.appDanger),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getModeTitle(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SafeArea(
        child: ContentBounds(
          child: Column(
            children: [
              // The canvas keeps a 3:4 shape, so it has to be bounded by the
              // height left over rather than deriving its height from the
              // window's width - which on a desktop asked for a canvas taller
              // than the screen and overflowed.
              Expanded(
                child: Center(
                  child: RenderCharacter(
                    alphabet: currentCharacter.key,
                    shouldRebuild: shouldRebuildCharacter,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius:
                      BorderRadius.circular(VarnamalaTheme.radiusMedium),
                  border: Border.all(color: context.appBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentCharacter.key,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.appSuccess,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded,
                        color: context.appInfo, size: 20),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        currentCharacter.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: context.appTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: context.appInfo.withValues(alpha: 0.14),
                      borderRadius:
                          BorderRadius.circular(VarnamalaTheme.radiusSmall),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(VarnamalaTheme.radiusSmall),
                        onTap: () => getIt<SpeechService>()
                            .speak(currentCharacter.value),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.volume_up_rounded,
                              color: context.appInfo, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CharacterProvider>().clearPoints();
                      setState(() {
                        visitedCharacters.add(currentCharacter);
                        charactersToLearn.remove(currentCharacter.key);
                        if (charactersToLearn.isNotEmpty) {
                          currentCharacter = charactersToLearn.entries.first;
                        }
                      });
                      shouldRebuildCharacter.value =
                          !shouldRebuildCharacter.value;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appAccent,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(VarnamalaTheme.radiusMedium),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Next',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case CharacterLearningMode.vowels:
        return 'Vowels';
      case CharacterLearningMode.consonants:
        return 'Consonants';
      case CharacterLearningMode.random:
        return 'Random Practice';
    }
  }
}

class CharacterPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;

  CharacterPainter({required this.strokes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);

      if (stroke.length < 3) {
        path.lineTo(stroke[1].dx, stroke[1].dy);
      } else {
        for (var i = 1; i < stroke.length - 1; i++) {
          final p0 = stroke[i];
          final p1 = stroke[i + 1];
          final midPoint = Offset(
            (p0.dx + p1.dx) / 2,
            (p0.dy + p1.dy) / 2,
          );
          path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CharacterPainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.color != color;
  }
}

/// Opens one letter: big enough to actually see, with the two things a learner
/// wants next - hear it, and write it.
///
/// This is the answer to "the grid only lets you look". Every letter becomes a
/// way into practice, so a learner can start from the one that puzzles them
/// rather than restarting the whole alphabet.
Future<void> showCharacterSheet(
  BuildContext context, {
  required String character,
  required String pronunciation,
  required Color color,
}) {
  return showModalBottomSheet<void>(
    context: context,
    constraints: kSheetConstraints,
    showDragHandle: true,
    builder: (sheetContext) => _CharacterSheet(
      character: character,
      pronunciation: pronunciation,
      color: color,
    ),
  );
}

class _CharacterSheet extends StatelessWidget {
  const _CharacterSheet({
    required this.character,
    required this.pronunciation,
    required this.color,
  });

  final String character;
  final String pronunciation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final accent = VarnamalaTheme.adaptiveAccent(context, color);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 130,
              height: 130,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    character,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              pronunciation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      getIt<SpeechService>().speak(pronunciation);
                      getIt<GameProvider>().bumpStat('lettersPracticed');
                    },
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('HEAR IT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // Captured before the pop, because `context` belongs to
                      // the sheet's own route and is defunct once it closes.
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => VowelAndConsonantLearningPage(
                            mode: CharacterLearningMode.random,
                            startAt: character,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.draw_rounded),
                    label: const Text('WRITE IT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
