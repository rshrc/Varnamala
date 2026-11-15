import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/katha/katha_sentence.dart';
import 'package:words625/domain/katha/katha_token.dart';

part 'katha_line.freezed.dart';
part 'katha_line.g.dart';

/// What is said in one beat, word by word.
@Freezed(toJson: false)
abstract class KathaLine with _$KathaLine {
  const factory KathaLine({
    /// The whole sentence in native script, punctuation included. Spoken by
    /// the device voice; never displayed.
    @JsonKey(name: 'n') required String native,

    /// Phrase chunks as token indices, for the spotlight band.
    required List<List<int>> chunks,
    required List<KathaToken> tokens,

    /// A recording of the whole line, relative to the series folder
    /// (`audio/kn/s1e01-b08.mp3`). Null means the device voice reads it.
    String? audio,

    /// The line in natural English (`Priya rolls her eyes.`), shown faintly
    /// beneath it. The token glosses give the words; this gives the sense.
    @JsonKey(name: 'tr') String? translation,
  }) = _KathaLine;

  const KathaLine._();

  factory KathaLine.fromJson(Map<String, dynamic> json) =>
      _$KathaLineFromJson(json);

  /// Whether every token knows when it is spoken in [audio].
  bool get isTimed => tokens.every((token) => token.time != null);

  bool get chunksCoverTokens {
    final flat = chunks.expand((chunk) => chunk).toList();
    return flat.length == tokens.length &&
        flat.indexed.every((entry) => entry.$1 == entry.$2);
  }

  /// The punctuation that follows each token, read off the native sentence.
  ///
  /// Tokens carry no punctuation, so it is recovered from [native]: find each
  /// token's native form in order, and keep whatever marks sit between it and
  /// the next word. A danda becomes a full stop, since the learner reads
  /// English letters.
  List<String> trailingPunctuation() {
    final trailing = List.filled(tokens.length, '');
    var cursor = 0;
    for (final (i, token) in tokens.indexed) {
      final at = native.indexOf(token.native, cursor);
      if (at < 0) continue;
      cursor = at + token.native.length;
      final marks = StringBuffer();
      while (cursor < native.length) {
        final mark = _punctuation[native[cursor]];
        if (mark == null) break;
        marks.write(mark);
        cursor++;
      }
      trailing[i] = marks.toString();
    }
    return trailing;
  }

  /// The line split into its sentences, each with the tokens it covers and
  /// the native text to speak. A reader pauses between them, the way a person
  /// does after "I will come." and before naming the price.
  ///
  /// Falls back to the whole line as one sentence if the native text and the
  /// tokens disagree about where sentences end.
  List<KathaSentence> sentences() {
    final trailing = trailingPunctuation();
    final ranges = <(int, int)>[];
    var start = 0;
    for (var i = 0; i < tokens.length; i++) {
      if (trailing[i].contains(_sentenceEnd) || i == tokens.length - 1) {
        ranges.add((start, i));
        start = i + 1;
      }
    }
    final spoken = native
        .split(_sentenceBreak)
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (spoken.length != ranges.length) {
      return [KathaSentence(first: 0, last: tokens.length - 1, native: native)];
    }
    return [
      for (final (i, (first, last)) in ranges.indexed)
        KathaSentence(first: first, last: last, native: spoken[i]),
    ];
  }

  static final _sentenceEnd = RegExp('[.!?]');
  static final _sentenceBreak = RegExp(r'(?<=[.!?।॥۔؟])\s+');

  /// Native punctuation, as the learner sees it in English letters.
  static const _punctuation = {
    '.': '.',
    ',': ',',
    '!': '!',
    '?': '?',
    ';': ';',
    ':': ':',
    '।': '.', // danda
    '॥': '.', // double danda
    '۔': '.', // Urdu full stop
    '،': ',', // Arabic comma
    '؟': '?', // Arabic question mark
  };
}
