import 'dart:math';

import 'package:shared_events/shared_events.dart';

import '../util/game_timer.dart';
import 'block_movement_contact.dart';

mixin RandomMovement on BlockMovementOnContact {
  MoveDirectionEnum? _directionEnum;
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

  void randomMove(double dt) {
    if (_directionEnum == null) {
      if (_timer.update(dt)) {
        _initPosition = position.clone();
        final randomInt = Random().nextInt(MoveDirectionEnum.values.length);
        _directionEnum = MoveDirectionEnum.values[randomInt];
        _timer.reset();
      }
      return;
    }

    if (_directionEnum != null) {
      moveFromDirection(dt, _directionEnum!);
    }
    if (_initPosition.distanceTo(position) > _maxDistance) {
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
