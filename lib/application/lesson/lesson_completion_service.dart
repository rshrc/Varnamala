import 'package:words625/application/achievements_provider.dart';
import 'package:words625/application/game_provider.dart';
import 'package:words625/application/gems_provider.dart';
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/application/lesson/interactive_course_progress.dart';
import 'package:words625/domain/course/course.dart';

/// Owns lesson progression and reward side effects.
///
/// UI-facing providers delegate here so their responsibility stays limited to
/// observable lesson state.
class LessonCompletionService {
  LessonCompletionService({
    required this.gameProvider,
    required this.gemsProvider,
    required this.achievementsProvider,
    this.interactiveProgress = const InteractiveCourseProgress(),
  });

  final GameProvider gameProvider;
  final GemsProvider gemsProvider;
  final AchievementsProvider achievementsProvider;
  final InteractiveCourseProgress interactiveProgress;

  Future<void> completeLegacyLesson({
    required bool wasPerfect,
    required bool courseCompleted,
  }) async {
    await gameProvider.awardXP(XPEvent.lessonComplete);
    await gemsProvider.earnGems(GemEvent.lessonComplete);

    if (wasPerfect) {
      await gameProvider.awardXP(XPEvent.perfectLesson);
      await gemsProvider.earnGems(GemEvent.perfectLesson);
    }

    await gameProvider.recordLessonCompletion(wasPerfect: wasPerfect);
    await gameProvider.bumpStat('levelsCompleted');
    if (courseCompleted) await gameProvider.bumpStat('coursesCompleted');
    await checkLessonMilestones();
  }

  Future<InteractiveProgressAdvance> completeInteractiveStage({
    required Course course,
    required int unitIndex,
    required LessonStageKind stage,
    required bool wasPerfect,
    bool isReplay = false,
  }) async {
    if (isReplay) return const InteractiveProgressAdvance.notCommitted();

    final advance = await interactiveProgress.advance(
      course: course,
      expectedUnitIndex: unitIndex,
      expectedStage: stage,
      stageWasPerfect: wasPerfect,
    );
    if (!advance.committed) return advance;

    final multiplier = switch (stage) {
      LessonStageKind.discover => 0.3,
      LessonStageKind.build => 0.3,
      LessonStageKind.recall => 0.4,
    };
    await gameProvider.awardXP(
      XPEvent.lessonComplete,
      multiplier: multiplier,
    );
    await gameProvider.recordLessonCompletion(wasPerfect: wasPerfect);

    if (advance.unitCompleted) {
      await gemsProvider.earnGems(GemEvent.lessonComplete);
      await gameProvider.bumpStat('levelsCompleted');
      if (advance.unitWasPerfect) {
        await gameProvider.awardXP(XPEvent.perfectLesson);
        await gemsProvider.earnGems(GemEvent.perfectLesson);
      }
    }
    if (advance.courseCompleted) {
      await gameProvider.bumpStat('coursesCompleted');
    }

    await checkLessonMilestones();
    return advance;
  }

  Future<void> checkLessonMilestones() async {
    final userData = await gameProvider.getUserGameStateOnce();
    await achievementsProvider.checkLessonMilestones(
      lessonsCompleted: (userData['lessonsCompleted'] as num? ?? 0).toInt(),
      perfectLessons: (userData['perfectLessons'] as num? ?? 0).toInt(),
    );
  }
}
