import 'dart:math';

import 'package:shared_events/shared_events.dart';

import '../../main.dart';
import '../infrastructure/websocket/polo_websocket.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import '../player_manager.dart';
import 'game.dart';
import 'game_client.dart';
import 'game_state.dart';

class GameImpl extends Game<PoloClient> {
  GameImpl({required this.server}) {
    _registerTypes();
  }

  final WebsocketProvider<PoloClient> server;
  final GameState state = GameState();

  bool _needUpdate = false;

  @override
  void enterClient(GameClient<PoloClient> client) {
    logger.i('Client(${client.id}) Connected!');
    client.socketClient.onEvent<JoinEvent>(EventType.JOIN.name, (message) {
      logger.i('JoinEvent: ${message.toMap()}');
      _joinPlayerInTheGame(client, message);
    });
  }

  @override
  void leaveClient(GameClient<PoloClient> client) {
    if (state.players.containsKey(client.id)) {
      server.broadcastFrom(
        client.socketClient,
        EventType.PLAYER_LEAVE.name,
        PlayerEvent(player: state.players[client.id]!.state),
      );
      state.players.remove(client.id);
    }

    logger.i('Client(${client.id}) Disconnected!');
  }

  @override
  void onUpdate() {
    if (_needUpdate) {
      final stateList = statePlayerList;
      for (final player in state.players.values) {
        player.client.socketClient.send(
          EventType.UPDATE_STATE.name,
          GameStateModel(players: stateList),
        );
      }
      _needUpdate = false;
    }
  }

  List<PlayerStateModel> get statePlayerList =>
      state.players.values.map((e) => e.state).toList();

  void _joinPlayerInTheGame(GameClient<PoloClient> client, JoinEvent message) {
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

    state.players[client.id] = Player(
      state: PlayerStateModel(
        id: client.id,
        name: message.name,
        skin: message.skin,
        position: position,
        life: 100,
      ),
      client: client,
      game: this,
    );

    // send ACK to client that request join.
    client.socketClient.send(
      EventType.JOIN_ACK.name,
      JoinAckEvent(
        state: state.players[client.id]!.state,
        players: statePlayerList,
        map: 'map.tmj',
      ),
    );

    // send to others players that this player is joining
    server.broadcastFrom(
      client.socketClient,
      EventType.PLAYER_JOIN.name,
      PlayerEvent(player: state.players[client.id]!.state),
    );
  }

  @override
  void requestUpdate() {
    _needUpdate = true;
  }

  @override
  List<PlayerStateModel> players() {
    return statePlayerList;
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
