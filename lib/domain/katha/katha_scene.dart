import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/katha/katha_beat.dart';
import 'package:words625/domain/katha/katha_cast.dart';
import 'package:words625/domain/katha/katha_cue.dart';
import 'package:words625/domain/katha/katha_panel.dart';

part 'katha_scene.freezed.dart';
part 'katha_scene.g.dart';

/// The language-neutral half of a Katha episode: what is drawn, what moves,
/// and in what order the story's moments happen.
///
/// A scene holds no human-language text, only ids. Everything a learner reads
/// comes from a `KathaTelling`, one per language, so a scene is drawn and
/// animated once and serves every language. See `stories/README.md`.
@Freezed(toJson: false)
abstract class KathaScene with _$KathaScene {
  const factory KathaScene({
    required String id,
    required String series,
    required List<KathaPanel> panels,

    /// Named scene actions (`raju.shrug`, `meter.tap`): the shared vocabulary
    /// between the art and every telling's words.
    required Map<String, KathaCue> cues,
    required List<KathaBeat> beats,

    /// How each character sounds. Language-neutral: Raju is a gruff older
    /// man in every telling.
    @Default({}) Map<String, KathaCast> cast,
  }) = _KathaScene;

  const KathaScene._();

  factory KathaScene.fromJson(Map<String, dynamic> json) =>
      _$KathaSceneFromJson(json);

  KathaPanel panel(String id) => panels.firstWhere((panel) => panel.id == id);

  List<KathaBeat> beatsIn(String panelId) =>
      beats.where((beat) => beat.panel == panelId).toList();
}
