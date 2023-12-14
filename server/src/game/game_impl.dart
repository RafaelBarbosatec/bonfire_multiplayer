import 'dart:async';
import 'dart:math';

import 'package:shared_events/shared_events.dart';

import '../../main.dart';
import '../infrastructure/websocket/polo_websocket.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import '../player_manager.dart';
import 'game.dart';
import 'game_state.dart';

class GameImpl extends Game<PoloClient> {
  GameImpl({required this.server}) {
    _registerTypes();
  }

  final WebsocketProvider<PoloClient> server;
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
    if (state.players.containsKey(client.id)) {
      server.broadcastFrom(
        client,
        EventType.PLAYER_LEAVE.name,
        PlayerEvent(player: state.players[client.id]!),
      );
      state.players.remove(client.id);
      _playerManagers.remove(client.id);
    }

    logger.i('Client(${client.id}) Disconnected!');
  }

  @override
  void onUpdate() {
    if (_needUpdate) {
      _playerManagers.forEach((key, value) {
        value.client.send(
          EventType.UPDATE_STATE.name,
          GameStateModel(players: state.players.values.toList()),
        );
      });
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

    client
      ..onEvent<MoveEvent>(EventType.PLAYER_MOVE.name, (data) {
        _handleMoveEvent(client, data);
      })

      // send ACK to client that request join.
      ..send(
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

  void _handleMoveEvent(PoloClient client, MoveEvent event) {
    // Get the PlayerManager for the client who sent the MoveEvent
    PlayerManager? playerManager = _playerManagers[client.id];

    // Calculate the new position based on the direction from the MoveEvent
    // This is where you would add your game's movement logic
    // For example, if the direction is "up", you might decrease the player's y coordinate
    // If the direction is "down", you might increase the player's y coordinate
    // And so on for "left" and "right"
    GamePosition newPosition = calculateNewPosition(playerManager!.playerModel.position, event.direction);

    // Check if the new position is valid (e.g., it's not outside the game area, it's not colliding with anything)
    if (isValidPosition(newPosition)) {
      // If the new position is valid, update the player's position
      playerManager.playerModel.position = newPosition;

      // Send a MoveResponseEvent with success = true back to the client
      client.send(
        EventType.MOVE_RESPONSE.name,
        MoveResponseEvent(success: true),
      );
    } else {
      // If the new position is not valid, send a MoveResponseEvent with success = false and an error message back to the client
      client.send(
        EventType.MOVE_RESPONSE.name,
        MoveResponseEvent(success: false, errorMessage: "Invalid move"),
      );
    }
  }

  GamePosition calculateNewPosition(GamePosition currentPosition, String direction) {
    // For now, let's just return the current position regardless of the direction
    // In the future, you can add logic here to calculate the new position based on the direction
    return currentPosition;
  }

  bool isValidPosition(GamePosition position) {
    // For now, let's just return true to allow all positions
    // In the future, you can add logic here to check if the position is valid (e.g., it's not outside the game area, it's not colliding with anything)
    return true;
  }

  @override
  void requestUpdate() {
    _needUpdate = true;
  }

  @override
  List<PlayerStateModel> players() {
    return state.players.values.toList();
  }

  void _registerTypes() {
    server
      ..registerType<JoinEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: JoinEvent.fromMap,
        ),
      )
      ..registerType<JoinAckEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: JoinAckEvent.fromMap,
        ),
      )
      ..registerType<GameStateModel>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: GameStateModel.fromMap,
        ),
      )
      ..registerType<PlayerEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: PlayerEvent.fromMap,
        ),
      )
      ..registerType<MoveEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: MoveEvent.fromMap,
        ),
      );
  }
}
