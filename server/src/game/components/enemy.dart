import 'package:shared_events/shared_events.dart';

import '../../core/game_npc.dart';
import '../../core/geometry/rectangle.dart';
import '../../core/mixins/block_movement_contact.dart';
import '../../core/mixins/contact_sensor.dart';
import '../../core/mixins/random_movement.dart';
import '../../core/mixins/vision.dart';

class Enemy extends GameNpc
    with Vision, ContactSensor, BlockMovementOnContact, RandomMovement {
  Enemy({required super.state}) {
    setupGameSensor(
      RectangleShape(
        GameVector.all(16),
        position: GameVector(x: 8, y: 16),
      ),
    );
  }

  @override
  void onUpdate(double dt) {
    randomMove(dt);
    super.onUpdate(dt);
  }
}
