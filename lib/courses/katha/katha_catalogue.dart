/// Every episode of Dev in the City, season by season, in reading order.
abstract final class KathaCatalogue {
  /// The series folder, under `stories/` and `assets/katha/`.
  static const series = 'dev-in-the-city';

  /// Each season's episodes, in order. A season with no episodes yet is left
  /// off the shelf.
  static const seasons = <List<String>>[
    [
      's1e01',
      's1e02',
      's1e03',
      's1e04',
      's1e05',
      's1e06',
      's1e07',
      's1e08',
      's1e09',
      's1e10',
    ],
    // The Lake.
    [
      's2e01',
      's2e02',
      's2e03',
      's2e04',
      's2e05',
      's2e06',
      's2e07',
      's2e08',
      's2e09',
      's2e10',
    ],
  ];

  /// Every episode of every season: the last episode of one season leads
  /// into the first of the next.
  static final List<String> episodes = [
    for (final season in seasons) ...season,
  ];

  /// The season [episode] belongs to, counting from one: `s2e03` is in 2.
  static int seasonOf(String episode) =>
      int.tryParse(_season.firstMatch(episode)?.group(1) ?? '') ?? 1;

  static final _season = RegExp(r'^s(\d+)e');
}
