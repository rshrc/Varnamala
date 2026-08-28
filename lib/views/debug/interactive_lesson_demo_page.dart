// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:words625/application/interactive_lesson_engine.dart';
import 'package:words625/views/debug/interactive_lesson_samples.dart';
import 'package:words625/views/lesson/exercises/interactive_exercise_host.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/beta_badge.dart';

@RoutePage()
class InteractiveLessonDemoPage extends StatefulWidget {
  const InteractiveLessonDemoPage({super.key});

  @override
  State<InteractiveLessonDemoPage> createState() =>
      _InteractiveLessonDemoPageState();
}

class _InteractiveLessonDemoPageState extends State<InteractiveLessonDemoPage> {
  late final InteractiveLessonEngine _engine = InteractiveLessonEngine(
    exercises: buildInteractiveLessonSamples(),
  );

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _engine,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Interactive lesson lab'),
              SizedBox(width: 8),
              BetaBadge(compact: true),
            ],
          ),
        ),
        body: _engine.phase == InteractiveLessonPhase.complete
            ? _LessonSummary(engine: _engine)
            : _LessonBody(engine: _engine),
      ),
    );
  }
}

class _LessonBody extends StatelessWidget {
  const _LessonBody({required this.engine});

  final InteractiveLessonEngine engine;

  @override
  Widget build(BuildContext context) {
    final exercise = engine.currentExercise;
    final showingFeedback = engine.phase == InteractiveLessonPhase.feedback;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(VarnamalaTheme.radiusRound),
                        child: LinearProgressIndicator(
                          value: engine.progress,
                          minHeight: 9,
                          backgroundColor: context.appBorder,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${engine.currentNumber}/${engine.totalSteps}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.science_rounded,
                        size: 16, color: context.appViolet),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Debug sample · progress is not saved',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.appTextSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (engine.currentStep.isAdaptiveRetry) ...[
                    const _MistakeReviewNotice(),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    exercise.prompt,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 18),
                  IgnorePointer(
                    ignoring: showingFeedback,
                    child: AnimatedOpacity(
                      opacity: showingFeedback ? 0.62 : 1,
                      duration: const Duration(milliseconds: 150),
                      child: KeyedSubtree(
                        key: ValueKey(exercise.id),
                        child: InteractiveExerciseHost(
                          exercise: exercise,
                          onResponseChanged: engine.setResponse,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showingFeedback) _FeedbackPanel(engine: engine),
          _LessonAction(engine: engine),
        ],
      ),
    );
  }
}

class _MistakeReviewNotice extends StatelessWidget {
  const _MistakeReviewNotice();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Mistake review. This exercise revisits something you missed earlier.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: context.appViolet.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(VarnamalaTheme.radiusMedium),
          border: Border.all(
            color: context.appViolet.withValues(alpha: 0.42),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.appViolet.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.replay_rounded,
                color: context.appViolet,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MISTAKE REVIEW',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.appViolet,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'This revisits something you missed earlier.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appTextSecondary,
                          height: 1.3,
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

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({required this.engine});

  final InteractiveLessonEngine engine;

  @override
  Widget build(BuildContext context) {
    final correct = engine.lastAttempt?.correct ?? false;
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
                correct ? Icons.check_circle_rounded : Icons.refresh_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? 'Correct' : 'Not quite',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 6),
            Text(
              'Answer: ${engine.currentExercise.correctAnswerLabel}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
          const SizedBox(height: 5),
          Text(engine.currentExercise.explanation),
          if (engine.retryScheduledForLastAttempt) ...[
            const SizedBox(height: 7),
            Text(
              'A focused retry was added after two more exercises.',
              style: TextStyle(
                color: context.appViolet,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonAction extends StatelessWidget {
  const _LessonAction({required this.engine});

  final InteractiveLessonEngine engine;

  @override
  Widget build(BuildContext context) {
    final feedback = engine.phase == InteractiveLessonPhase.feedback;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: feedback
                ? engine.continueLesson
                : engine.canSubmit
                    ? engine.submit
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  feedback && !(engine.lastAttempt?.correct ?? false)
                      ? context.appDanger
                      : feedback
                          ? context.appSuccess
                          : context.appAccent,
            ),
            child: Text(
              feedback ? 'CONTINUE' : 'CHECK',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonSummary extends StatelessWidget {
  const _LessonSummary({required this.engine});

  final InteractiveLessonEngine engine;

  @override
  Widget build(BuildContext context) {
    final correct = engine.attempts.where((attempt) => attempt.correct).length;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.appSuccess.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.science_rounded,
                    size: 52, color: context.appSuccess),
              ),
              const SizedBox(height: 20),
              Text(
                'Sample complete',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nothing was written to course progress or Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.appTextSecondary),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _SummaryChip(label: '$correct correct'),
                  _SummaryChip(label: '${engine.mistakes} mistakes'),
                  _SummaryChip(
                    label:
                        '${engine.adaptiveRetriesCompleted} retries recovered',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: engine.restart,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('RUN SAMPLE AGAIN'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('BACK TO APP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: context.appElevatedSurface,
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
        border: Border.all(color: context.appBorder),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
