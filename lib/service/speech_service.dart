// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_tts/flutter_tts.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/core/logger.dart';

/// How fast a phrase is read.
enum SpeechPace {
  normal,

  /// For picking a word apart. Slow enough to hear each syllable, not so slow
  /// that the voice starts to drone.
  slow,
}

/// Reads lesson text aloud in the language it belongs to.
///
/// Wraps [FlutterTts] because speaking on the web needs two things the plugin
/// does not do for you: waiting for the browser to publish its voice list, and
/// clearing a wedged utterance before starting the next one.
///
/// The voice is chosen **per language, per utterance**. It used to be chosen
/// once for the whole app - an Indian English voice, whatever the learner was
/// studying - so Kannada, Tamil and Hindi were all read by the same English
/// reader. An English voice applies English vowels to romanized text, which is
/// why everything sounded English no matter which course was open.
class SpeechService {
  SpeechService(this._tts);

  final FlutterTts _tts;
  Future<List<Map<String, String>>>? _voiceList;

  /// The voice already resolved for a locale, so the list is searched once.
  final Map<String, Map<String, String>?> _resolved = {};

  /// What the engine is currently set to, so an unchanged language does not
  /// pay for a voice switch on every tap.
  String? _appliedLocale;
  SpeechPace? _appliedPace;

  Future<void> speak(
    String text, {
    TargetLanguage? language,
    SpeechPace pace = SpeechPace.normal,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      final voice = await _voiceFor(language);
      // Browsers keep an utterance queued after an error or a backgrounded tab,
      // and the plugin refuses to speak while it believes one is playing.
      await _tts.stop();
      await _apply(voice, pace);
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

  /// Whether [language] can actually be read in its own voice on this device.
  ///
  /// Callers use this to decide whether to offer native script at all: reading
  /// Kannada letters with an English voice produces nothing useful.
  Future<bool> hasNativeVoice(TargetLanguage language) async {
    final voice = await _voiceFor(language);
    if (voice == null) return false;
    return language.speechLocaleFallbacks
        .any((locale) => _matches(voice, locale));
  }

  Future<Map<String, String>?> _voiceFor(TargetLanguage? language) async {
    final key = language?.name ?? '_default';
    if (_resolved.containsKey(key)) return _resolved[key];

    final voices = await (_voiceList ??= _loadVoices());
    Map<String, String>? chosen;

    if (language != null) {
      for (final locale in language.speechLocaleFallbacks) {
        chosen = _firstMatching(voices, locale);
        if (chosen != null) break;
      }
    }

    // No native voice on this device. An Indian English reader is the least
    // wrong of what is left: it at least keeps the vowels closer than a US
    // voice does.
    chosen ??= _firstMatching(voices, 'en-in') ??
        _firstMatching(voices, 'en') ??
        (voices.isEmpty ? null : voices.first);

    if (chosen == null && language != null) {
      logger.w('No voice for ${language.name}; the device has none installed');
    }
    _resolved[key] = chosen;
    return chosen;
  }

  bool _matches(Map<String, String> voice, String locale) =>
      (voice['locale'] ?? '')
          .toLowerCase()
          .replaceAll('_', '-')
          .startsWith(locale.toLowerCase());

  Map<String, String>? _firstMatching(
    List<Map<String, String>> voices,
    String locale,
  ) {
    for (final voice in voices) {
      if (_matches(voice, locale)) return voice;
    }
    return null;
  }

  Future<void> _apply(Map<String, String>? voice, SpeechPace pace) async {
    final locale = voice?['locale'];
    if (locale != null && locale != _appliedLocale) {
      await _tts.setVoice(voice!);
      await _tts.setLanguage(locale);
      _appliedLocale = locale;
    }
    if (pace != _appliedPace) {
      // The web and native engines read these numbers on different scales.
      const normal = kIsWeb ? 0.9 : 0.45;
      await _tts.setSpeechRate(
        pace == SpeechPace.slow ? normal * 0.55 : normal,
      );
      await _tts.setPitch(1);
      _appliedPace = pace;
    }
  }

  Future<List<Map<String, String>>> _loadVoices() async {
    if (kIsWeb) {
      // Chrome and Safari populate speechSynthesis.getVoices() asynchronously,
      // so the list is empty for the first moments after load. Setting a voice
      // before then silently does nothing and the utterance stays mute.
      for (var attempt = 0; attempt < 25; attempt++) {
        if ((await _readVoices()).isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    return _readVoices();
  }

  Future<List<Map<String, String>>> _readVoices() async {
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((voice) {
      return {
        'name': '${voice['name']}',
        'locale': '${voice['locale'] ?? voice['lang']}',
      };
    }).toList();
  }
}
