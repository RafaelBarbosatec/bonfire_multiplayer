import 'package:shared_events/shared_events.dart';

import 'mixins/movement.dart';
import 'mixins/use_state.dart';
import 'positioned_game_component.dart';

abstract class GamePlayer extends PositionedGameComponent
    with Movement, UseState {
  GamePlayer({
    required ComponentStateModel state,
    super.components,
  }) {
    this.state = state;
  }

  void send<T>(String event, T data);
}
