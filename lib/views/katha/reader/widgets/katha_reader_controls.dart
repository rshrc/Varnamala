import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/views/katha/reader/katha_reader_controller.dart';

/// Back, again, pause, report, and the main button: Start, Next, Finish,
/// Read again, or Next episode.
class KathaReaderControls extends StatelessWidget {
  const KathaReaderControls({super.key, required this.controller});

  final KathaReaderController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final playing = c.started && !c.finished;
    final next = c.nextEpisode;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous line',
            onPressed: playing && c.index > 0 ? c.previous : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            tooltip: 'Hear it again',
            onPressed: playing ? c.replay : null,
            icon: const Icon(Icons.volume_up_rounded),
          ),
          if (!c.finished)
            IconButton(
              tooltip: c.autoplay ? 'Pause after this line' : 'Play on',
              onPressed: c.started ? c.toggleAutoplay : null,
              icon: Icon(
                c.autoplay ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
            ),
          if (c.story.telling.isBeta)
            TextButton(
              onPressed: () => launchUrl(
                c.mistakeReport,
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Report a mistake'),
            ),
          const Spacer(),
          if (c.finished && next != null)
            FilledButton.icon(
              onPressed: () => context.router.replace(
                KathaReaderRoute(lang: c.story.telling.lang, episode: next),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next episode'),
            )
          else
            FilledButton(onPressed: c.next, child: Text(_mainLabel)),
        ],
      ),
    );
  }

  String get _mainLabel => switch (controller) {
    KathaReaderController(started: false) => 'Start',
    KathaReaderController(finished: true) => 'Read again',
    KathaReaderController(atLastLine: true) => 'Finish',
    _ => 'Next',
  };
}
