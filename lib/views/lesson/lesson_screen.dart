// Flutter imports:
import 'package:flutter/material.dart';

// Dart imports:
import 'dart:math';

// Package imports:
import 'package:auto_route/annotations.dart';
import 'package:chiclet/chiclet.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/interactive_lesson_engine.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/application/level_provider.dart';
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/application/lesson/interactive_course_progress.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/views/courses/components/community_sheet.dart';
import 'package:words625/views/lesson/components/lesson_app_bar.dart';
import 'package:words625/views/lesson/components/list_lesson.dart';
import 'package:words625/views/lesson/exercises/interactive_exercise_host.dart';
import 'package:words625/views/theme.dart';

enum LessonAvailability { loading, present, absent }

enum LessonRendererMode { legacy, interactiveAllCourses }

/// One switch returns every course to the old renderer without touching JSON,
/// Firestore releases, or learner completion data.
const LessonRendererMode lessonRendererMode =
    LessonRendererMode.interactiveAllCourses;

@RoutePage()
class LessonPage extends StatefulWidget {
  final Course course;
  final int? unitIndex;
  final int? stageIndex;
  final bool isReplay;

  const LessonPage({
    Key? key,
    required this.course,
    this.unitIndex,
    this.stageIndex,
    this.isReplay = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LessonPageState();
}

class LessonPageState extends State<LessonPage> {
  double percent = 0.1;
  int index = 0;
  List<ListLesson>? lessons;
  LessonAvailability lessonAvailability = LessonAvailability.loading;
  InteractiveLessonEngine? _interactiveEngine;
  GeneratedLessonStage? _generatedStage;
  late int _unitIndex;
  late LessonStageKind _stageKind;
  bool _isReplay = false;
  bool _finishing = false;
  InteractiveProgressAdvance? _completion;

  @override
  void initState() {
    super.initState();
    if (lessonRendererMode == LessonRendererMode.legacy) {
      generateQuestions();
    } else {
      _prepareInteractiveLesson();
    }
  }

  void _prepareInteractiveLesson() {
    final levels = widget.course.levels;
    if (levels == null || levels.isEmpty) {
      lessonAvailability = LessonAvailability.absent;
      return;
    }

    final progress = const InteractiveCourseProgress().read(widget.course);
    _isReplay = widget.isReplay || progress.isComplete;
    _unitIndex = (widget.unitIndex ?? progress.currentUnitIndex)
        .clamp(0, levels.length - 1)
        .toInt();
    final requestedStage = widget.stageIndex ??
        (_isReplay && widget.stageIndex == null
            ? LessonStageKind.recall.index
            : progress.stageIndex);
    _stageKind = LessonStageKind.values[
        requestedStage.clamp(0, LessonStageKind.values.length - 1).toInt()];

    final language = TargetLanguage.values.firstWhere(
      (item) => item.name == widget.course.language,
      orElse: () => TargetLanguage.kannada,
    );
    final level = levels[_unitIndex];
    const factory = CourseExerciseFactory();
    _generatedStage = factory.buildStage(
      context: CourseExerciseContext(
        language: language,
        courseId: widget.course.courseId ?? widget.course.courseName,
        levelNumber: level.level ?? _unitIndex + 1,
        dictionary: courseRepository.cachedDictionary(language) ??
            courseRepository.activeDictionary ??
            const {},
      ),
      questions: level.questions ?? const [],
      stage: _stageKind,
    );
    _interactiveEngine = InteractiveLessonEngine(
      exercises: _generatedStage!.exercises
          .map((generated) => generated.exercise)
          .toList(growable: false),
    )..addListener(_onInteractiveChanged);
    lessonAvailability = LessonAvailability.present;
  }

  void _onInteractiveChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _interactiveEngine
      ?..removeListener(_onInteractiveChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> generateQuestions() async {
    if (widget.course.levels == null || widget.course.levels!.isEmpty) {
      setState(() => lessonAvailability = LessonAvailability.absent);
      return;
    }

    final List<ListLesson> generatedLessons = widget
        .course.levels!.first.questions!
        .map((question) => ListLesson(question, course: widget.course))
        .toList();

    setState(() {
      lessonAvailability = generatedLessons.isEmpty
          ? LessonAvailability.absent
          : LessonAvailability.present;
      lessons = generatedLessons;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (lessonRendererMode == LessonRendererMode.interactiveAllCourses) {
      return _buildInteractive(context);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: lessonAvailability == LessonAvailability.present
          ? const LessonAppBar()
          : null,
      body: Builder(
        builder: (context) {
          switch (lessonAvailability) {
            case LessonAvailability.loading:
              return Center(
                child: CircularProgressIndicator(
                  color: context.appAccent,
                  strokeWidth: 3,
                ),
              );
            case LessonAvailability.present:
              return lessons![index];
            case LessonAvailability.absent:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded,
                        size: 64,
                        color: context.appInfo.withValues(alpha: 0.65)),
                    const SizedBox(height: 16),
                    Text(
                      'No lessons available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.appTextSecondary,
                          ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildInteractive(BuildContext context) {
    if (lessonAvailability == LessonAvailability.absent) {
      return Scaffold(
        body: Center(
          child: Text(
            'No lessons available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }
    final engine = _interactiveEngine;
    final stage = _generatedStage;
    if (engine == null || stage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_completion != null ||
        (_isReplay && engine.phase == InteractiveLessonPhase.complete)) {
      return _InteractiveCompletionView(
        course: widget.course,
        stage: _stageKind,
        isReplay: _isReplay,
        completion: _completion,
      );
    }

    final generated = _currentGenerated(engine, stage);
    final isFeedback = engine.phase == InteractiveLessonPhase.feedback;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Leave lesson',
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close_rounded, color: context.appDanger),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'UNIT ${_unitIndex + 1} · ${_stageKind.label.toUpperCase()}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.appViolet.withValues(alpha: 0.14),
                    borderRadius:
                        BorderRadius.circular(VarnamalaTheme.radiusRound),
                  ),
                  child: Text(
                    _isReplay ? 'PRACTICE' : 'BETA',
                    style: TextStyle(
                      color: context.appViolet,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
              child: LinearProgressIndicator(
                value: engine.progress,
                minHeight: 8,
                backgroundColor: context.appBorder,
                valueColor: AlwaysStoppedAnimation<Color>(context.appSuccess),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Report a mistake in this question',
            onPressed: generated.sourceSentence.isEmpty
                ? null
                : () => showReportSheet(
                      context,
                      language:
                          context.read<LanguageProvider>().selectedLanguage,
                      courseName: widget.course.courseName,
                      sentence: generated.sourceSentence,
                    ),
            icon: Icon(Icons.flag_outlined, color: context.appWarning),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (engine.currentStep.isAdaptiveRetry) ...[
                      const _RealMistakeReviewNotice(),
                      const SizedBox(height: 14),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (generated.sourceSentence.isNotEmpty) ...[
                          SpeakButton(sentence: generated.sourceSentence),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            engine.currentExercise.prompt,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    IgnorePointer(
                      ignoring: isFeedback,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 140),
                        opacity: isFeedback ? 0.72 : 1,
                        child: InteractiveExerciseHost(
                          key: ValueKey(engine.currentExercise.id),
                          exercise: engine.currentExercise,
                          onResponseChanged: engine.setResponse,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isFeedback) _InteractiveFeedbackPanel(engine: engine),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _finishing || (!isFeedback && !engine.canSubmit)
                      ? null
                      : () => _handleInteractiveAction(engine),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFeedback
                        ? engine.lastAttempt!.correct
                            ? context.appSuccess
                            : context.appDanger
                        : context.appAccent,
                  ),
                  child: Text(
                    _finishing
                        ? 'SAVING…'
                        : isFeedback
                            ? 'CONTINUE'
                            : 'CHECK',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GeneratedExercise _currentGenerated(
    InteractiveLessonEngine engine,
    GeneratedLessonStage stage,
  ) {
    final sourceExerciseId =
        engine.currentStep.retryForExerciseId ?? engine.currentExercise.id;
    return stage.exercises.firstWhere(
      (item) => item.exercise.id == sourceExerciseId,
      orElse: () => stage.exercises.first,
    );
  }

  Future<void> _handleInteractiveAction(
    InteractiveLessonEngine engine,
  ) async {
    if (engine.phase == InteractiveLessonPhase.answering) {
      engine.submit();
      return;
    }
    if (engine.phase != InteractiveLessonPhase.feedback) return;
    engine.continueLesson();
    if (engine.phase != InteractiveLessonPhase.complete) return;

    if (_isReplay) {
      setState(() {});
      return;
    }
    setState(() => _finishing = true);
    final completion =
        await context.read<LessonProvider>().completeInteractiveStage(
              course: widget.course,
              unitIndex: _unitIndex,
              stage: _stageKind,
              wasPerfect: engine.mistakes == 0,
            );
    if (!mounted) return;
    setState(() {
      _completion = completion;
      _finishing = false;
    });
  }
}

class _RealMistakeReviewNotice extends StatelessWidget {
  const _RealMistakeReviewNotice();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Mistake review. This exercise revisits something you missed earlier.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.appWarning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          border: Border.all(
            color: context.appWarning.withValues(alpha: 0.48),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.replay_rounded, color: context.appWarning),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MISTAKE REVIEW',
                    style: TextStyle(
                      color: context.appWarning,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('This revisits something you missed earlier.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveFeedbackPanel extends StatelessWidget {
  const _InteractiveFeedbackPanel({required this.engine});

  final InteractiveLessonEngine engine;

  @override
  Widget build(BuildContext context) {
    final correct = engine.lastAttempt!.correct;
    final color = correct ? context.appSuccess : context.appDanger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      color: color.withValues(alpha: 0.11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? 'Correct!' : 'Not quite',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 7),
            Text(
              'Correct answer: ${engine.currentExercise.correctAnswerLabel}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (engine.currentExercise.explanation.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(engine.currentExercise.explanation),
          ],
        ],
      ),
    );
  }
}

class _InteractiveCompletionView extends StatelessWidget {
  const _InteractiveCompletionView({
    required this.course,
    required this.stage,
    required this.isReplay,
    required this.completion,
  });

  final Course course;
  final LessonStageKind stage;
  final bool isReplay;
  final InteractiveProgressAdvance? completion;

  @override
  Widget build(BuildContext context) {
    final courseComplete = completion?.courseCompleted ?? false;
    final title = isReplay
        ? 'Practice complete!'
        : courseComplete
            ? 'Course complete!'
            : '${stage.label} complete!';
    final subtitle = isReplay
        ? 'Replay this course whenever you want.'
        : courseComplete
            ? '${course.courseName} is now golden.'
            : stage == LessonStageKind.recall
                ? 'The next unit is ready.'
                : '${LessonStageKind.values[stage.index + 1].label} is ready.';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: context.appWarning.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: context.appWarning, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: context.appWarning.withValues(alpha: 0.3),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: context.appWarning,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.appTextSecondary,
                      ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'CONTINUE ON PATH',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckButton extends StatelessWidget {
  const CheckButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Consumer<LessonProvider>(
        builder: (context, lessonState, child) {
          String title;
          Color backgroundColor;

          if (lessonState.answerState == AnswerState.correct ||
              lessonState.answerState == AnswerState.readyForNext) {
            title = "CONTINUE";
            backgroundColor = context.appSuccess;
          } else if (lessonState.answerState == AnswerState.incorrect) {
            title = "GOT IT";
            backgroundColor = context.appDanger;
          } else {
            title = "CHECK";
            backgroundColor = context.appAccent;
          }

          final isEnabled = lessonState.selectedAnswer != null;
          final disabledColor = Theme.of(context).disabledColor;

          return ChicletAnimatedButton(
            width: MediaQuery.of(context).size.width - 40,
            backgroundColor: isEnabled ? backgroundColor : disabledColor,
            onPressed: isEnabled
                ? () {
                    if (lessonState.answerState != AnswerState.readyForNext) {
                      final checkAnswer = lessonState.checkAnswer();
                      if (checkAnswer) {
                        if (lessonState.answerState == AnswerState.correct) {
                          lessonState
                              .changeAnswerState(AnswerState.readyForNext);
                        }
                      }
                    } else if (lessonState.answerState ==
                        AnswerState.readyForNext) {
                      lessonState.next(context);
                    }
                  }
                : null,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isEnabled
                    ? Theme.of(context).colorScheme.onPrimary
                    : context.appTextSecondary,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}

class LevelPlayerChoice extends StatelessWidget {
  const LevelPlayerChoice({super.key});

  @override
  Widget build(BuildContext context) {
    const styles = [
      _CelebrationStyle(
        icon: Icons.celebration_rounded,
        accent: VarnamalaTheme.peacockTurquoise,
        title: 'Level Complete!',
        subtitle: 'Brilliant focus. You cleared this level.',
      ),
      _CelebrationStyle(
        icon: Icons.flash_on_rounded,
        accent: VarnamalaTheme.warning,
        title: 'That Was Fast!',
        subtitle: 'You are climbing fast. Keep the streak alive.',
      ),
      _CelebrationStyle(
        icon: Icons.auto_awesome_rounded,
        accent: VarnamalaTheme.leagueAmethyst,
        title: 'Excellent Work!',
        subtitle: 'Every lesson gets you closer to mastery.',
      ),
    ];
    final style = styles[Random().nextInt(styles.length)];

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: style.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                style.icon,
                color: style.accent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              style.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              style.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                "Back to Courses",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCompletionPlayerChoice extends StatelessWidget {
  const CourseCompletionPlayerChoice({super.key});

  @override
  Widget build(BuildContext context) {
    const styles = [
      _CelebrationStyle(
        icon: Icons.emoji_events_rounded,
        accent: VarnamalaTheme.successDark,
        title: 'Course Complete!',
        subtitle: "You've mastered all the lessons.",
      ),
      _CelebrationStyle(
        icon: Icons.workspace_premium_rounded,
        accent: VarnamalaTheme.leagueRuby,
        title: 'Legendary Finish!',
        subtitle: 'That was a strong finish. Keep practicing.',
      ),
      _CelebrationStyle(
        icon: Icons.star_rounded,
        accent: VarnamalaTheme.peacockTeal,
        title: 'Mastery Unlocked!',
        subtitle: 'You completed the course with style.',
      ),
    ];
    final style = styles[Random().nextInt(styles.length)];

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusXLarge)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: style.accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                style.icon,
                color: style.accent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              style.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              style.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Practice Again',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                "Back to Courses",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationStyle {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;

  const _CelebrationStyle({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });
}
