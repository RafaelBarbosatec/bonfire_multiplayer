import 'package:shared_events/shared_events.dart';

import 'mixins/movement.dart';
import 'mixins/use_state.dart';
import 'positioned_game_component.dart';

abstract class GameNpc extends PositionedGameComponent with Movement, UseState {
  GameNpc({
    required ComponentStateModel state,
    super.components,
  }) {
    this.state = state;
  }
}
