import 'dart:async';
import 'dart:math';

import 'package:shared_events/shared_events.dart';

import '../../main.dart';
import '../infrastructure/websocket_manager.dart';
import '../player_manager.dart';
import 'game.dart';
import 'game_state.dart';

class GameImpl extends Game<PoloClient> {
  GameImpl({required this.server});

  final WebsocketManager server;
  Timer? _gameTimer;
  final GameState state = GameState();
  final Map<String, PlayerManager> _playerManagers = {};

  bool _needUpdate = false;

  @override
  void start() {
    if (_gameTimer == null) {
      logger.i('Start Game loop');
      _gameTimer = Timer.periodic(
        const Duration(milliseconds: 30),
        (timer) => onUpdate(),
      );
    }
  }

  @override
  void stop() {
    logger.i('Stop Game loop');
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  @override
  void enterPlayer(PoloClient client) {
    logger.i('Client(${client.id}) Connected!');
    client.onEvent<JoinEvent>(EventType.JOIN.name, (message) {
      logger.i('JoinEvent: ${message.toMap()}');
      _joinPlayerInTheGame(client, message);
    });
  }

  @override
  void leavePlayer(PoloClient client) {
    server.broadcastFrom(
      client,
      EventType.PLAYER_LEAVE.name,
      PlayerEvent(player: state.players[client.id]!),
    );
    state.players.remove(client.id);
    _playerManagers.remove(client.id);
    logger.i('Client(${client.id}) Disconnected!');
  }

  @override
  void onUpdate() {
    if (_needUpdate) {
      server.send(
        EventType.UPDATE_STATE.name,
        GameStateModel(players: state.players.values.toList()),
      );
      _needUpdate = false;
    }
  }

  void _joinPlayerInTheGame(PoloClient client, JoinEvent message) {
    if (state.players.containsKey(client.id)) {
      return;
    }
    const tileSize = 16.0;

    // Create initial position
    final position = GamePosition(
      x: (8 + Random().nextInt(3)) * tileSize,
      y: 5 * tileSize,
    );
    // Adds Player
    state.players[client.id] = PlayerStateModel(
      id: client.id,
      name: message.name,
      skin: message.skin,
      position: position,
      life: 100,
    );

    _playerManagers[client.id] = PlayerManager(
      playerModel: state.players[client.id]!,
      client: client,
      game: this,
    );
    // send ACK to client that request join.
    client.send(
      EventType.JOIN_ACK.name,
      JoinAckEvent(
        state: state.players[client.id]!,
        players: state.players.values.toList(),
      ),
    );

    // send to others players that this player is joining
    server.broadcastFrom(
      client,
      EventType.PLAYER_JOIN.name,
      PlayerEvent(player: state.players[client.id]!),
    );
  }

  @override
  void requestUpdate() {
    _needUpdate = true;
  }
}
