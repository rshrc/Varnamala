import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:words625/application/language_provider.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/courses/katha.dart';
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/views/katha/shelf/widgets/katha_episode_card.dart';
import 'package:words625/views/katha/shelf/widgets/katha_not_told_yet.dart';
import 'package:words625/views/katha/shelf/widgets/katha_season_heading.dart';
import 'package:words625/views/katha/shelf/widgets/katha_shelf_header.dart';

/// The Stories tab: Dev in the City, every season, in the learner's language.
///
/// A language with no tellings yet says so and offers the ones that exist,
/// rather than showing an empty shelf.
class KathaShelf extends StatefulWidget {
  const KathaShelf({super.key});

  @override
  State<KathaShelf> createState() => _KathaShelfState();
}

class _KathaShelfState extends State<KathaShelf> {
  static const _series = KathaCatalogue.series;
  final _repository = KathaRepository();
  final Map<String, Future<List<KathaEpisode>>> _seasons = {};

  /// A telling picked here when the learner's own language has none.
  String? _chosen;

  /// Every written episode in [lang], in reading order.
  Future<List<KathaEpisode>> _season(String lang) =>
      _seasons[lang] ??= Future.wait([
        for (final episode in KathaCatalogue.episodes)
          _repository.load(series: _series, episode: episode, lang: lang),
      ]);

  @override
  Widget build(BuildContext context) {
    final language = context.select<LanguageProvider, TargetLanguage>(
      (provider) => provider.selectedLanguage,
    );
    final own = KathaLanguages.tellingFor(language);
    final lang = own ?? _chosen;

    return ContentBounds(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          KathaShelfHeader(
            language: lang == null ? null : KathaLanguages.byCode[lang],
          ),
          const SizedBox(height: 16),
          if (own == null) ...[
            KathaNotToldYet(
              language: language,
              chosen: _chosen,
              onChoose: (code) => setState(() => _chosen = code),
            ),
            const SizedBox(height: 16),
          ],
          if (lang != null)
            FutureBuilder<List<KathaEpisode>>(
              future: _season(lang),
              builder: (context, snapshot) {
                final season = snapshot.data;
                if (season == null) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                // Newest season first: that is where a returning reader is.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (n, episodes)
                        in KathaCatalogue.seasons.indexed.toList().reversed)
                      if (episodes.isNotEmpty) ...[
                        KathaSeasonHeading(
                          season: n + 1,
                          episodes: episodes.length,
                        ),
                        for (final (i, id) in episodes.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: KathaEpisodeCard(
                              number: i + 1,
                              story:
                                  season[KathaCatalogue.episodes.indexOf(id)],
                              onOpen: () => context.router.push(
                                KathaReaderRoute(lang: lang, episode: id),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
