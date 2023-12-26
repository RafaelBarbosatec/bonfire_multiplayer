import 'package:shared_events/shared_events.dart';

import 'game_component.dart';

abstract class GamePlayer extends GameComponent {
  GamePlayer({
    required this.state,
    super.components,
    super.position,
  });

  @override
  set position(GameVector position) {
    state.position = position;
    super.position = position;
  }

  final ComponentStateModel state;

  void send<T>(String event, T data);
}
