import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/core/enums.dart';
import 'package:words625/courses/katha/katha_audio.dart';
import 'package:words625/courses/katha/katha_languages.dart';
import 'package:words625/domain/katha.dart';

part 'katha_episode.freezed.dart';

/// A scene, the telling it is being read in, and where its voices are.
@freezed
abstract class KathaEpisode with _$KathaEpisode {
  const factory KathaEpisode({
    required KathaScene scene,
    required KathaTelling telling,

    /// The site serving this telling's recordings, ending in a slash.
    @Default('') String audioBase,

    /// Recorded words: a word as written in native script, punctuation
    /// stripped, to its recording's address.
    @Default({}) Map<String, String> words,
  }) = _KathaEpisode;

  const KathaEpisode._();

  /// [line]'s recording as the language's site names it (`s1e01-b05.mp3`):
  /// the telling's `audio/<lang>/` prefix dropped, since each language has
  /// its own site.
  String? recordingFile(KathaLine line) {
    final audio = line.audio;
    if (audio == null) return null;
    final prefix = 'audio/${telling.lang}/';
    return audio.startsWith(prefix) ? audio.substring(prefix.length) : audio;
  }

  /// The address of [line]'s recording, if it has one.
  String? audioFor(KathaLine line) {
    final file = recordingFile(line);
    return file == null ? null : '$audioBase$file';
  }

  /// The address of a recording of [token] said on its own, if there is one.
  String? wordAudioFor(KathaToken token) =>
      words[KathaAudio.wordKey(token.native)];

  /// The app language this telling is in, for picking a speech voice.
  TargetLanguage? get language => KathaLanguages.byCode[telling.lang];
}
