import 'package:bonfire_server/src/mixins/contact_sensor.dart';
import 'package:bonfire_server/src/mixins/movement.dart';
import 'package:shared_events/src/util/game_vector.dart';

mixin BlockMovementOnContact on Movement {
  @override
  void onMove(GameVector newPosition) {
    final lastPosition = position.clone();
    position = newPosition;
    if (this is ContactSensor) {
      if (checkContactWithParents(this as ContactSensor)) {
        onBlockMovement(lastPosition);
      }
    }
  }

  // ignore: use_setters_to_change_properties
  void onBlockMovement(GameVector lastPosition) {
    position = lastPosition;
    stopMove();
  }
}
