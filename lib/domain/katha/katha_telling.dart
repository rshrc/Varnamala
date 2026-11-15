import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/katha/katha_line.dart';
import 'package:words625/domain/katha/katha_scene.dart';
import 'package:words625/domain/katha/katha_string.dart';

part 'katha_telling.freezed.dart';
part 'katha_telling.g.dart';

/// One language's telling of a Katha scene: the words for every beat.
@Freezed(toJson: false)
abstract class KathaTelling with _$KathaTelling {
  const factory KathaTelling({
    /// The scene this tells, such as `s1e01`.
    required String scene,

    /// BCP-47, such as `kn` or `hi`.
    required String lang,

    /// ISO 15924, such as `Knda` or `Deva`.
    required String script,

    /// AI-written and not yet checked by a native speaker. Shown with a beta
    /// label and a way to report a mistake.
    @JsonKey(name: 'review', fromJson: _isBeta) required bool isBeta,

    /// Titles, teases and names, by key (`s1e01.title`, `name.raju`).
    @Default({}) Map<String, KathaString> strings,

    /// The line for each beat, by beat id.
    @JsonKey(name: 'beats') required Map<String, KathaLine> lines,
  }) = _KathaTelling;

  const KathaTelling._();

  factory KathaTelling.fromJson(Map<String, dynamic> json) =>
      _$KathaTellingFromJson(json);

  /// Everything wrong with this telling against [scene], empty when it fits.
  List<String> problemsAgainst(KathaScene scene) => [
    if (this.scene != scene.id) 'telling is for ${this.scene}, not ${scene.id}',
    for (final beat in scene.beats)
      if (!lines.containsKey(beat.id)) 'no line for beat ${beat.id}',
    for (final id in lines.keys)
      if (!scene.beats.any((beat) => beat.id == id))
        'line for unknown beat $id',
    for (final MapEntry(key: id, value: line) in lines.entries) ...[
      for (final token in line.tokens)
        if (token.cue != null && !scene.cues.containsKey(token.cue))
          '$id: unknown cue ${token.cue}',
      if (!line.chunksCoverTokens)
        '$id: chunks do not cover every token once, in order',
    ],
  ];
}

bool _isBeta(Object? review) =>
    review is! Map || review['status'] != 'approved';
