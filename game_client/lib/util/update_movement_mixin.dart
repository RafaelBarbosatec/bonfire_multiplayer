import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/move_state.dart';
import 'package:bonfire_multiplayer/util/smooth_movement_mixin.dart';
import 'package:shared_events/shared_events.dart';

/// Mixin for handling remote player/enemy movement updates from server.
/// Must be used together with SmoothMovementMixin on a component that carries
/// WithDirectionAnimation (SimplePlayer/SimpleEnemy already provide it).
///
/// Bonfire 4.0 moved via `position += velocity*dt` directly (no `translate`
/// hook), so the old "zero velocity + moveFromDirection" trick would make
/// remote entities drift. Instead we NEVER touch velocity here: the sprite
/// animation is driven explicitly through the `directionAnimation` API
/// (the same onPlay* methods Bonfire uses for moving entities), while
/// SmoothMovementMixin fully owns the position.
mixin UpdateMovementMixin on WithDirectionAnimation, SmoothMovementMixin {
  void updateStateMove(MoveState state, {DateTime? serverTime}) {
    final isIdle = state.direction == null;
    final facing = state.direction ?? state.lastDirection;

    // Update facing + sprite animation without touching velocity.
    direction = facing.toDirection();
    if (isIdle) {
      velocity = Vector2.zero();
      _playIdle(state.lastDirection);
    } else {
      _playRun(state.direction!);
    }

    smoothMoveTo(
      state.position,
      snapWhenIdle: isIdle,
      serverTime: serverTime,
    );
  }

  void _playRun(MoveDirectionEnum direction) {
    switch (direction) {
      case MoveDirectionEnum.up:
        directionAnimation.onPlayRunUpAnimation();
        break;
      case MoveDirectionEnum.down:
        directionAnimation.onPlayRunDownAnimation();
        break;
      case MoveDirectionEnum.left:
        directionAnimation.onPlayRunLeftAnimation();
        break;
      case MoveDirectionEnum.right:
        directionAnimation.onPlayRunRightAnimation();
        break;
      case MoveDirectionEnum.upLeft:
        directionAnimation.onPlayRunUpLeftAnimation();
        break;
      case MoveDirectionEnum.upRight:
        directionAnimation.onPlayRunUpRightAnimation();
        break;
      case MoveDirectionEnum.downLeft:
        directionAnimation.onPlayRunDownLeftAnimation();
        break;
      case MoveDirectionEnum.downRight:
        directionAnimation.onPlayRunDownRightAnimation();
        break;
    }
  }

  void _playIdle(MoveDirectionEnum direction) {
    switch (direction) {
      case MoveDirectionEnum.up:
        directionAnimation.onPlayIdleUpAnimation();
        break;
      case MoveDirectionEnum.down:
        directionAnimation.onPlayIdleDownAnimation();
        break;
      case MoveDirectionEnum.left:
        directionAnimation.onPlayIdleLeftAnimation();
        break;
      case MoveDirectionEnum.right:
        directionAnimation.onPlayIdleRightAnimation();
        break;
      case MoveDirectionEnum.upLeft:
        directionAnimation.onPlayIdleUpLeftAnimation();
        break;
      case MoveDirectionEnum.upRight:
        directionAnimation.onPlayIdleUpRightAnimation();
        break;
      case MoveDirectionEnum.downLeft:
        directionAnimation.onPlayIdleDownLeftAnimation();
        break;
      case MoveDirectionEnum.downRight:
        directionAnimation.onPlayIdleDownRightAnimation();
        break;
    }
  }
}
