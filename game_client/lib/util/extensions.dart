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
  MoveDirectionEnum? toMoveDirection() {
    switch (this) {
      case JoystickMoveDirectional.MOVE_UP:
        return MoveDirectionEnum.up;
      case JoystickMoveDirectional.MOVE_RIGHT:
        return MoveDirectionEnum.right;
      case JoystickMoveDirectional.MOVE_DOWN:
        return MoveDirectionEnum.down;
      case JoystickMoveDirectional.MOVE_LEFT:
        return MoveDirectionEnum.left;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
      case JoystickMoveDirectional.IDLE:
        return null;
    }
  }
}

extension MoveDirectionEnumExt on MoveDirectionEnum {
  Direction toDirection() {
    switch (this) {
      case MoveDirectionEnum.up:
        return Direction.up;
      case MoveDirectionEnum.right:
        return Direction.right;
      case MoveDirectionEnum.down:
        return Direction.down;
      case MoveDirectionEnum.left:
        return Direction.left;
    }
  }
}
