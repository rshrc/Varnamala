import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/katha/katha_bubble.dart';

part 'katha_beat.freezed.dart';
part 'katha_beat.g.dart';

/// One moment of the story: someone says a line, and things happen.
@Freezed(toJson: false)
abstract class KathaBeat with _$KathaBeat {
  const factory KathaBeat({
    required String id,

    /// The panel it happens in.
    required String panel,

    /// A character id, or `narrator`.
    required String speaker,

    /// Cues fired when the line starts, and when it ends.
    @JsonKey(name: 'on_start') @Default([]) List<String> onStart,
    @JsonKey(name: 'on_end') @Default([]) List<String> onEnd,
    @Default(false) bool cliffhanger,

    /// What the speaker "says" in picture mode, when the text is hidden.
    KathaBubble? bubble,

    /// How the line is said (`shocked`, `sly`, `weary`), which is the same in
    /// every language, so it lives here and not in a telling. The reader maps
    /// it to a pitch and pace for the device voice.
    String? delivery,

    /// Direction for a recorded voice: ElevenLabs v3 audio tags (`whispers`,
    /// `sighs`), one for the whole line or one per sentence. Sent with the
    /// text when recording, never shown. Without them, [delivery] decides.
    @Default([]) List<String> tags,
  }) = _KathaBeat;

  const KathaBeat._();

  factory KathaBeat.fromJson(Map<String, dynamic> json) =>
      _$KathaBeatFromJson(json);

  bool get isNarration => speaker == 'narrator';
}
