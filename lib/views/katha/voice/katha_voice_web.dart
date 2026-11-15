import 'dart:async';
import 'dart:collection';
import 'dart:js_interop';

import 'package:words625/views/katha/voice/katha_take.dart';

/// Plays Katha's recordings in the browser, without gaps and in sync.
///
/// - **Fetched ahead.** [prefetch] downloads the next lines into memory while
///   the current one plays, so starting a line never waits on the network.
/// - **Timed by the player.** A [KathaTake] reports the audio element's own
///   position, so word highlights cannot run ahead of a line that is still
///   buffering, or lag one that started early.
/// - **One element, unlocked once.** iPhone Safari lets an audio element play
///   on its own only after a tap has played it; [unlock] does that on the
///   first tap, and every later line reuses the same element.
class KathaVoice {
  KathaVoice({this.keep = 12});

  /// How many fetched recordings to hold in memory: a line is ~20 KB.
  final int keep;

  final _Audio _audio = _Audio();
  final LinkedHashMap<String, Future<String?>> _blobs = LinkedHashMap();
  bool _unlocked = false;

  /// Bumped by every [start] and [stop]: a recording that finds it changed
  /// has been replaced, and steps aside.
  int _generation = 0;
  Completer<void>? _started;
  Completer<void>? _ended;

  /// Plays [url] and returns once sound has actually started. Throws if it
  /// cannot play, or if another [start] or a [stop] replaced it first.
  Future<KathaTake> start(String url) async {
    stop();
    final generation = _generation;
    final source = await _fetched(url) ?? url;
    if (generation != _generation) throw const KathaSuperseded();

    final started = _started = Completer<void>();
    final ended = _ended = Completer<void>();
    // Stopped before playing errors [started]; nobody may be awaiting it yet.
    started.future.catchError((_) {});
    late final JSFunction onPlaying, onEnded, onError;
    void detach() {
      _audio.removeEventListener('playing', onPlaying);
      _audio.removeEventListener('ended', onEnded);
      _audio.removeEventListener('error', onError);
    }

    onPlaying = ((JSAny? _) {
      if (!started.isCompleted) started.complete();
    }).toJS;
    onEnded = ((JSAny? _) {
      detach();
      if (!ended.isCompleted) ended.complete();
    }).toJS;
    onError = ((JSAny? _) {
      detach();
      if (!started.isCompleted) {
        started.completeError(StateError('could not play $url'));
      }
      if (!ended.isCompleted) ended.complete();
    }).toJS;
    _audio
      ..addEventListener('playing', onPlaying)
      ..addEventListener('ended', onEnded)
      ..addEventListener('error', onError)
      ..src = source;
    try {
      await _audio.play().toDart;
      await started.future.timeout(const Duration(seconds: 8));
    } catch (_) {
      detach();
      if (!ended.isCompleted) ended.complete();
      if (generation != _generation) throw const KathaSuperseded();
      rethrow;
    }
    if (generation != _generation) throw const KathaSuperseded();
    return KathaTake(
      position: () => (_audio.currentTime * 1000).round(),
      done: ended.future,
    );
  }

  /// Starts downloading [urls] now, so they play the moment they are asked
  /// for. Already-fetched ones are left alone.
  void prefetch(Iterable<String> urls) {
    for (final url in urls) {
      _fetched(url);
    }
  }

  /// Lets later recordings start without a tap. Call it from a tap, before
  /// any await.
  void unlock() {
    if (_unlocked) return;
    _unlocked = true;
    final generation = _generation;
    _audio.src = _silence;
    _audio.play().toDart.then((_) {
      // Only pause the silence: a line may already have taken over.
      if (generation == _generation) _audio.pause();
    }, onError: (_) {});
  }

  /// Stops the current recording; whoever awaits its start or end is
  /// released.
  void stop() {
    _generation++;
    _audio.pause();
    final started = _started;
    if (started != null && !started.isCompleted) {
      started.completeError(const KathaSuperseded());
    }
    final ended = _ended;
    if (ended != null && !ended.isCompleted) ended.complete();
    _started = _ended = null;
  }

  void dispose() {
    stop();

    for (final blob in _blobs.values) {
      blob.then((url) {
        if (url != null) _revokeObjectUrl(url);
      });
    }
    _blobs.clear();
  }

  /// [url] downloaded into memory, as a blob: address; null if the download
  /// failed, in which case the player streams [url] directly.
  Future<String?> _fetched(String url) {
    final known = _blobs.remove(url);
    if (known != null) {
      _blobs[url] = known; // most recently used goes to the back
      return known;
    }
    final blob = _download(url);
    _blobs[url] = blob;
    while (_blobs.length > keep) {
      final oldest = _blobs.keys.first;
      _blobs.remove(oldest)!.then((old) {
        if (old != null) _revokeObjectUrl(old);
      });
    }
    return blob;
  }

  static Future<String?> _download(String url) async {
    try {
      final response = await _fetch(url).toDart;
      if (!response.ok) return null;
      return _createObjectUrl(await response.blob().toDart);
    } catch (_) {
      return null;
    }
  }

  /// A few milliseconds of silence, played once to unlock the element.
  static const _silence =
      'data:audio/wav;base64,UklGRigAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQQAAACAgICA';
}

@JS('Audio')
extension type _Audio._(JSObject _) implements JSObject {
  external factory _Audio();
  external set src(String value);
  external double get currentTime;
  external set currentTime(double value);
  external JSPromise<JSAny?> play();
  external void pause();
  external void addEventListener(String type, JSFunction listener);
  external void removeEventListener(String type, JSFunction listener);
}

extension type _Response._(JSObject _) implements JSObject {
  external bool get ok;
  external JSPromise<JSObject> blob();
}

@JS('fetch')
external JSPromise<_Response> _fetch(String url);

@JS('URL.createObjectURL')
external String _createObjectUrl(JSObject blob);

@JS('URL.revokeObjectURL')
external void _revokeObjectUrl(String url);
