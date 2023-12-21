// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';


import '../core/game_component.dart';
import '../infrastructure/websocket/polo_websocket.dart';

class Player extends GameComponent {
  Player({
    required this.state,
    required this.client,
  }) {
    _confMove();
  }

  final PlayerStateModel state;
  final PoloClient client;

  String get id => state.id;

  void _confMove() {
    client.onEvent<MoveEvent>(
      EventType.PLAYER_MOVE.name,
      (data) {
        state.direction = data.direction;
      },
    );
  }

  bool sendedIdle = false;

  @override
  void onUpdate(double dt) {
    if (state.direction != null) {
      sendedIdle = false;
      _updatePosition(dt);
      game.requestUpdate(client.id);
    } else {
      if (!sendedIdle) {
        sendedIdle = true;
        game.requestUpdate(client.id);
      }
    }
  }

  void _updatePosition(double dt) {
    if (state.direction == 'left') {
      state.position.x -= dt * 100;
    }
    if (state.direction == 'right') {
      state.position.x += dt * 100;
    }

    if (state.direction == 'up') {
      state.position.y -= dt * 100;
    }
    if (state.direction == 'down') {
      state.position.y += dt * 100;
    }
  }
}
