/// The stat an achievement tracks, and the Firestore field it reads.
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

  final String field;

  int read(Map<String, dynamic> data) {
    final value = data[field];
    if (value is num) return value.toInt();
    if (value is List) return value.length;
    return 0;
  }
}
