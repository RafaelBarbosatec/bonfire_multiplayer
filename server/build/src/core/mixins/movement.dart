import 'package:shared_events/shared_events.dart';

import '../positioned_game_component.dart';
import '../util/game_timer.dart';

mixin Movement on PositionedGameComponent {
  static const diaginalReduction = 0.7853981633974483;

  MoveDirectionEnum? direction;
  GameTimer _timer = GameTimer(duration: 1, loop: true);
  double speed = 0;

  void moveFromDirection(double dt, MoveDirectionEnum direction) {
    final newPosition = getNewPosition(dt, direction);
    if (newPosition != position) {
      if (direction != this.direction) {
        this.direction = direction;
        requestUpdate();
      }
      onMove(newPosition);
    }
  }

  GameVector getNewPosition(double dt, MoveDirectionEnum direction) {
    final displacement = dt * speed;
    switch (direction) {
      case MoveDirectionEnum.left:
        return position.copyWith(x: position.x - displacement);
      case MoveDirectionEnum.right:
        return position.copyWith(x: position.x + displacement);
      case MoveDirectionEnum.up:
        return position.copyWith(y: position.y - displacement);
      case MoveDirectionEnum.down:
        return position.copyWith(y: position.y + displacement);
      case MoveDirectionEnum.upLeft:
        return position.copyWith(
          y: position.y - displacement * diaginalReduction,
          x: position.x - displacement * diaginalReduction,
        );
      case MoveDirectionEnum.upRight:
        return position.copyWith(
          y: position.y - displacement * diaginalReduction,
          x: position.x + displacement * diaginalReduction,
        );
      case MoveDirectionEnum.downLeft:
        return position.copyWith(
          y: position.y + displacement * diaginalReduction,
          x: position.x - displacement * diaginalReduction,
        );
      case MoveDirectionEnum.downRight:
        return position.copyWith(
          y: position.y + displacement * diaginalReduction,
          x: position.x + displacement * diaginalReduction,
        );
    }
  }

  // ignore: use_setters_to_change_properties
  void onMove(GameVector newPosition) {
    position = newPosition;
  }

  void stopMove() {
    if (direction != null) {
      direction = null;
      requestUpdate();
    }
  }

  @override
  void onUpdate(double dt) {
    super.onUpdate(dt);
    if (direction != null && _timer.update(dt)) {
      requestUpdate();
    }
  }
}
