// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:words625/domain/exercise/interactive_exercise.dart';

enum InteractiveLessonPhase { answering, feedback, complete }

class InteractiveLessonAttempt {
  const InteractiveLessonAttempt({
    required this.exerciseId,
    required this.response,
    required this.correct,
    required this.isAdaptiveRetry,
  });

  final String exerciseId;
  final ExerciseResponse response;
  final bool correct;
  final bool isAdaptiveRetry;
}

class InteractiveLessonStep {
  const InteractiveLessonStep({
    required this.exercise,
    this.retryForExerciseId,
  });

  final InteractiveExercise exercise;
  final String? retryForExerciseId;

  bool get isAdaptiveRetry => retryForExerciseId != null;
}

/// Owns a mixed lesson's queue, responses, validation, feedback, and retries.
///
/// Renderers only report a typed [ExerciseResponse]. This lets a choice, token
/// sequence, or text field participate in the same lesson lifecycle.
class InteractiveLessonEngine extends ChangeNotifier {
  InteractiveLessonEngine({required List<InteractiveExercise> exercises})
      : assert(exercises.isNotEmpty),
        _initialExercises = List.unmodifiable(exercises) {
    _resetQueue();
  }

  final List<InteractiveExercise> _initialExercises;
  final List<InteractiveLessonStep> _queue = [];
  final List<InteractiveLessonAttempt> _attempts = [];
  final Set<String> _scheduledRetries = {};

  int _index = 0;
  ExerciseResponse? _response;
  InteractiveLessonPhase _phase = InteractiveLessonPhase.answering;
  InteractiveLessonAttempt? _lastAttempt;
  bool _retryScheduledForLastAttempt = false;

  InteractiveLessonPhase get phase => _phase;
  InteractiveLessonStep get currentStep => _queue[_index];
  InteractiveExercise get currentExercise => currentStep.exercise;
  ExerciseResponse? get response => _response;
  InteractiveLessonAttempt? get lastAttempt => _lastAttempt;
  List<InteractiveLessonAttempt> get attempts => List.unmodifiable(_attempts);
  int get currentNumber => _index + 1;
  int get totalSteps => _queue.length;
  int get mistakes => _attempts.where((attempt) => !attempt.correct).length;
  int get adaptiveRetriesCompleted => _attempts
      .where((attempt) => attempt.isAdaptiveRetry && attempt.correct)
      .length;
  bool get canSubmit =>
      _phase == InteractiveLessonPhase.answering && _response != null;
  bool get retryScheduledForLastAttempt => _retryScheduledForLastAttempt;
  double get progress {
    if (_phase == InteractiveLessonPhase.complete) return 1;
    final completed =
        _index + (_phase == InteractiveLessonPhase.feedback ? 1 : 0);
    return completed / _queue.length;
  }

  void setResponse(ExerciseResponse? response) {
    if (_phase != InteractiveLessonPhase.answering) return;
    _response = response;
    notifyListeners();
  }

  bool submit() {
    final response = _response;
    if (!canSubmit || response == null) return false;

    final step = currentStep;
    final correct = step.exercise.isCorrect(response);
    final attempt = InteractiveLessonAttempt(
      exerciseId: step.exercise.id,
      response: response,
      correct: correct,
      isAdaptiveRetry: step.isAdaptiveRetry,
    );
    _attempts.add(attempt);
    _lastAttempt = attempt;
    _retryScheduledForLastAttempt = false;

    if (!correct &&
        !step.isAdaptiveRetry &&
        step.exercise.adaptiveRetry != null &&
        _scheduledRetries.add(step.exercise.id)) {
      // Two normal exercises remain between the mistake and its focused retry
      // whenever the queue is long enough.
      final insertionIndex = math.min(_index + 3, _queue.length);
      _queue.insert(
        insertionIndex,
        InteractiveLessonStep(
          exercise: step.exercise.adaptiveRetry!,
          retryForExerciseId: step.exercise.id,
        ),
      );
      _retryScheduledForLastAttempt = true;
    }

    _phase = InteractiveLessonPhase.feedback;
    notifyListeners();
    return correct;
  }

  void continueLesson() {
    if (_phase != InteractiveLessonPhase.feedback) return;
    if (_index >= _queue.length - 1) {
      _phase = InteractiveLessonPhase.complete;
    } else {
      _index += 1;
      _response = null;
      _lastAttempt = null;
      _retryScheduledForLastAttempt = false;
      _phase = InteractiveLessonPhase.answering;
    }
    notifyListeners();
  }

  void restart() {
    _attempts.clear();
    _scheduledRetries.clear();
    _index = 0;
    _response = null;
    _lastAttempt = null;
    _retryScheduledForLastAttempt = false;
    _phase = InteractiveLessonPhase.answering;
    _resetQueue();
    notifyListeners();
  }

  void _resetQueue() {
    _queue
      ..clear()
      ..addAll(
        _initialExercises.map(
          (exercise) => InteractiveLessonStep(exercise: exercise),
        ),
      );
  }
}
