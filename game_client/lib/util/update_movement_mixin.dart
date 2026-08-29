import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/move_state.dart';
import 'package:bonfire_multiplayer/util/smooth_movement_mixin.dart';

/// Mixin for handling remote player/enemy movement updates from server.
/// Must be used together with SmoothMovementMixin.
mixin UpdateMovementMixin on Movement, SmoothMovementMixin {
  void updateStateMove(MoveState state) {
    final isIdle = state.direction == null;

    // Update animation state
    if (!isIdle) {
      // Trigger walking animation WITHOUT actual movement:
      // translate() is a no-op on remote components, so the engine never
      // moves them — position is fully controlled by SmoothMovementMixin
      // (single source of truth, no jitter).
      setZeroVelocity();
      moveFromDirection(state.direction!.toDirection());
    } else {
      // Show idle animation facing last direction
      lastDirection = state.lastDirection.toDirection();
      stopMove(forceIdle: true);
    }

    // Sync position to server
    // When idle: snap to exact position for precise sync
    // When moving: interpolate smoothly
    smoothMoveTo(state.position, snapWhenIdle: isIdle);
  }
}
