import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

extension MovementExt on Movement {
  void followComponent(PositionedGameComponent target, double dt) {
    var direction = (target.position - position).normalized();
    if (direction.x.abs() < 0.2) direction = GameVector(x: 0, y: direction.y);
    if (direction.y.abs() < 0.2) direction = GameVector(x: direction.x, y: 0);
    final moveDirection = MoveDirectionEnum.fromVector(
      direction,
    );
    moveFromDirection(dt, moveDirection);
  }
}
