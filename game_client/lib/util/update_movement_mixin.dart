import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/move_state.dart';
import 'package:bonfire_multiplayer/util/smooth_movement_mixin.dart';
import 'package:flutter/material.dart';

mixin UpdateMovementMixin on Movement {
  void updateStateMove(MoveState state) {
    // Update direction and trigger animations using Bonfire's movement API
    if (state.direction != null) {
      // Call moveFromDirection to trigger walking animation
      // Note: The translate() override in MyRemotePlayer prevents actual movement
      // This allows animations to play while position is controlled by server
      setZeroVelocity();
      moveFromDirection(state.direction!.toDirection());
    } else {
      // Stop movement and show idle animation
      lastDirection = state.lastDirection.toDirection();
      stopMove(forceIdle: true);
    }

    // Always sync to server position using improved interpolation
    _updatePositionSmooth(state.position);
  }

  void _updatePositionSmooth(Vector2 serverPosition) {
    // Check if this component uses SmoothMovementMixin
    if (this is SmoothMovementMixin) {
      (this as SmoothMovementMixin).smoothMoveTo(serverPosition);
    } else {
      // Fallback to MoveEffect for components without SmoothMovementMixin
      final distance = position.distanceTo(serverPosition);

      // For very large distances (teleportation), snap immediately
      if (distance > 64.0) {
        position.setFrom(serverPosition);
      } else {
        // Smooth interpolation for normal movement
        add(
          MoveEffect.to(
            serverPosition,
            EffectController(duration: 0.06, curve: Curves.easeOut),
          ),
        );
      }
    }
  }
}
