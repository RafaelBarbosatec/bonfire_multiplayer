import 'dart:math';

import 'package:shared_events/shared_events.dart';

import 'block_movement_contact.dart';

mixin RandomMovement on BlockMovementOnContact {
  MoveDirectionEnum? _directionEnum;
  void randomMove(double dt) {
    _directionEnum ??= MoveDirectionEnum
        .values[Random().nextInt(MoveDirectionEnum.values.length)];
    moveFromDirection(dt, _directionEnum!);
  }

  @override
  void onBlockMovement(GameVector lastPosition) {
    _directionEnum = null;
    print('onBlockMovement');
    super.onBlockMovement(lastPosition);
  }
}
