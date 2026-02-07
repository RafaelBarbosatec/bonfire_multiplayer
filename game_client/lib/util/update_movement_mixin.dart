import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/move_state.dart';

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
    
    // Always sync to server position regardless of movement direction
    // MoveEffect smoothly interpolates to the server-provided position
    _updatePosition(state.position);
  }

  void _updatePosition(Vector2 position) {
    // Use 30ms to match server tick rate
    // This ensures smooth interpolation between server updates
    add(
      MoveEffect.to(
        position,
        EffectController(duration: 0.03),
      ),
    );
  }
}
