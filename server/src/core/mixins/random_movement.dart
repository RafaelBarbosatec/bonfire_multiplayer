import 'dart:math';

import 'package:shared_events/shared_events.dart';

import 'block_movement_contact.dart';

mixin RandomMovement on BlockMovementOnContact {
  MoveDirectionEnum? _directionEnum;
  double _timeSinceLastDirectionChange = 0;
  GameVector _initPosition = GameVector.zero();
  void randomMove(double dt) {
    if (_directionEnum == null) {
      _timeSinceLastDirectionChange += dt;
      if (_timeSinceLastDirectionChange >= 2) {
        _initPosition = position.clone();
        _directionEnum = MoveDirectionEnum
            .values[Random().nextInt(MoveDirectionEnum.values.length)];
        _timeSinceLastDirectionChange = 0;
      }
      return;
    }

    if (_directionEnum != null) {
      moveFromDirection(dt, _directionEnum!);
    }
    if (_initPosition.distanceTo(position) > 50) {
      _directionEnum = null;
      stopMove();
      return;
    }
  }

  @override
  void onBlockMovement(GameVector lastPosition) {
    _directionEnum = null;
    super.onBlockMovement(lastPosition);
  }
}
