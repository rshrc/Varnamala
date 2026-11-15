/// One recording, playing: how far it has got, and when it is over.
class KathaTake {
  KathaTake({required int Function() position, required this.done})
    : _position = position; // ignore: prefer_initializing_formals

  final int Function() _position;

  /// Milliseconds into the recording, read from the player itself, so it
  /// stands still while the audio buffers and moves only while sound plays.
  int get positionMs => _position();

  /// Completes when the recording ends, fails, or is stopped.
  final Future<void> done;
}

/// A recording that was stopped, or replaced by another, before it began.
class KathaSuperseded implements Exception {
  const KathaSuperseded();

  @override
  String toString() => 'KathaSuperseded';
}
