import 'dart:async' as async;
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:words625/core/logger.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/scene/bubbles/picture_bubble.dart';
import 'package:words625/views/katha/scene/engine/cutout_rig.dart';
import 'package:words625/views/katha/scene/engine/katha_actor.dart';
import 'package:words625/views/katha/scene/engine/katha_palette.dart';
import 'package:words625/views/katha/scene/engine/paper_grain.dart';
import 'package:words625/views/katha/scene/staging/katha_backdrops.dart';
import 'package:words625/views/katha/scene/staging/katha_props.dart';
import 'package:words625/views/katha/scene/staging/katha_staging.dart';

/// One Katha panel, played in Flame.
///
/// **It sleeps when nothing moves.** A Flame game normally ticks at 60fps for
/// as long as it is on screen, and on the web every tick redraws the whole
/// screen - the same cost that made the course path janky on iPhones. So the
/// engine runs only while a move, a glow or a blink is actually in progress
/// ([wake]), and pauses itself the moment the scene is still.
class KathaPanelGame extends FlameGame {
  KathaPanelGame({
    required this.scene,
    required this.panel,
    this.reducedMotion = false,
  }) : super(
         camera: CameraComponent.withFixedResolution(
           width: kathaWorldWidth,
           height: kathaWorldHeight,
         ),
       );

  final KathaScene scene;
  final KathaPanel panel;

  /// Moves become instant poses and idle life stops.
  bool reducedMotion;

  final Map<String, KathaActor> _actors = {};
  PictureBubble? _bubble;

  double _clock = 0;
  double _awakeUntil = 0;

  @override
  Color backgroundColor() => KathaInk.paper;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    for (final piece in kathaBackground(panel.background)) {
      world.add(piece);
      // A backdrop with a life of its own (the crane, the Deepavali lights)
      // answers to cues like any prop.
      if (piece is KathaActor) _register(piece);
    }
    for (final placement in panel.characters) {
      world.addAll(_staging.place(placement));
    }
    for (final prop in panel.props) {
      final piece = _staging.setPieceFor(prop);
      if (piece != null) {
        world.add(piece);
        continue;
      }
      final actor = _staging.actorFor(prop);
      if (actor != null) world.add(_register(actor));
    }
    world.add(PaperGrain());
    wake(0.3);
  }

  /// Set once the reader has moved on to another panel. Timers still
  /// pending in this one (blinks, idle bits) see it and stop rescheduling.
  bool closed = false;

  void close() {
    closed = true;
    pauseEngine();
  }

  /// Keeps the engine running for at least [seconds] more.
  void wake(double seconds) {
    if (closed) return;
    _awakeUntil = math.max(_awakeUntil, _clock + seconds);
    if (paused) resumeEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    if (_clock > _awakeUntil) pauseEngine();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) wake(0.1);
  }

  /// Runs [action] once the scene has loaded. A new panel's first beat
  /// fires its cues straight away, before its characters exist.
  void _whenReady(void Function() action) {
    if (isLoaded) {
      action();
    } else {
      loaded.then((_) {
        if (!closed) action();
      });
    }
  }

  /// Plays a named cue from the scene: `raju.shrug`, `meter.tap`.
  void fireCue(String cueId, {bool glow = false}) {
    if (!isLoaded) return _whenReady(() => fireCue(cueId, glow: glow));
    final cue = scene.cues[cueId];
    final actor = cue == null ? null : _actors[cue.target];
    if (cue == null || actor == null) {
      logger.w('Katha: cue $cueId has nothing to act on in ${panel.id}');
      return;
    }
    if (glow) actor.glow();
    wake(actor.perform(cue.anim, cue.ms / 1000) + 0.05);
    for (final step in cue.then) {
      async.Timer(Duration(milliseconds: step.after), () {
        if (!closed) fireCue(step.cue);
      });
    }
  }

  /// Moves [speaker]'s lips for up to [seconds], and stills everyone else's.
  void talk(String speaker, double seconds) {
    if (!isLoaded) return _whenReady(() => talk(speaker, seconds));
    hush();
    final actor = _actors[speaker];
    if (actor is CutoutRig && !reducedMotion) actor.face.talk(seconds);
  }

  /// Closes every mouth: nobody is speaking.
  void hush() {
    for (final actor in _actors.values) {
      if (actor is CutoutRig) actor.face.hush();
    }
  }

  /// Shows [beat]'s picture bubble over its speaker, or clears it.
  void showBubble(KathaBeat? beat) {
    if (!isLoaded) return _whenReady(() => showBubble(beat));
    _bubble?.removeFromParent();
    _bubble = null;
    final bubble = beat?.bubble;
    final speaker = beat == null ? null : _actors[beat.speaker];
    if (bubble != null && speaker != null) {
      // A small character (the nephew) is a scaled rig: scale its anchor too.
      final anchor =
          speaker.position +
          (speaker.bubbleAnchor..multiply(speaker.scale)) -
          Vector2(0, 4);
      final lean = anchor.x < kathaWorldWidth / 2 ? -1.0 : 1.0;
      _bubble = PictureBubble(bubble: bubble, speaker: anchor, lean: lean)
        ..popIn(reducedMotion: reducedMotion);
      world.add(_bubble!);
    }
    wake(0.3);
  }

  late final _staging = KathaStaging(
    panel: panel,
    register: _register,
    actors: _actors,
  );

  T _register<T extends KathaActor>(T actor) {
    _actors[actor.actorId] = actor;
    return actor;
  }
}
