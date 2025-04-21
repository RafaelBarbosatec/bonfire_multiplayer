import 'package:shared_events/shared_events.dart';

import '../../core/game_npc.dart';
import '../../core/geometry/rectangle.dart';
import '../../core/mixins/block_movement_contact.dart';
import '../../core/mixins/contact_sensor.dart';
import '../../core/mixins/random_movement.dart';
import '../../core/mixins/vision.dart';
import 'player.dart';

class MyEnemy extends GameNpc
    with Vision<Player>, ContactSensor, BlockMovementOnContact, RandomMovement {
  MyEnemy({required super.state}) {
    setupGameSensor(
      RectangleShape(
        GameVector.all(16),
        position: GameVector(x: 8, y: 16),
      ),
    );
  }
  Player? _targetPlayer;

  bool exitVision = false;

  @override
  void onUpdate(double dt) {
    exitVision = _targetPlayer == null;
    _targetPlayer = null;
    super.onUpdate(dt);

    if (_targetPlayer != null) {
      var direction = (_targetPlayer!.position - position).normalized();
      if (direction.x.abs() < 0.2) direction = GameVector(x: 0, y: direction.y);
      if (direction.y.abs() < 0.2) direction = GameVector(x: direction.x, y: 0);
      final moveDirection = MoveDirectionEnum.fromVector(
        direction,
      );
      moveFromDirection(dt, moveDirection);
    } else {
      randomMove(dt);
    }
  }

  @override
  void onFieldOfVision(Iterable<Player> components) {
    _targetPlayer = components.first;
  }

  @override
  double get radiusVision => size.x * 2;
}
