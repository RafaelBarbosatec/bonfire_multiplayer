import 'package:shared_events/shared_events.dart';

import 'movement.dart';

mixin UseState on Movement {
  late ComponentStateModel _state;

  ComponentStateModel get state => _state;

  set state(ComponentStateModel state) {
    _state = state;
    position = _state.position;
    size = _state.size;
    speed = _state.speed;
    direction = _state.direction;
  }

  @override
  set position(GameVector position) {
    state.position = position;
    super.position = position;
  }

  @override
  set size(GameVector size) {
    state.size = size;
    super.size = size;
  }

  @override
  set direction(MoveDirectionEnum? direction) {
    state.direction = direction;
    super.direction = direction;
  }
}
