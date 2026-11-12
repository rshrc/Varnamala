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
