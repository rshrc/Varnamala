import 'package:words625/views/katha/voice/katha_take.dart';

/// Off the web there is no player: every recording is refused, and the
/// reader falls back to the device voice.
class KathaVoice {
  KathaVoice({int keep = 12});

  Future<KathaTake> start(String url) =>
      Future.error(UnsupportedError('Katha recordings play on the web only'));

  void prefetch(Iterable<String> urls) {}
  void unlock() {}
  void stop() {}
  void dispose() {}
}
