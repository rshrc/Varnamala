// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/character_provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/utils.dart';
import 'package:words625/courses/alphabets/alphabets.dart';
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
    return CustomScrollView(
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
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
                  color: VarnamalaTheme.peacockTeal,
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
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
                  color: VarnamalaTheme.leagueAmethyst,
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
            child: Column(
              children: [
                const SizedBox(height: 8),
                _PracticeButton(
                  label: 'Learn Vowels',
                  icon: Icons.record_voice_over_rounded,
                  color: VarnamalaTheme.peacockTeal,
                  onTap: () => context.router.push(
                      VowelAndConsonantLearningRoute(
                          mode: CharacterLearningMode.vowels)),
                ),
                const SizedBox(height: 10),
                _PracticeButton(
                  label: 'Learn Consonants',
                  icon: Icons.abc_rounded,
                  color: VarnamalaTheme.leagueAmethyst,
                  onTap: () => context.router.push(
                      VowelAndConsonantLearningRoute(
                          mode: CharacterLearningMode.consonants)),
                ),
                const SizedBox(height: 10),
                _PracticeButton(
                  label: 'Random Practice',
                  icon: Icons.shuffle_rounded,
                  color: VarnamalaTheme.peacockCyan,
                  onTap: () => context.router.push(
                      VowelAndConsonantLearningRoute(
                          mode: CharacterLearningMode.random)),
                ),
              ],
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
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
          Icon(icon, color: VarnamalaTheme.peacockTeal, size: 22),
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
                  color: VarnamalaTheme.textHint,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
      child: InkWell(
        onTap: () => getIt<SpeechService>().speak(pronunciation),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
            border: Border.all(color: const Color(0xFFEEF2F1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                character,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                pronunciation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: VarnamalaTheme.textSecondary,
                      fontSize: 11,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
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
            color: Colors.white,
            border: Border.all(
                color: VarnamalaTheme.peacockTeal.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 0.08,
                  child: Text(
                    widget.alphabet,
                    style: const TextStyle(
                      fontSize: 280,
                      color: VarnamalaTheme.peacockTeal,
                      fontWeight: FontWeight.bold,
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
                      painter: CharacterPainter(strokes: strokes),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: VarnamalaTheme.peacockTeal.withValues(alpha: 0.1),
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
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: VarnamalaTheme.peacockTeal,
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
  const VowelAndConsonantLearningPage({super.key, required this.mode});

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

    switch (widget.mode) {
      case CharacterLearningMode.vowels:
        charactersToLearn = vowels;
        break;
      case CharacterLearningMode.consonants:
        charactersToLearn = consonants;
        break;
      case CharacterLearningMode.random:
        charactersToLearn = shuffleMap(sounds);
        break;
    }
    currentCharacter = charactersToLearn.entries.first;
  }

  Set<MapEntry> visitedCharacters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VarnamalaTheme.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: VarnamalaTheme.textHint),
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
        child: Column(
          children: [
            const Spacer(flex: 1),
            RenderCharacter(
              alphabet: currentCharacter.key,
              shouldRebuild: shouldRebuildCharacter,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(VarnamalaTheme.radiusMedium),
                border: Border.all(color: const Color(0xFFEEF2F1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentCharacter.key,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: VarnamalaTheme.peacockTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded,
                      color: VarnamalaTheme.textHint, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    currentCharacter.value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: VarnamalaTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: VarnamalaTheme.peacockTeal.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusSmall),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(VarnamalaTheme.radiusSmall),
                      onTap: () =>
                          getIt<SpeechService>().speak(currentCharacter.value),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.volume_up_rounded,
                            color: VarnamalaTheme.peacockTeal, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
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
                    backgroundColor: VarnamalaTheme.peacockTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          VarnamalaTheme.radiusMedium),
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

  CharacterPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VarnamalaTheme.peacockTeal
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
    return true;
  }
}
