import 'package:bonfire_server/src/components/positioned_game_component.dart';
import 'package:bonfire_server/src/mixins/movement.dart';
import 'package:bonfire_server/src/mixins/use_state.dart';
import 'package:shared_events/shared_events.dart';

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
