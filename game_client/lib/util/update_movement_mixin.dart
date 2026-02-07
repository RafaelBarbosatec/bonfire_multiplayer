import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/move_state.dart';

mixin UpdateMovementMixin on Movement {
  void updateStateMove(MoveState state) {
    // Always interpolate to server position to stay in sync
    // Duration matches server update rate (30ms) for smooth movement
    _updatePosition(state.position);
    
    // Update direction for animation purposes without client-side movement
    if (state.direction != null) {
      // Update lastDirection for animation but don't call moveFromDirection
      // This prevents client-side prediction that conflicts with server position
      lastDirection = state.direction!.toDirection();
    } else {
      lastDirection = state.lastDirection.toDirection();
      stopMove(forceIdle: true);
    }
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
