import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:words625/courses/katha/katha_audio.dart';
import 'package:words625/courses/katha/katha_episode.dart';
import 'package:words625/courses/katha/katha_word_index.dart';
import 'package:words625/domain/katha.dart';

/// Loads Katha episodes: the scene and telling from the app bundle (compiled
/// from `stories/` by tool/katha_build.rb), the voices from the language's
/// site.
class KathaRepository {
  KathaRepository({AssetBundle? bundle, KathaWordIndex? wordIndex})
    : _bundle = bundle ?? rootBundle,
      _wordIndex = wordIndex ?? _sharedWordIndex;

  final AssetBundle _bundle;
  final KathaWordIndex _wordIndex;

  /// One word index for the app, so every screen shares its fetches.
  static final _sharedWordIndex = KathaWordIndex();

  static const _root = 'assets/katha';

  /// Loads [episode] of [series] as told in [lang]. Throws a
  /// [FormatException] if the telling does not fit the scene.
  Future<KathaEpisode> load({
    required String series,
    required String episode,
    required String lang,
  }) async {
    final dir = '$_root/$series/$episode';
    final scene = KathaScene.fromJson(await _json('$dir/$episode.scene.json'));
    final telling = KathaTelling.fromJson(
      await _json('$dir/tellings/$lang.telling.json'),
    );
    final problems = telling.problemsAgainst(scene);
    if (problems.isNotEmpty) {
      throw FormatException(
        '$series/$episode/$lang does not fit its scene:\n${problems.join('\n')}',
      );
    }
    final audioBase = KathaAudio.baseFor(lang);
    return KathaEpisode(
      scene: scene,
      telling: telling,
      audioBase: audioBase,
      words: await _wordIndex.at(audioBase),
    );
  }

  Future<Map<String, dynamic>> _json(String path) async =>
      (jsonDecode(await _bundle.loadString(path)) as Map)
          .cast<String, dynamic>();
}
