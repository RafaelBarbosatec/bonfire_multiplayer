import 'dart:math';

import 'package:shared_events/shared_events.dart';

import '../util/game_timer.dart';
import 'block_movement_contact.dart';

mixin RandomMovement on BlockMovementOnContact {
  GameVector _initPosition = GameVector.zero();

  GameTimer _timer = GameTimer(duration: 2);
  double _maxDistance = 50;

  void setupRandomMovement({
    double? durationIdle,
    double maxDistance = 50,
  }) {
    if (durationIdle != null) {
      _timer = GameTimer(duration: durationIdle);
    }
    _maxDistance = maxDistance;
  }

  MoveDirectionEnum? newDirection;

  void randomMove(double dt) {
    if (direction == null || newDirection == null) {
      newDirection = null;
      if (_timer.update(dt)) {
        _initPosition = position.clone();
        final randomInt = Random().nextInt(MoveDirectionEnum.values.length);
        newDirection = MoveDirectionEnum.values[randomInt];
       _timer.reset();
      }
    }

    if (newDirection != null) {
      moveFromDirection(dt, newDirection!);
    }
    if (_initPosition.distanceTo(position) > _maxDistance) {
      stopMove();
      return;
    }
  }

  @override
  void onBlockMovement(GameVector lastPosition) {
    stopMove();
    super.onBlockMovement(lastPosition);
  }
}
