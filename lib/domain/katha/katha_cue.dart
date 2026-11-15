import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:words625/domain/katha/katha_cue_step.dart';

part 'katha_cue.freezed.dart';
part 'katha_cue.g.dart';

/// A named scene action: someone (or something) makes a move.
@Freezed(toJson: false)
abstract class KathaCue with _$KathaCue {
  const factory KathaCue({
    /// The character or prop that moves.
    required String target,

    /// A named move from the shared move library: `wave`, `nod`, `shrug` ...
    required String anim,

    /// How long the move takes, in milliseconds.
    required int ms,

    /// A sound played with it, such as `sfx.thud`.
    String? sfx,

    /// Cues that follow this one, each so many milliseconds after it: a
    /// bowler's run-up, then the ball, the swing, the stumps, the cheer.
    @Default([]) List<KathaCueStep> then,
  }) = _KathaCue;

  factory KathaCue.fromJson(Map<String, dynamic> json) =>
      _$KathaCueFromJson(json);
}
