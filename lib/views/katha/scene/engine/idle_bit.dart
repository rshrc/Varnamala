import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:words625/views/katha/scene/katha_panel_game.dart';

/// A small piece of background life: a tail that wags, a crow that pecks.
///
/// These are what make a picture worth looking at twice, but each one must
/// not keep the engine awake on its own. So they share a clock, like
/// `RestingLoop` does for the course path: every [period] there is one short
/// window in which any of them may play, and outside it the scene is still.
/// Each bit sits out some windows at random, so the street never repeats
/// itself exactly. None of this runs under reduced motion.
abstract class IdleBit extends PositionComponent
    with HasGameReference<KathaPanelGame> {
  IdleBit({
    required this.seconds,
    this.chance = 0.6,
    super.position,
    super.priority = -5,
  });

  static const period = Duration(seconds: 6);

  /// How long one play lasts. Must fit well inside [period].
  final double seconds;

  /// How often it joins a window, 0 to 1.
  final double chance;

  final _random = math.Random();
  async.Timer? _timer;
  double _elapsed = -1;

  /// 0 to 1 through the current play, or 0 when at rest.
  double get t => _elapsed < 0 ? 0 : (_elapsed / seconds).clamp(0.0, 1.0);

  @override
  void onMount() {
    super.onMount();
    _schedule();
  }

  @override
  void onRemove() {
    _timer?.cancel();
    super.onRemove();
  }

  void _schedule() {
    _timer?.cancel();
    if (game.reducedMotion || game.closed) return;
    final ms = period.inMilliseconds;
    final wait = ms - DateTime.now().millisecondsSinceEpoch % ms;
    _timer = async.Timer(Duration(milliseconds: wait), () {
      if (!isMounted) return;
      if (_random.nextDouble() < chance) {
        _elapsed = 0;
        game.wake(seconds + 0.1);
      }
      _schedule();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_elapsed < 0) return;
    _elapsed += dt;
    if (_elapsed >= seconds) _elapsed = -1;
  }
}
