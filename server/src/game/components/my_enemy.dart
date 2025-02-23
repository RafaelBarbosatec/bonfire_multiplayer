import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import 'player.dart';

class MyEnemy extends GameNpc
    with Vision<Player>, Collision, BlockMovementOnCollision, RandomMovement {
  MyEnemy({required super.state}) {
    setupCollision(
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
      followComponent(_targetPlayer!, dt);
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
