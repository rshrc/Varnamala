import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:words625/courses/katha.dart';
import 'package:words625/views/katha/reader/katha_reader_controller.dart';
import 'package:words625/views/katha/reader/katha_reader_view.dart';

/// An episode of a Katha story, read panel by panel in one language.
///
/// `/katha-lab` reads s1e01 in Kannada; `?lang=hi&episode=s1e02` reads
/// episode 2 in Hindi. The path keeps its old name so links already shared
/// still open.
@RoutePage()
class KathaReaderPage extends StatelessWidget {
  const KathaReaderPage({
    super.key,
    @QueryParam('lang') this.lang = 'kn',
    @QueryParam('episode') this.episode = 's1e01',
  });

  final String lang;
  final String episode;

  /// Keyed by telling and episode. auto_route keys a page by its route name,
  /// not its query, so moving to the next episode hands this same page new
  /// parameters; the key makes it start over rather than keep the old story.
  @override
  Widget build(BuildContext context) => _KathaReaderLoader(
    key: ValueKey('$lang/$episode'),
    lang: lang,
    episode: episode,
  );
}

/// Loads the episode, then holds its [KathaReaderController] for as long as
/// the page is open.
class _KathaReaderLoader extends StatefulWidget {
  const _KathaReaderLoader({
    super.key,
    required this.lang,
    required this.episode,
  });

  final String lang;
  final String episode;

  @override
  State<_KathaReaderLoader> createState() => _KathaReaderLoaderState();
}

class _KathaReaderLoaderState extends State<_KathaReaderLoader> {
  late final Future<KathaEpisode> _story = KathaRepository().load(
    series: KathaCatalogue.series,
    episode: widget.episode,
    lang: widget.lang,
  );
  KathaReaderController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.reducedMotion = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  KathaReaderController _controllerFor(KathaEpisode story) =>
      _controller ??= KathaReaderController(
        story: story,
        reducedMotion: MediaQuery.disableAnimationsOf(context),
      );

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _story,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('Katha')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not load this story.\n${snapshot.error}'),
            ),
          ),
        );
      }
      final story = snapshot.data;
      if (story == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return KathaReaderView(controller: _controllerFor(story));
    },
  );
}
