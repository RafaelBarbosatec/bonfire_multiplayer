import 'package:bonfire_server/src/components/positioned_game_component.dart';
import 'package:bonfire_server/src/mixins/movement.dart';
import 'package:bonfire_server/src/mixins/use_state.dart';
import 'package:shared_events/shared_events.dart';

abstract class GameNpc extends PositionedGameComponent with Movement, UseState {
  GameNpc({
    required ComponentStateModel state,
    super.components,
  }) {
    this.state = state;
  }
}
