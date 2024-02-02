import 'package:shared_events/shared_events.dart';

import '../positioned_game_component.dart';
import 'movement.dart';

mixin UseState on PositionedGameComponent {
  late ComponentStateModel _state;

  ComponentStateModel get state => _state;

  set state(ComponentStateModel state) {
    _state = state;
    position = _state.position;
    size = _state.size;
    if (this is Movement) {
      (this as Movement).speed = _state.speed;
    }
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
}
