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

/// How a line is delivered: the nearest a device voice gets to acting.
///
/// Multipliers on the normal voice, so 1 everywhere is plain speech. A raised
/// pitch and a quicker rate read as surprise; lower and slower as weariness.
class SpeechTone {
  const SpeechTone({this.pitch = 1, this.rate = 1, this.volume = 1});

  static const plain = SpeechTone();

  final double pitch;
  final double rate;
  final double volume;

  @override
  bool operator ==(Object other) =>
      other is SpeechTone &&
      other.pitch == pitch &&
      other.rate == rate &&
      other.volume == volume;

  @override
  int get hashCode => Object.hash(pitch, rate, volume);
}

/// Who is speaking, for picking and shaping a voice: a story character
/// rather than the lesson reader.
///
/// [variant] spreads characters across the device's voices when it has more
/// than one for the language, so two people do not share a voice.
class SpeechCasting {
  const SpeechCasting({
    required this.male,
    this.variant = 0,
    this.pitch = 1,
    this.rate = 1,
  });

  final bool male;
  final int variant;
  final double pitch;
  final double rate;
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

  /// What the engine is currently set to, so an unchanged voice does not pay
  /// for a switch on every tap.
  String? _appliedVoice;
  SpeechPace? _appliedPace;
  SpeechTone? _appliedTone;

  Future<void> speak(
    String text, {
    TargetLanguage? language,
    SpeechPace pace = SpeechPace.normal,
    SpeechTone tone = SpeechTone.plain,
    SpeechCasting? casting,
    bool waitUntilSpoken = false,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      final voice = casting == null
          ? await _voiceFor(language)
          : await _castVoice(language, casting);
      if (casting != null) tone = _shape(tone, voice, casting);
      // Browsers keep an utterance queued after an error or a backgrounded tab,
      // and the plugin refuses to speak while it believes one is playing.
      await _tts.stop();
      await _apply(voice, pace, tone);
      // When asked, the future completes as the voice falls silent, so a
      // caller can leave a pause before the next sentence.
      await _tts.awaitSpeakCompletion(waitUntilSpoken);
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

/// A voice for [casting]: one of the right gender when the device has it,
  /// otherwise any native voice, spread across characters by
  /// [SpeechCasting.variant] so different people get different voices where
  /// there is more than one to go round.
  Future<Map<String, String>?> _castVoice(
    TargetLanguage? language,
    SpeechCasting casting,
  ) async {
    final key = '${language?.name}|${casting.male}|${casting.variant}';
    if (_resolved.containsKey(key)) return _resolved[key];
    final voices = await (_voiceList ??= _loadVoices());
    var native = <Map<String, String>>[];
    for (final locale in language?.speechLocaleFallbacks ?? const <String>[]) {
      native = [for (final v in voices) if (_matches(v, locale)) v];
      if (native.isNotEmpty) break;
    }
    final wanted = casting.male ? 'male' : 'female';
    final gendered = [for (final v in native) if (_genderOf(v) == wanted) v];
    final pool = gendered.isNotEmpty ? gendered : native;
    final chosen = pool.isEmpty
        ? await _voiceFor(language)
        : pool[casting.variant % pool.length];
    _resolved[key] = chosen;
    return chosen;
  }

  /// [tone] adjusted for who is speaking.
  ///
  /// Most phones and desktops ship one voice per Indian language, and it is
  /// usually a woman's - Soumya for Kannada, Lekha for Hindi. A man given that
  /// voice unchanged sounds like a woman, so when no male voice exists his
  /// lines are pitched well down. A voice whose gender the device does not
  /// report is treated as female, since that is what it nearly always is.
  SpeechTone _shape(
    SpeechTone tone,
    Map<String, String>? voice,
    SpeechCasting casting,
  ) {
    final gender = voice == null ? null : _genderOf(voice);
    var pitch = tone.pitch * casting.pitch;
    if (casting.male && gender != 'male') pitch *= 0.64;
    if (!casting.male && gender == 'male') pitch *= 1.3;
    return SpeechTone(
      // Engines accept roughly half to double; outside that some refuse.
      pitch: pitch.clamp(0.5, 2.0),
      rate: tone.rate * casting.rate,
      volume: tone.volume,
    );
  }

  /// `male`, `female`, or null when the device does not say. iOS reports it;
  /// the web does not, so a few well-known system voices are named here.
  static String? _genderOf(Map<String, String> voice) {
    final reported = voice['gender']?.toLowerCase();
    if (reported == 'male' || reported == 'female') return reported;
    final name = (voice['name'] ?? '').toLowerCase();
    if (name.contains('female')) return 'female';
    if (name.contains('male')) return 'male';
    for (final known in _maleVoices) {
      if (name.contains(known)) return 'male';
    }
    for (final known in _femaleVoices) {
      if (name.contains(known)) return 'female';
    }
    return null;
  }

  static const _femaleVoices = ['soumya', 'lekha', 'veena', 'kanya', 'tara', 'kiyara'];
  static const _maleVoices = ['rishi', 'aman', 'neel'];

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

  Future<void> _apply(
    Map<String, String>? voice,
    SpeechPace pace,
    SpeechTone tone,
  ) async {
    final locale = voice?['locale'];
    final id = voice == null ? null : '${voice['name']}|$locale';
    if (locale != null && id != _appliedVoice) {
      await _tts.setVoice({'name': voice!['name']!, 'locale': locale});
      await _tts.setLanguage(locale);
      _appliedVoice = id;
    }
    if (pace != _appliedPace || tone != _appliedTone) {
      // The web and native engines read these numbers on different scales.
      const normal = kIsWeb ? 0.9 : 0.45;
      await _tts.setSpeechRate(
        (pace == SpeechPace.slow ? normal * 0.55 : normal) * tone.rate,
      );
      await _tts.setPitch(tone.pitch);
      await _tts.setVolume(tone.volume);
      _appliedPace = pace;
      _appliedTone = tone;
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
        if (voice['gender'] != null) 'gender': '${voice['gender']}',
        'locale': '${voice['locale'] ?? voice['lang']}',
      };
    }).toList();
  }
}
