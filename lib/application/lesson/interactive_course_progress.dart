// Dart imports:
import 'dart:async';

// Project imports:
import 'package:words625/application/lesson/course_exercise_factory.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/course/course.dart';
import 'package:words625/service/locator.dart';

class InteractiveCourseProgressSnapshot {
  const InteractiveCourseProgressSnapshot({
    required this.completedUnits,
    required this.stageIndex,
    required this.totalUnits,
  });

  final int completedUnits;
  final int stageIndex;
  final int totalUnits;

  int get totalPlayableLessons => totalUnits * LessonStageKind.values.length;
  int get completedPlayableLessons => isComplete
      ? totalPlayableLessons
      : completedUnits * LessonStageKind.values.length + stageIndex;
  int get currentUnitIndex =>
      totalUnits == 0 ? 0 : completedUnits.clamp(0, totalUnits - 1).toInt();
  LessonStageKind get currentStage => LessonStageKind
      .values[stageIndex.clamp(0, LessonStageKind.values.length - 1).toInt()];
  bool get isComplete => totalUnits > 0 && completedUnits >= totalUnits;
}

class InteractiveProgressAdvance {
  const InteractiveProgressAdvance({
    required this.committed,
    required this.unitCompleted,
    required this.courseCompleted,
    required this.unitWasPerfect,
  });

  const InteractiveProgressAdvance.notCommitted()
      : committed = false,
        unitCompleted = false,
        courseCompleted = false,
        unitWasPerfect = false;

  final bool committed;
  final bool unitCompleted;
  final bool courseCompleted;
  final bool unitWasPerfect;
}

/// Versioned local progress for the three generated lesson stages in each
/// authored content unit.
///
/// The old course-name preference remains a read-only migration fallback. New
/// writes are language and course-ID scoped, so progress in Hindi can no longer
/// leak into Kannada merely because both have a course named Basics.
class InteractiveCourseProgress {
  const InteractiveCourseProgress();

  static const int generationVersion = 1;

  String _identity(Course course) =>
      '${course.language ?? 'legacy'}.${course.courseId ?? course.courseName}';

  String _unitsKey(Course course) =>
      'interactiveProgress.v$generationVersion.${_identity(course)}.units';
  String _stageKey(Course course) =>
      'interactiveProgress.v$generationVersion.${_identity(course)}.stage';
  String _perfectKey(Course course) =>
      'interactiveProgress.v$generationVersion.${_identity(course)}.perfect';
  String _legacyOwnerKey(Course course) =>
      'interactiveProgress.legacyOwner.${course.courseId ?? course.courseName}';

  InteractiveCourseProgressSnapshot read(Course course) {
    final preferences = getIt<AppPrefs>().preferences;
    final totalUnits = course.levels?.length ?? 0;
    final keys = preferences.getKeys().getValue();
    final legacyUnits = preferences
        .getInt(course.courseName, defaultValue: 0)
        .getValue()
        .clamp(0, totalUnits);
    final owner = preferences
        .getString(_legacyOwnerKey(course), defaultValue: '')
        .getValue();
    final language = course.language ?? 'legacy';
    final canClaimLegacy = owner.isEmpty || owner == language;
    if (legacyUnits > 0 && owner.isEmpty) {
      unawaited(preferences.setString(_legacyOwnerKey(course), language));
    }
    final migratedDefault = canClaimLegacy ? legacyUnits : 0;
    final completedUnits = preferences
        .getInt(
          _unitsKey(course),
          defaultValue: keys.contains(_unitsKey(course)) ? 0 : migratedDefault,
        )
        .getValue()
        .clamp(0, totalUnits);
    final stage = completedUnits >= totalUnits
        ? 0
        : preferences
            .getInt(_stageKey(course), defaultValue: 0)
            .getValue()
            .clamp(0, LessonStageKind.values.length - 1);
    return InteractiveCourseProgressSnapshot(
      completedUnits: completedUnits,
      stageIndex: stage,
      totalUnits: totalUnits,
    );
  }

  Future<InteractiveProgressAdvance> advance({
    required Course course,
    required int expectedUnitIndex,
    required LessonStageKind expectedStage,
    required bool stageWasPerfect,
  }) async {
    final current = read(course);
    if (current.isComplete ||
        current.currentUnitIndex != expectedUnitIndex ||
        current.currentStage != expectedStage) {
      return const InteractiveProgressAdvance.notCommitted();
    }

    final preferences = getIt<AppPrefs>().preferences;
    final priorPerfect = expectedStage == LessonStageKind.discover
        ? true
        : preferences
            .getBool(_perfectKey(course), defaultValue: true)
            .getValue();
    final unitWasPerfect = priorPerfect && stageWasPerfect;

    if (expectedStage != LessonStageKind.recall) {
      await preferences.setBool(_perfectKey(course), unitWasPerfect);
      await preferences.setInt(_stageKey(course), expectedStage.index + 1);
      await preferences.setInt(_unitsKey(course), current.completedUnits);
      return InteractiveProgressAdvance(
        committed: true,
        unitCompleted: false,
        courseCompleted: false,
        unitWasPerfect: unitWasPerfect,
      );
    }

    final completedUnits = expectedUnitIndex + 1;
    await preferences.setInt(_unitsKey(course), completedUnits);
    await preferences.setInt(_stageKey(course), 0);
    await preferences.setBool(_perfectKey(course), true);

    // Preserve the legacy value for older builds and the existing course tree
    // until the interactive renderer leaves beta.
    await preferences.setInt(course.courseName, completedUnits);

    return InteractiveProgressAdvance(
      committed: true,
      unitCompleted: true,
      courseCompleted: completedUnits >= current.totalUnits,
      unitWasPerfect: unitWasPerfect,
    );
  }
}
