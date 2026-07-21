// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_tts/flutter_tts.dart';

// Project imports:
import 'package:words625/core/logger.dart';

/// Reads lesson sentences aloud.
///
/// Wraps [FlutterTts] because speaking on the web needs two things the plugin
/// does not do for you: waiting for the browser to publish its voice list, and
/// clearing a wedged utterance before starting the next one.
class SpeechService {
  SpeechService(this._tts);

  final FlutterTts _tts;
  Future<void>? _preparation;

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await (_preparation ??= _prepare());
      // Browsers keep an utterance queued after an error or a backgrounded tab,
      // and the plugin refuses to speak while it believes one is playing.
      await _tts.stop();
      await _tts.speak(text);
    } catch (error, stackTrace) {
      // A silent button is bad; a crashed lesson is worse.
      logger.e('Could not speak', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing was playing.
    }
  }

  Future<void> _prepare() async {
    if (kIsWeb) {
      // Chrome and Safari populate speechSynthesis.getVoices() asynchronously,
      // so the list is empty for the first moments after load. Setting a voice
      // before then silently does nothing and the utterance stays mute.
      for (var attempt = 0; attempt < 25; attempt++) {
        if ((await _voices()).isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    await _selectVoice();
  }

  Future<List<Map<String, String>>> _voices() async {
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((voice) {
      return {
        'name': '${voice['name']}',
        'locale': '${voice['locale'] ?? voice['lang']}',
      };
    }).toList();
  }

  /// Lessons are written in romanized Indic script, which an Indian English
  /// voice pronounces far more faithfully than a US one — "vanakkam" as
  /// something like the word, rather than as American vowels.
  Future<void> _selectVoice() async {
    final voices = await _voices();
    if (voices.isEmpty) {
      await _tts.setLanguage('en-IN');
      return;
    }

    bool localed(Map<String, String> voice, String prefix) =>
        voice['locale']!.toLowerCase().replaceAll('_', '-').startsWith(prefix);

    final chosen = voices.firstWhere(
      (voice) => localed(voice, 'en-in'),
      orElse: () => voices.firstWhere(
        (voice) => localed(voice, 'en'),
        orElse: () => voices.first,
      ),
    );

    await _tts.setVoice(chosen);
    await _tts.setLanguage(chosen['locale']!);
    await _tts.setSpeechRate(kIsWeb ? 0.9 : 0.45);
    await _tts.setPitch(1);
  }
}
