import 'package:bonfire/bonfire.dart';
import 'package:shared_events/shared_events.dart';

/// Input event for client-side prediction buffer
class InputEvent {
  final int id;
  final MoveDirectionEnum? direction;
  final DateTime timestamp;
  final Vector2 position;

  InputEvent({
    required this.id,
    required this.direction,
    required this.timestamp,
    required this.position,
  });

  /// Calculate predicted position based on time elapsed and speed
  Vector2 getPredictedPosition(double speed, double deltaTime) {
    if (direction == null) return position.clone();

    final Vector2 movement;
    switch (direction!) {
      case MoveDirectionEnum.up:
        movement = Vector2(0, -speed * deltaTime);
        break;
      case MoveDirectionEnum.down:
        movement = Vector2(0, speed * deltaTime);
        break;
      case MoveDirectionEnum.left:
        movement = Vector2(-speed * deltaTime, 0);
        break;
      case MoveDirectionEnum.right:
        movement = Vector2(speed * deltaTime, 0);
        break;
      default:
        movement = Vector2.zero();
        break;
    }

    return position + movement;
  }
}
