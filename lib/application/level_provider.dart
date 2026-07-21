// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:words625/application/achievements_provider.dart';
import 'package:words625/application/audio_controller.dart';
import 'package:words625/application/game_provider.dart';
import 'package:words625/application/gems_provider.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/lesson/lesson_screen.dart';

enum AnswerState {
  none,
  selected,
  correct,
  incorrect,
  readyForNext,
}

extension AnswerStateX on AnswerState {
  bool get isCorrect =>
      this == AnswerState.correct || this == AnswerState.readyForNext;
  bool get isIncorrect => this == AnswerState.incorrect;
}

@injectable
class LessonProvider with ChangeNotifier {
  final AudioController _audioController;
  final GameProvider _gameProvider;
  final GemsProvider _gemsProvider;
  final AchievementsProvider _achievementsProvider;

  LessonProvider(
    this._audioController,
    this._gameProvider,
    this._gemsProvider,
    this._achievementsProvider,
  );

  Course? _currentCourse;
  int _currentLevelIndex = 0;
  int _currentQuestionIndex = 0;
  bool _isAnswerCorrect = false;
  bool _hasSelectedAnswer = false;
  String? _selectedAnswer;
  double _percent = 0;
  AnswerState _answerState = AnswerState.none;
  int _mistakesInCurrentLevel = 0;

  // Getters for the UI to use
  Course? get currentCourse => _currentCourse;
  Level? get currentLevel => _currentCourse?.levels?[_currentLevelIndex];
  Question? get currentQuestion =>
      currentLevel?.questions?[_currentQuestionIndex];
  bool get isAnswerCorrect => _isAnswerCorrect;
  bool get hasSelectedAnswer => _hasSelectedAnswer;
  String? get selectedAnswer => _selectedAnswer;
  double get percent => _percent;
  AnswerState get answerState => _answerState;

  void selectAnswer(String? answer) {
    _selectedAnswer = answer;
    _answerState = AnswerState.selected;
    notifyListeners();
  }

  // Function to set the current course and reset progress
  void setCourse(Course course) {
    _currentCourse = course;
    final storedProgress = getIt<AppPrefs>()
        .preferences
        .getInt(currentCourse!.courseName, defaultValue: 0)
        .getValue();
    final totalLevels = currentCourse?.levels?.length ?? 0;
    if (totalLevels == 0) {
      _currentLevelIndex = 0;
    } else {
      _currentLevelIndex = storedProgress >= totalLevels
          ? totalLevels - 1
          : storedProgress.clamp(0, totalLevels - 1);
    }
    _currentQuestionIndex = 0;
    _isAnswerCorrect = false;
    _hasSelectedAnswer = false;
    shuffleOptions();
    notifyListeners();
  }

  void shuffleOptions() {
    for (var level in currentCourse!.levels!) {
      for (var question in level.questions!) {
        question.options!.shuffle();
      }
    }
  }

  // Function to check if the selected answer is correct
  bool checkAnswer() {
    if (selectedAnswer == currentQuestion?.correctAnswer) {
      _answerState = AnswerState.correct;
      _isAnswerCorrect = true;
      _audioController.playRandomLevelUpSound();
    } else {
      _answerState = AnswerState.incorrect;
      _isAnswerCorrect = false;
      _mistakesInCurrentLevel += 1;
      _audioController.playRandomErrorSound();
    }

    notifyListeners();

    return selectedAnswer == currentQuestion?.correctAnswer;
  }

  // Function to proceed to the next question or level
  Future<void> next(BuildContext context) async {
    if (_currentQuestionIndex < (currentLevel?.questions!.length)! - 1) {
      _currentQuestionIndex++;
    } else if (_currentLevelIndex < _currentCourse!.levels!.length - 1) {
      _currentLevelIndex++;
      _currentQuestionIndex = 0;
      _percent = 0;

      // show dialog to continue, or change stuff
      logger.w("You have completed the level");
      await _onLessonCompleted();
      _mistakesInCurrentLevel = 0;

      // We store the game progress in local shared preferences
      getIt<AppPrefs>()
          .preferences
          .setInt(currentCourse!.courseName, _currentLevelIndex);

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => const LevelPlayerChoice(),
      );
    } else {
      // Reached the end of the course
      final totalLevels = _currentCourse?.levels?.length ?? 0;
      if (totalLevels > 0) {
        await getIt<AppPrefs>()
            .preferences
            .setInt(currentCourse!.courseName, totalLevels);
      }
      _currentLevelIndex = 0;
      _currentQuestionIndex = 0;
      await _onLessonCompleted();
      _mistakesInCurrentLevel = 0;

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => const CourseCompletionPlayerChoice(),
      );
    }
    _answerState = AnswerState.none;
    _isAnswerCorrect = false;
    _hasSelectedAnswer = false;
    _percent = (_currentQuestionIndex + 1) / (currentLevel!.questions!.length);
    notifyListeners();
  }

  Future<void> _onLessonCompleted() async {
    final wasPerfect = _mistakesInCurrentLevel == 0;

    await _gameProvider.awardXP(XPEvent.lessonComplete);
    await _gemsProvider.earnGems(GemEvent.lessonComplete);

    if (wasPerfect) {
      await _gameProvider.awardXP(XPEvent.perfectLesson);
      await _gemsProvider.earnGems(GemEvent.perfectLesson);
    }

    await _gameProvider.recordLessonCompletion(wasPerfect: wasPerfect);

    // Counters the achievement catalogue reads. A level is one lesson; a course
    // is done when its last level is.
    await _gameProvider.bumpStat('levelsCompleted');
    final course = _currentCourse;
    if (course != null) {
      final totalLevels = course.levels?.length ?? 0;
      if (totalLevels > 0 && _currentLevelIndex + 1 >= totalLevels) {
        await _gameProvider.bumpStat('coursesCompleted');
      }
    }

    final userData = await _gameProvider.getUserGameStateOnce();
    final lessonsCompleted = (userData['lessonsCompleted'] as num? ?? 0).toInt();
    final perfectLessons = (userData['perfectLessons'] as num? ?? 0).toInt();
    await _achievementsProvider.checkLessonMilestones(
      lessonsCompleted: lessonsCompleted,
      perfectLessons: perfectLessons,
    );
  }

  void changeAnswerState(AnswerState answerState) {
    _answerState = answerState;
    notifyListeners();
  }

  // Reset course progress
  void reset() {
    _currentLevelIndex = 0;
    _currentQuestionIndex = 0;
    _isAnswerCorrect = false;
    _hasSelectedAnswer = false;
    _answerState = AnswerState.none;
    _percent = 0;
    notifyListeners();
  }
}
