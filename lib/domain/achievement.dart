// Flutter imports:
import 'package:flutter/material.dart';

/// The stat an achievement tracks, and the Firestore field it reads.
///
/// Achievements used to carry a loosely-related "type" and the UI held a switch
/// mapping each one to a field, which is why some entries ended up pointing at
/// the wrong stat. Naming the field here means a new achievement is one list
/// entry and nothing else.
enum AchievementMetric {
  xp('score'),
  streak('streak'),
  lessons('lessonsCompleted'),
  perfectLessons('perfectLessons'),
  dailyXp('dailyXpEarned'),
  gems('gems'),
  leagueXp('leagueXp'),
  languages('languages'),
  badges('achievements'),
  coursesCompleted('coursesCompleted'),
  levelsCompleted('levelsCompleted'),
  wordsTapped('wordsTapped'),
  lettersPracticed('lettersPracticed'),
  matchBest('matchBestScore'),
  matchRounds('matchRoundsCleared'),
  matchGames('matchGamesPlayed'),
  bestCombo('matchBestCombo'),
  comments('commentsPosted'),
  helpfulVotes('helpfulVotes'),
  reports('reportsFiled'),
  hiFivesSent('hiFivesSent'),
  hiFivesReceived('hiFivesReceived'),
  friends('friendsCount'),
  dailyGoalsHit('dailyGoalsHit');

  const AchievementMetric(this.field);

  /// Where the number lives on the user document.
  final String field;

  /// Reads the metric, treating a list field (languages, badges) as its length.
  int read(Map<String, dynamic> data) {
    final value = data[field];
    if (value is num) return value.toInt();
    if (value is List) return value.length;
    return 0;
  }
}

/// Which part of the app an achievement belongs to, for grouping in the UI.
enum AchievementGroup {
  learning('Learning'),
  consistency('Consistency'),
  mastery('Mastery'),
  games('Games'),
  community('Community'),
  collection('Collection');

  const AchievementGroup(this.label);

  final String label;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.metric,
    required this.group,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.targets,
  });

  final String id;
  final AchievementMetric metric;
  final AchievementGroup group;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  /// Ascending thresholds; each one is a level of the same badge.
  final List<int> targets;

  int get maxLevel => targets.length;

  int progressFrom(Map<String, dynamic> data) => metric.read(data);

  /// 1-based level the learner is working towards, or [maxLevel] + 1 when the
  /// badge is fully earned.
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
