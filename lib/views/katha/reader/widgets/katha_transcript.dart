import 'package:flutter/material.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/reader/katha_reader_controller.dart';
import 'package:words625/views/katha/reader/widgets/katha_line_view.dart';
import 'package:words625/views/katha/scene/staging/katha_link_color.dart';

/// The current panel's lines. A run of lines from one person sits under one
/// name, and each line sits on the side its speaker stands on. Keeps the
/// line being spoken in view.
class KathaTranscript extends StatefulWidget {
  const KathaTranscript({super.key, required this.controller});

  final KathaReaderController controller;

  @override
  State<KathaTranscript> createState() => _KathaTranscriptState();
}

class _KathaTranscriptState extends State<KathaTranscript> {
  late final Map<String, GlobalKey> _lineKeys = {
    for (final beat in widget.controller.beats) beat.id: GlobalKey(),
  };
  int _shownIndex = -1;

  KathaReaderController get _controller => widget.controller;

  @override
  void didUpdateWidget(KathaTranscript old) {
    super.didUpdateWidget(old);
    _scrollToCurrent();
  }

  @override
  void initState() {
    super.initState();
    _scrollToCurrent();
  }

  /// Brings the line being spoken into view once it is laid out.
  void _scrollToCurrent() {
    final beat = _controller.currentBeat;
    if (beat == null || _controller.index == _shownIndex) return;
    _shownIndex = _controller.index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _lineKeys[beat.id]?.currentContext;
      if (target == null || !mounted) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.3,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final panel = c.panel;
    final sides = _sidesIn(panel);
    final shown = [
      for (final (i, beat) in c.beats.indexed)
        if (beat.panel == panel.id) i,
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
      children: [
        for (final (n, i) in shown.indexed)
          KeyedSubtree(
            key: _lineKeys[c.beats[i].id],
            child: KathaLineView(
              speaker: _speakerName(c.beats[i]),
              showSpeaker:
                  n == 0 || c.beats[shown[n - 1]].speaker != c.beats[i].speaker,
              side: sides[c.beats[i].speaker] ?? KathaLineSide.centre,
              line: c.lineFor(c.beats[i]),
              state: _stateOf(i),
              activeChunk: c.chunk,
              spelling: c.spelling,
              showTranslation: c.translations,
              linkColorFor: (cue) =>
                  kathaLinkColor(panel, c.story.scene.cues[cue]),
              onWordTap: c.tapWord,
              onWordHeld: c.sayWord,
            ),
          ),
      ],
    );
  }

  KathaLineState _stateOf(int i) {
    final c = _controller;
    if (!c.started || i > c.index) return KathaLineState.upcoming;
    if (i < c.index || c.finished) return KathaLineState.past;
    return KathaLineState.current;
  }

  /// Which side of the page each speaker in [panel] takes: whoever stands
  /// further left in the picture speaks from the left. Narration is centred.
  Map<String, KathaLineSide> _sidesIn(KathaPanel panel) {
    final speakers = {
      for (final beat in _controller.story.scene.beatsIn(panel.id))
        if (!beat.isNarration) beat.speaker,
    };
    final placed =
        panel.characters.where((c) => speakers.contains(c.id)).toList()
          ..sort((a, b) => a.x.compareTo(b.x));
    if (placed.length == 1) {
      final only = placed.single;
      return {only.id: only.x < 0.5 ? KathaLineSide.left : KathaLineSide.right};
    }
    return {
      for (final (i, c) in placed.indexed)
        c.id: i < placed.length / 2 ? KathaLineSide.left : KathaLineSide.right,
    };
  }

  /// The speaker as the telling names them (`name.raju`: "Raju Autowala"),
  /// so a language can localise its cast. Falls back to the scene id.
  String _speakerName(KathaBeat beat) {
    if (beat.isNarration) return '';
    final named = _controller.story.telling.strings['name.${beat.speaker}'];
    if (named != null) return named.roman;
    final id = beat.speaker;
    return id[0].toUpperCase() + id.substring(1);
  }
}
