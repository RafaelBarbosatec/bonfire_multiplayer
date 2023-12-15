// ignore_for_file: lines_longer_than_80_chars

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
    client.onEvent<JoinEvent>(
      EventType.JOIN.name,
      (message) {
        logger.i('JoinEvent: ${message.toMap()}');
        _joinPlayerInTheGame(client, message);
      },
    );
  }

  void _validateAndMovePlayer(PoloClient client, MoveEvent message) {
    logger.i('_validateAndMovePlayer');
    final player = state.players[client.id];

    if (player == null) {
      logger.i('player==null');
      return;
    }

    final oldPosition = player.position;
    final newPosition = message.position;

    if (isMoveValid(oldPosition, newPosition)) {
      player.position = newPosition;
      requestUpdate();
      logger.i('Sending move validation event with direction: ${message.direction}');
      client.send(EventType.MOVE_VALIDATION.name, MoveValidationEvent(isValid: true, position: newPosition, direction: message.direction));
    } else {
      logger.i('else');
      client.send(EventType.MOVE_VALIDATION.name, MoveValidationEvent(isValid: false, position: oldPosition, direction: message.direction));
    }
  }

  bool isMoveValid(GamePosition oldPosition, GamePosition newPosition) {
    final distance = sqrt(pow(newPosition.x - oldPosition.x, 2) + pow(newPosition.y - oldPosition.y, 2));

    // Por enquanto, apenas verifique a distância do movimento
    if (distance > 32) {
      logger.i('isNotValid');
      return false;
    }

    // No futuro, adicione a lógica para verificar os bloqueios do mapa aqui
    logger.i('isMoveValid');
    return true;
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
      ..onEvent<MoveEvent>(
        EventType.PLAYER_MOVE.name,
        (message) {
          logger.i('PLAYER_MOVE');
          print('Received move event: ${message.toMap()}');
          _validateAndMovePlayer(client, message);
        },
      )

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
      )
      ..registerType<MoveValidationEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: MoveValidationEvent.fromMap,
        ),
      );
  }
}
