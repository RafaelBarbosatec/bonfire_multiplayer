// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

import 'game/game.dart';
import 'game/game_client.dart';
import 'infrastructure/websocket/polo_websocket.dart';

class Player {
  Player({
    required this.state,
    required this.client,
    required this.game,
  }) {
    _confMove();
  }

  final PlayerStateModel state;
  final GameClient<PoloClient> client;
  // ignore: strict_raw_type
  final Game game;

  void _confMove() {
    client.socketClient.onEvent<MoveEvent>(EventType.PLAYER_MOVE.name, (data) {
      // update playerState position
      state
        ..position = data.position.clone()
        ..direction = data.direction;
      game.requestUpdate();
    });
  }
}
