import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:words625/views/katha/reader/katha_reader_controller.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/theme.dart';

/// The picture. Tapping it moves the story on; before the first line it
/// carries the Start button.
class KathaSceneView extends StatelessWidget {
  const KathaSceneView({super.key, required this.controller});

  final KathaReaderController controller;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(VarnamalaTheme.radiusLarge),
      child: AspectRatio(
        aspectRatio: kathaWorldWidth / kathaWorldHeight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.next,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: still
                    ? Duration.zero
                    : const Duration(milliseconds: 380),
                child: GameWidget(
                  key: ValueKey(controller.panelId),
                  game: controller.game,
                ),
              ),
              if (!controller.started)
                ColoredBox(
                  color: KathaInk.ink.withValues(alpha: 0.35),
                  child: Center(
                    child: FilledButton.icon(
                      onPressed: controller.next,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
