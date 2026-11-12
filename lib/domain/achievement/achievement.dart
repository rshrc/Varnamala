import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/achievement/achievement_group.dart';
import 'package:words625/domain/achievement/achievement_metric.dart';

part 'achievement.freezed.dart';

@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required AchievementMetric metric,
    required AchievementGroup group,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<int> targets,
  }) = _Achievement;

  const Achievement._();

  int get maxLevel => targets.length;

  int progressFrom(Map<String, dynamic> data) => metric.read(data);

  int getCurrentLevel(int progress) {
    for (var i = 0; i < targets.length; i++) {
      if (progress < targets[i]) return i + 1;
    }
    return targets.length + 1;
  }

  int getTargetForLevel(int level) {
    if (targets.isEmpty) return 0;
    if (level <= 0) return targets.first;
    if (level > targets.length) return targets.last;
    return targets[level - 1];
  }

  bool isComplete(int progress) =>
      targets.isNotEmpty && progress >= targets.last;
}
