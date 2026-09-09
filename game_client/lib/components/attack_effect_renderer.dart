import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:shared_events/shared_events.dart';

/// Renders attack effects broadcast by the server ([AttackEffectEvent]).
///
/// The server is authoritative about *which* effect plays and *where*, so the
/// client keeps a registry keyed by [AttackEffectEvent.effectId]. An id the
/// client doesn't know (newer server, older client) is **silently ignored** —
/// nothing is rendered, matching the "unknown effect → show nothing" rule.
typedef AttackEffectSpawner =
    void Function(BonfireGameInterface game, AttackEffectEvent event);

final Map<String, AttackEffectSpawner> _spawners = {
  AttackEffectId.meleeSlash: _spawnMeleeSlash,
};

/// Plays the effect identified by [event.effectId] at [event.position].
/// Unknown ids render nothing.
void renderAttackEffect(BonfireGameInterface game, AttackEffectEvent event) {
  final spawner = _spawners[event.effectId];
  if (spawner == null) return;
  spawner(game, event);
}

// --- Built-in effects ------------------------------------------------------

/// Melee slash: the white arc sprite is drawn facing [event.direction] and
/// auto-removed when the animation finishes (3 frames × 0.1s).
Future<SpriteAnimation>? _meleeSlashAnimation;

Future<SpriteAnimation> _loadMeleeSlashAnimation() {
  // The sprite sheet is 48x16 → 3 frames of 16px (the canonical bonfire
  // example declares 6, but the last 3 would fall outside the texture).
  return _meleeSlashAnimation ??= SpriteAnimation.load(
    'attack_effect_right.png',
    SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2.all(16),
    ),
  );
}

void _spawnMeleeSlash(BonfireGameInterface game, AttackEffectEvent event) {
  final direction = event.direction?.toDirection() ?? Direction.right;
  game.add(
    AnimatedGameObject(
      animation: _loadMeleeSlashAnimation(),
      position: event.position.toVector2(),
      size: Vector2.all(32), // matches the 32px player/enemy sprites
      angle: direction.toRadians(),
      anchor: Anchor.center,
      loop: false,
      renderAboveComponents: true,
    ),
  );
}
