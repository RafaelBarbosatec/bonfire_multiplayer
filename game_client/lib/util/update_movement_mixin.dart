import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/move_state.dart';

mixin UpdateMovementMixin on Movement {
  void updateStateMove(MoveState state) {
    // if distance greater than 5 pixel do interpolation of position
    if (position.distanceTo(state.position) > 5) {
      _updatePosition(state.position);
    }
    if (state.direction != null) {
      setZeroVelocity();
      moveFromDirection(state.direction!.toDirection());
    } else {
      lastDirection = state.lastDirection.toDirection();
      stopMove(forceIdle: true);
      _updatePosition(state.position);
    }
  }

  void _updatePosition(Vector2 position) {
    add(
      MoveEffect.to(
        position,
        EffectController(duration: 0.05),
      ),
    );
  }
}
