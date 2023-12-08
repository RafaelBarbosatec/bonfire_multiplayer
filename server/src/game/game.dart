import 'dart:async';
import 'dart:math';

import '../../main.dart';
import '../infrastructure/websocket_manager.dart';
import '../model/join_ack_event.dart';
import '../model/join_event.dart';
import '../util/event_type.dart';
import '../util/game_position.dart';
import 'game_state.dart';
import 'player.dart';

Timer? _gameTimer;
GameState _state = GameState();

class Game {
  Game({required this.server});

  final WebsocketManager server;

  void start() {
    if (_gameTimer == null) {
      logger.i('Start Game loop');
      _gameTimer = Timer.periodic(
        const Duration(seconds: 5),
        (timer) => onUpdate(),
      );
    }
  }

  void enterPlayer(PoloClient client) {
    logger.i('Client(${client.id}) Connected!');
    client.onEvent<JoinEvent>(EventType.JOIN.name, (message) {
      logger.i('JoinEvent: ${message.toMap()}');
      _joinPlayerInTheGame(client, message);
    });
  }

  void leavePlayer(PoloClient client) {
    _state.players.remove(client.id);
    logger.i('Client(${client.id}) Disconnected!');
  }

  void onUpdate() {
    logger.d('PLAYERS: ${_state.players.length}');
  }

  void _joinPlayerInTheGame(PoloClient client, JoinEvent message) {
    if (_state.players.containsKey(client.id)) {
      return;
    }
    // Create initial position
    final position = GamePosition(
      Random().nextDouble() < 0.5 ? 280 : 296,
      264,
    );
    // Adds Player
    _state.players[client.id] = Player(
      id: client.id,
      name: message.name,
      skin: message.skin,
      position: position,
      life: 100,
      client: client,
    )..configure(server);
    // send ACK
    client.send(
      EventType.JOIN_ACK.name,
      JoinAckEvent(
        id: client.id,
        name: message.name,
        skin: message.skin,
        position: position,
        players: _state.players.values.toList(),
      ).toMap(),
    );
  }
}
