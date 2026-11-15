import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:words625/courses/katha.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/service/speech_service.dart';
import 'package:words625/views/katha/katha_delivery.dart';
import 'package:words625/views/katha/reader/katha_line_performance.dart';
import 'package:words625/views/katha/scene/katha_panel_game.dart';
import 'package:words625/views/katha/scene/staging/katha_backdrops.dart';
import 'package:words625/views/katha/voice/katha_take.dart';
import 'package:words625/views/katha/voice/katha_voice.dart';

/// The state of an episode being read: which line is playing, which panel
/// is on screen, and how the learner has set the page up.
///
/// Lines play one after another on their own (autoplay), like a radio play,
/// and stop at the cliffhanger. Nothing plays until the first tap, because a
/// browser only lets audio start from one.
class KathaReaderController extends ChangeNotifier {
  KathaReaderController({
    required this.story,
    required bool reducedMotion,
    SpeechService? speech,
    KathaVoice? voice,
    KathaVoice? wordVoice,
  }) : _speech = speech ?? getIt<SpeechService>(),
       _voice = voice ?? KathaVoice(),
       _wordVoice = wordVoice ?? KathaVoice(keep: 24),
       // A setter of the same name also updates the game, so no initializing formal.
       // ignore: prefer_initializing_formals
       _reducedMotion = reducedMotion {
    final drawn = [
      for (final panel in story.scene.panels)
        if (kathaDrawnBackdrops.contains(panel.background)) panel.id,
    ];
    beats = [for (final id in drawn) ...story.scene.beatsIn(id)];
    _panelId = drawn.first;
    _game = _gameFor(_panelId);
    final language = story.language;
    _hasDeviceVoice = language == null
        ? Future.value(false)
        : _speech.hasNativeVoice(language);
    _prefetchFrom(0);
  }

  final KathaEpisode story;

  /// The lines played, in order: every beat in a panel whose set is drawn.
  late final List<KathaBeat> beats;

  final SpeechService _speech;

  /// Recorded lines, and recorded words said on their own. Separate, so a
  /// word tapped mid-line does not cut the line off.
  final KathaVoice _voice;
  final KathaVoice _wordVoice;
  late final Future<bool> _hasDeviceVoice;

  /// How many lines ahead to download while one plays.
  static const _lookahead = 3;

  late KathaPanelGame _game;
  late String _panelId;
  bool _reducedMotion;

  int _index = -1;
  int _chunk = 0;
  bool _finished = false;
  bool _lineDone = false;
  bool _autoplay = true;
  bool _pictureOnly = false;
  bool _translations = true;
  KathaSpelling _spelling = KathaSpelling.casual;

  KathaLinePerformance? _performance;
  Timer? _breath;
  bool _disposed = false;

  // ---------------------------------------------------------------- state

  /// The picture on screen.
  KathaPanelGame get game => _game;
  String get panelId => _panelId;
  KathaPanel get panel => story.scene.panel(_panelId);

  /// The line playing or last played; -1 before the first tap.
  int get index => _index;
  bool get started => _index >= 0;
  KathaBeat? get currentBeat => started ? beats[_index] : null;

  /// The chunk of the current line being spoken.
  int get chunk => _chunk;

  /// The learner has played past the last line.
  bool get finished => _finished;
  bool get atLastLine => _index == beats.length - 1;
  bool get autoplay => _autoplay;

  /// The words are hidden: listen and watch.
  bool get pictureOnly => _pictureOnly;

  /// The English beneath each line. On by default; off for a challenge.
  bool get translations => _translations;
  KathaSpelling get spelling => _spelling;

  KathaLine lineFor(KathaBeat beat) => story.telling.lines[beat.id]!;

  /// The episode after this one, if there is one yet.
  String? get nextEpisode {
    final episodes = KathaCatalogue.episodes;
    final at = episodes.indexOf(story.scene.id);
    return at < 0 || at == episodes.length - 1 ? null : episodes[at + 1];
  }

  set reducedMotion(bool value) {
    _reducedMotion = value;
    _game.reducedMotion = value;
  }

  // ---------------------------------------------------------------- moving

  /// Starts, moves on a line, or finishes: whatever the main button means now.
  void next() {
    if (!started || _finished) {
      play(0);
    } else if (!atLastLine) {
      play(_index + 1);
    } else {
      _stop();
      _finished = true;
      _game.showBubble(null);
      notifyListeners();
    }
  }

  void previous() {
    if (_index > 0) play(_index - 1);
  }

  void replay() {
    if (started && !_finished) play(_index);
  }

  /// Plays line [index], moving the picture to its panel.
  void play(int index) {
    final beat = beats[index];
    _enterPanel(beat.panel);
    // Every line starts from a tap or from autoplay after one, so this runs
    // inside the first tap, which is when iPhone Safari allows audio.
    _voice.unlock();
    _wordVoice.unlock();
    _stop();
    _index = index;
    _chunk = 0;
    _finished = false;
    _lineDone = false;
    notifyListeners();

    _game.showBubble(_pictureOnly ? beat : null);
    for (final cue in beat.onStart) {
      _game.fireCue(cue);
    }
    _perform(beat);
    _prefetchFrom(index + 1);
  }

  Future<void> _perform(KathaBeat beat) async {
    final line = lineFor(beat);
    final performance = _performance = KathaLinePerformance(
      beat: beat,
      line: line,
      game: _game,
      voice: _voice,
      speech: _speech,
      hasDeviceVoice: _hasDeviceVoice,
      recording: story.audioFor(line),
      language: story.language,
      casting: _castingFor(beat.speaker),
      onChunk: (chunk) {
        _chunk = chunk;
        notifyListeners();
      },
    );
    await performance.run();
    if (performance.cancelled || _disposed) return;
    _lineDone = true;
    _playOnAfterBreath(beat);
  }

  /// With autoplay on, the next line follows after a breath: short for a
  /// reply, longer for a cut to a new picture. The last line is the
  /// cliffhanger, and waits for the learner.
  void _playOnAfterBreath(KathaBeat beat) {
    if (!_autoplay || atLastLine) return;
    final following = beats[_index + 1];
    final breath = following.panel == beat.panel
        ? kathaLineBreath
        : kathaPanelBreath;
    _breath = Timer(breath, () {
      if (_autoplay && !_disposed) next();
    });
  }

  /// Stops the line playing, its timers, and every voice.
  void _stop() {
    _performance?.cancel();
    _performance = null;
    _breath?.cancel();
    _speech.stop();
    _voice.stop();
    _game.hush();
  }

  void _enterPanel(String panelId) {
    if (panelId == _panelId) return;
    _game.close();
    _panelId = panelId;
    _game = _gameFor(panelId);
  }

  KathaPanelGame _gameFor(String panelId) => KathaPanelGame(
    scene: story.scene,
    panel: story.scene.panel(panelId),
    reducedMotion: _reducedMotion,
  );

  /// Starts downloading the recordings of the lines from [index] on, so the
  /// next one plays the moment it is reached.
  void _prefetchFrom(int index) => _voice.prefetch([
    for (final beat in beats.skip(index).take(_lookahead))
      ?story.audioFor(lineFor(beat)),
  ]);

  /// The device voice for [speaker], from the scene's cast. Each character
  /// gets their own variant, so on a device with several voices for the
  /// language nobody shares one.
  SpeechCasting? _castingFor(String speaker) {
    final cast = story.scene.cast;
    final role = cast[speaker];
    if (role == null) return null;
    return SpeechCasting(
      male: role.gender == 'male',
      variant: cast.keys.toList().indexOf(speaker),
      pitch: role.pitch,
      rate: role.rate,
    );
  }

  // ---------------------------------------------------------------- settings

  void toggleAutoplay() {
    _autoplay = !_autoplay;
    notifyListeners();
    if (_autoplay && _lineDone && !_finished && started) next();
  }

  void togglePictureOnly() {
    _pictureOnly = !_pictureOnly;
    _game.showBubble(_pictureOnly && !_finished ? currentBeat : null);
    notifyListeners();
  }

  void toggleTranslations() {
    _translations = !_translations;
    notifyListeners();
  }

  void toggleSpelling() {
    _spelling = _spelling == KathaSpelling.casual
        ? KathaSpelling.precise
        : KathaSpelling.casual;
    notifyListeners();
  }

  // ---------------------------------------------------------------- words

  /// A tapped word: its picture moves, and it is said.
  void tapWord(KathaToken token) {
    final cue = token.cue;
    if (cue != null) _game.fireCue(cue, glow: true);
    sayWord(token);
  }

  /// Says [token] on its own: its recording if it has one, else the device
  /// voice.
  Future<void> sayWord(KathaToken token) async {
    final recording = story.wordAudioFor(token);
    if (recording != null) {
      try {
        _wordVoice.unlock();
        await (await _wordVoice.start(recording)).done;
        return;
      } on KathaSuperseded {
        return; // another word was tapped
      } catch (_) {
        // A missing or unplayable file falls through to the device voice.
      }
    }
    if (await _hasDeviceVoice) {
      await _speech.speak(token.native, language: story.language);
    }
  }

  // ---------------------------------------------------------------- reporting

  /// A prefilled GitHub issue about the line on screen.
  Uri get mistakeReport {
    final beat = currentBeat?.id ?? 'none';
    final episode = story.scene.id;
    final lang = story.telling.lang;
    return Uri.https('github.com', '/rshrc/Varnamala/issues/new', {
      'title': 'Katha $episode ($lang): mistake in $beat',
      'body':
          'Episode: ${story.scene.series}/$episode\nTelling: $lang\n'
          'Beat: $beat\n\nWhat is wrong, and what should it say?\n',
      'labels': 'katha',
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _stop();
    _voice.dispose();
    _wordVoice.dispose();
    _game.close();
    super.dispose();
  }
}
