import 'dart:async';

import 'package:flutter/animation.dart';

/// Plays an ambient animation in bursts on a shared clock, and holds still in
/// between.
///
/// On the web there is no raster cache: any frame that paints anything redraws
/// the whole screen. An animation on `repeat()` therefore keeps the screen at
/// 60fps for as long as it is visible. That is free on a laptop, but on an
/// iPhone every one of those frames is a full-screen WebGL redraw. The phone
/// heats up, throttles, and the jank surfaces everywhere else, not just on the
/// screen doing the animating.
///
/// Every loop starts its burst at the same multiple of [period] since the
/// epoch, so a path full of shining nodes and a bobbing START flag animate
/// *together* and the screen is idle for the rest of the period, rather than
/// each loop keeping it awake at a different moment.
class RestingLoop {
  RestingLoop(this.controller, {this.period = defaultPeriod})
      : assert(
          controller.duration != null && controller.duration! < period,
          'The burst has to fit inside the period, or there is no rest.',
        );

  static const Duration defaultPeriod = Duration(seconds: 6);

  final AnimationController controller;
  final Duration period;

  Timer? _timer;
  bool _running = false;

  /// Starts playing, joining the current burst part-way if one is under way.
  void start() {
    if (_running) return;
    _running = true;
    final burst = controller.duration!.inMilliseconds;
    final into = DateTime.now().millisecondsSinceEpoch % period.inMilliseconds;
    if (into < burst) controller.forward(from: into / burst);
    _scheduleNext();
  }

  /// Stops at rest, for reduced motion: the controller is left at 0.
  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    controller
      ..stop()
      ..value = 0;
  }

  /// Cancels the timer. Call from `dispose` before disposing the controller.
  void dispose() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleNext() {
    final ms = period.inMilliseconds;
    final wait = ms - DateTime.now().millisecondsSinceEpoch % ms;
    _timer = Timer(Duration(milliseconds: wait), () {
      if (!_running) return;
      controller.forward(from: 0);
      _scheduleNext();
    });
  }
}
