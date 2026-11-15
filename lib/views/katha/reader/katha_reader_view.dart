import 'package:flutter/material.dart';
import 'package:words625/core/responsive.dart';
import 'package:words625/views/katha/reader/katha_reader_controller.dart';
import 'package:words625/views/katha/reader/widgets/katha_listen_hint.dart';
import 'package:words625/views/katha/reader/widgets/katha_reader_app_bar.dart';
import 'package:words625/views/katha/reader/widgets/katha_reader_controls.dart';
import 'package:words625/views/katha/reader/widgets/katha_scene_view.dart';
import 'package:words625/views/katha/reader/widgets/katha_transcript.dart';

/// The reader's screen: the picture, the lines under it, the controls.
class KathaReaderView extends StatelessWidget {
  const KathaReaderView({super.key, required this.controller});

  final KathaReaderController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: KathaReaderAppBar(controller: controller),
      body: SafeArea(
        top: false,
        child: ContentBounds(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              KathaSceneView(controller: controller),
              const SizedBox(height: 8),
              Expanded(
                child: controller.pictureOnly
                    ? const KathaListenHint()
                    : KathaTranscript(controller: controller),
              ),
              if (controller.finished && controller.nextEpisode == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'The end, for now. More is being written.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              KathaReaderControls(controller: controller),
            ],
          ),
        ),
      ),
    ),
  );
}
