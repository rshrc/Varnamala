import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/service/speech_service.dart';
import 'package:words625/views/katha/katha_delivery.dart';
import 'package:words625/views/katha/scene/katha_panel_game.dart';
import 'package:words625/views/katha/voice/katha_take.dart';
import 'package:words625/views/katha/voice/katha_voice.dart';

/// Says one line of a story, the way a person would.
///
/// From its [recording] when it has one: the highlight, the cues and the lips
/// follow the word timings, measured against the player's own position, so
/// nothing moves until sound does and a line that stalls to buffer holds its
/// place. Otherwise with the device voice, one sentence at a time, paced by
/// an estimate of how long each word takes.
///
/// A performance runs once. [cancel] stops it at its next step; whoever
/// awaits [run] is released.
class KathaLinePerformance {
  KathaLinePerformance({
    required this.beat,
    required this.line,
    required this.game,
    required this.voice,
    required this.speech,
    required this.hasDeviceVoice,
    required this.onChunk,
    this.recording,
    this.language,
    this.casting,
  });

  final KathaBeat beat;
  final KathaLine line;
  final KathaPanelGame game;
  final KathaVoice voice;
  final SpeechService speech;

  /// Whether the device can read the language natively. Native script handed
  /// to an English voice is worse than silence.
  final Future<bool> hasDeviceVoice;

  /// Called as the highlight moves to each chunk of the line.
  final ValueChanged<int> onChunk;

  /// The line's recording, if it has one.
  final String? recording;
  final TargetLanguage? language;
  final SpeechCasting? casting;

  final List<Timer> _timers = [];
  bool _cancelled = false;

  bool get cancelled => _cancelled;

  /// Says the line. Completes when it has been said, or cancelled.
  Future<void> run() async {
    final recording = this.recording;
    if (recording != null && line.isTimed) {
      try {
        await _playRecording(recording);
        return;
      } on KathaSuperseded {
        return; // a newer line took the voice
      } catch (error) {
        logger.w('Katha: recording failed, using the device voice: $error');
        if (_cancelled) return;
      }
    }
    await _speak();
  }

  void cancel() {
    _cancelled = true;
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  Future<void> _playRecording(String recording) async {
    final take = await voice.start(recording);
    if (_cancelled) return;

    final moments = _Timeline();
    final fired = {...beat.onStart};
    for (final (c, chunk) in line.chunks.indexed) {
      moments.at(line.tokens[chunk.first].time!.start, () => onChunk(c));
      for (final token in chunk.map((i) => line.tokens[i])) {
        final cue = token.cue;
        if (cue != null && fired.add(cue)) {
          moments.at(token.time!.start, () => game.fireCue(cue, glow: true));
        }
      }
    }
    if (!beat.isNarration) {
      for (final sentence in line.sentences()) {
        final from = line.tokens[sentence.first].time!.start;
        final to = line.tokens[sentence.last].time!.end;
        moments
          ..at(from, () => game.talk(beat.speaker, (to - from) / 1000))
          ..at(to, game.hush);
      }
    }

    // A frame's worth of polling: highlights land within 16ms of the word.
    final poll = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_cancelled) moments.playUntil(take.positionMs);
    });
    _timers.add(poll);
    moments.playUntil(take.positionMs);

    // The line is over when the recording says so. The ceiling only covers a
    // browser that never reports the end.
    final ceiling = Duration(milliseconds: line.tokens.last.time!.end + 4000);
    await take.done.timeout(ceiling, onTimeout: () {});
    poll.cancel();
    if (_cancelled) return;
    moments.playRest(); // anything timed past the recording's last sample
    _finish();
  }

  Future<void> _speak() async {
    final voiced = await hasDeviceVoice;
    final tone = kathaTones[beat.delivery] ?? SpeechTone.plain;
    final sentences = line.sentences();
    final fired = {...beat.onStart};

    for (final (s, sentence) in sentences.indexed) {
      if (_cancelled) return;

      var at = 0;
      for (final (c, chunk) in line.chunks.indexed) {
        if (chunk.first < sentence.first || chunk.first > sentence.last) {
          continue;
        }
        _after(at, () => onChunk(c));
        for (final token in chunk.map((i) => line.tokens[i])) {
          final cue = token.cue;
          if (cue != null && fired.add(cue)) {
            _after(at + 120, () => game.fireCue(cue, glow: true));
          }
          at += (_estimatedMs(token) / tone.rate).round();
        }
      }

      if (voiced) {
        // The voice decides how long the lips move; the estimate is only a
        // ceiling in case the engine never reports that it finished.
        final ceiling = Duration(milliseconds: at * 3 + 3000);
        if (!beat.isNarration) {
          game.talk(beat.speaker, ceiling.inMilliseconds / 1000);
        }
        await speech
            .speak(
              sentence.native,
              language: language,
              tone: tone,
              casting: casting,
              waitUntilSpoken: true,
            )
            .timeout(ceiling, onTimeout: () {});
      } else {
        if (!beat.isNarration) game.talk(beat.speaker, at / 1000);
        await Future<void>.delayed(Duration(milliseconds: at));
      }
      if (_cancelled) return;
      game.hush();
      if (s < sentences.length - 1) {
        await Future<void>.delayed(kathaSentencePause);
      }
    }
    if (_cancelled) return;
    _finish();
  }

  void _finish() {
    game.hush();
    for (final cue in beat.onEnd) {
      game.fireCue(cue);
    }
  }

  void _after(int ms, VoidCallback action) => _timers.add(
    Timer(Duration(milliseconds: ms), () {
      if (!_cancelled) action();
    }),
  );

  /// Rough reading time for a word, for a line with no recording.
  static int _estimatedMs(KathaToken token) =>
      (240 + 46 * token.roman.length).clamp(380, 900);
}

/// Things to do at moments in a recording, done in order as the recording
/// reaches them. Moments at the same time keep the order they were added.
class _Timeline {
  final List<({int ms, int order, VoidCallback action})> _moments = [];
  int _next = 0;
  bool _sorted = false;

  void at(int ms, VoidCallback action) =>
      _moments.add((ms: ms, order: _moments.length, action: action));

  /// Does everything due by [positionMs] that has not been done yet.
  void playUntil(int positionMs) {
    if (!_sorted) {
      _moments.sort(
        (a, b) => a.ms != b.ms ? a.ms.compareTo(b.ms) : a.order - b.order,
      );
      _sorted = true;
    }
    while (_next < _moments.length && _moments[_next].ms <= positionMs) {
      _moments[_next++].action();
    }
  }

  void playRest() => playUntil(1 << 30);
}
