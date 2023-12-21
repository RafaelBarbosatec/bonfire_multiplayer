import 'package:bonfire/bonfire.dart';
import 'package:shared_events/shared_events.dart';

extension GamePositionExt on GameVector {
  Vector2 toVector2() {
    return Vector2(x, y);
  }
}

extension Vector2Ext on Vector2 {
  GameVector toGamePosition() {
    return GameVector(x: x, y: y);
  }
}

extension JoystickMoveDirectionalExt on JoystickMoveDirectional {
  Direction? toDirection() {
    switch (this) {
      case JoystickMoveDirectional.MOVE_UP:
        return Direction.up;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        return Direction.upLeft;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        return Direction.upRight;
      case JoystickMoveDirectional.MOVE_RIGHT:
        return Direction.right;
      case JoystickMoveDirectional.MOVE_DOWN:
        return Direction.down;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        return Direction.downRight;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        return Direction.downLeft;
      case JoystickMoveDirectional.MOVE_LEFT:
        return Direction.left;
      case JoystickMoveDirectional.IDLE:
        return null;
    }
  }
}
