import 'package:flutter/material.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/reader/katha_reader_controller.dart';
import 'package:words625/views/widgets/beta_badge.dart';

/// The episode's title, and the reading settings: English, spelling, and
/// listening without the words.
class KathaReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KathaReaderAppBar({super.key, required this.controller});

  final KathaReaderController controller;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final telling = controller.story.telling;
    final title = telling.strings['${controller.story.scene.id}.title'];
    final precise = controller.spelling == KathaSpelling.precise;
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title == null ? 'Katha' : controller.spelling.show(title.roman),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (telling.isBeta) ...[
            const SizedBox(width: 8),
            const BetaBadge(compact: true),
          ],
        ],
      ),
      actions: [
        IconButton(
          tooltip: controller.translations
              ? 'Hide the English'
              : 'Show the English',
          isSelected: controller.translations,
          icon: const Icon(Icons.translate_rounded),
          onPressed: controller.toggleTranslations,
        ),
        IconButton(
          tooltip: precise ? 'Casual spelling' : 'Show retroflex capitals',
          isSelected: precise,
          icon: const Icon(Icons.text_fields_rounded),
          onPressed: controller.toggleSpelling,
        ),
        IconButton(
          tooltip: controller.pictureOnly
              ? 'Show the words'
              : 'Hide the words: just listen',
          isSelected: controller.pictureOnly,
          icon: Icon(
            controller.pictureOnly
                ? Icons.subtitles_off_rounded
                : Icons.subtitles_rounded,
          ),
          onPressed: controller.togglePictureOnly,
        ),
      ],
    );
  }
}
