// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_route/annotations.dart';
import 'package:chiclet/chiclet.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/audio_controller.dart';
import 'package:words625/application/interactive_lesson_engine.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/application/level_provider.dart';
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/application/lesson/interactive_course_progress.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/courses/courses.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/views/courses/components/community_sheet.dart';
import 'package:words625/views/lesson/components/lesson_app_bar.dart';
import 'package:words625/views/lesson/components/interactive_completion_view.dart';
import 'package:words625/views/lesson/components/interactive_feedback_panel.dart';
import 'package:words625/views/lesson/components/list_lesson.dart';
import 'package:words625/views/lesson/components/mistake_review_notice.dart';
import 'package:words625/views/lesson/exercises/exercise_evaluation.dart';
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
      return InteractiveCompletionView(
        course: widget.course,
        stage: _stageKind,
        isReplay: _isReplay,
        completion: _completion,
      );
    }

    final generated = _currentGenerated(engine, stage);
    final isFeedback = engine.phase == InteractiveLessonPhase.feedback;
    final buttonEnabled = !_finishing && (isFeedback || engine.canSubmit);
    final buttonColor = isFeedback
        ? engine.lastAttempt!.correct
            ? context.appSuccess
            : context.appDanger
        : context.appAccent;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Leave lesson',
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close_rounded, color: context.appDanger),
        ),
        // The unit label and progress bar line up with the exercise column
        // below them rather than running the width of the window.
        title: ContentBounds(
          gutter: false,
          child: Column(
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
                // A prompt stretched across a desktop window is a prompt
                // nobody can read in one glance, so the exercise keeps to a
                // single column no matter how much room there is.
                child: ContentBounds(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (engine.currentStep.isAdaptiveRetry) ...[
                        const MistakeReviewNotice(),
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
                      // Answering is locked once checked, but the exercise
                      // stays at full strength: the tile the learner tapped is
                      // where the verdict has to land, so fading the whole
                      // thing out - which only ever read as "disabled" - would
                      // hide the one thing worth looking at.
                      IgnorePointer(
                        ignoring: isFeedback,
                        child: InteractiveExerciseHost(
                          key: ValueKey(engine.currentExercise.id),
                          exercise: engine.currentExercise,
                          onResponseChanged: engine.setResponse,
                          evaluation: engine.lastAttempt == null
                              ? null
                              : ExerciseEvaluation(
                                  correct: engine.lastAttempt!.correct,
                                  response: engine.lastAttempt!.response,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Sliding the band in rather than inserting it keeps the footer
            // from jumping under the learner's thumb the instant they check.
            AnimatedSize(
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: isFeedback
                  ? InteractiveFeedbackPanel(engine: engine)
                  : const SizedBox(width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: ContentBounds(
                gutter: false,
                // A flat button was a regression from the legacy renderer,
                // whose chiclet press is a large part of why checking an
                // answer felt like anything at all.
                child: ChicletAnimatedButton(
                  width: double.infinity,
                  height: 52,
                  backgroundColor: buttonEnabled
                      ? buttonColor
                      : Theme.of(context).disabledColor,
                  onPressed: buttonEnabled
                      ? () => _handleInteractiveAction(engine)
                      : null,
                  child: Text(
                    _finishing
                        ? 'SAVING…'
                        : isFeedback
                            ? 'CONTINUE'
                            : 'CHECK',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: buttonEnabled
                          ? onColorFor(buttonColor)
                          : context.appTextSecondary,
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

  /// The half of feedback that is not on the screen.
  ///
  /// [AudioController] and its eight sounds already existed, but were only ever
  /// wired into the legacy renderer and Match Madness - so the lessons every
  /// learner actually plays checked answers in total silence, which is most of
  /// why they felt flat next to Duolingo.
  void _cueVerdict({required bool correct}) {
    if (correct) {
      HapticFeedback.lightImpact();
      getIt<AudioController>().playRandomLevelUpSound();
    } else {
      HapticFeedback.heavyImpact();
      getIt<AudioController>().playRandomErrorSound();
    }
  }

  Future<void> _handleInteractiveAction(
    InteractiveLessonEngine engine,
  ) async {
    if (engine.phase == InteractiveLessonPhase.answering) {
      final correct = engine.submit();
      _cueVerdict(correct: correct);
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
