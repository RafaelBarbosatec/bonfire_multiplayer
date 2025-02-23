import 'dart:math';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../main.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import 'components/player.dart';

class GameServer extends Game {
  GameServer({required this.server, required super.maps}) {
    _registerTypes();
  }
  static const tileSize = 16.0;

  List<WebsocketClient> clients = [];

  final WebsocketProvider server;

  void enterClient(WebsocketClient client) {
    clients.add(client);
    logger.i('Client(${client.id}) Connected!');
    client.on<JoinEvent>(EventType.JOIN.name, (message) {
      logger.i('JoinEvent: ${message.toMap()}');
      _joinPlayerInTheGame(client, message);
    });
  }

  void leaveClient(WebsocketClient client) {
    clients.remove(client);
    for (final map in maps) {
      map.components
          .whereType<Player>()
          .where((element) => element.id == client.id)
          .forEach((element) => element.removeFromParent());
    }
    requestUpdate();
    logger.i('Client(${client.id}) Disconnected!');
  }

  @override
  void updateListeners(GameComponent compChanged) {
    if (compChanged is GameMap) {
      if (compChanged.players.isEmpty) {
        return;
      }
      final players = compChanged.playersState;
      final npcs = compChanged.npcsState;

      for (final player in compChanged.players) {
        player.send(
          EventType.UPDATE_STATE.name,
          GameStateModel(
            players: players,
            npcs: npcs,
          ),
        );
      }
    }
  }

  void _joinPlayerInTheGame(WebsocketClient client, JoinEvent message) {
    if (components
        .whereType<Player>()
        .any((element) => element.id == client.id)) {
      return;
    }

    // Create initial position
    final position = GameVector(
      x: (3 + Random().nextInt(3)) * tileSize,
      y: 11 * tileSize,
    );
    // Adds Player

    final player = Player(
      state: ComponentStateModel(
        id: client.id,
        name: message.name,
        position: position,
        size: GameVector.all(16),
        life: 100,
        properties: {
          'skin': message.skin,
        },
      ),
      client: client,
    );

    final initialMap = maps[0]..add(player);

    // send ACK to client that request join.
    client.send(
      EventType.JOIN_MAP.name,
      JoinMapEvent(
        state: player.state,
        players: initialMap.playersState,
        npcs: initialMap.npcsState,
        map: initialMap.toModel(),
      ),
    );
  }

  void onPlayerChangeMap(GamePlayer player, GameMap map) {
    player.send(
      EventType.JOIN_MAP.name,
      JoinMapEvent(
        state: player.state,
        players: map.playersState,
        npcs: map.npcsState,
        map: map.toModel(),
      ),
    );
  }

  void _registerTypes() {
    server
      ..registerType<JoinEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: JoinEvent.fromMap,
        ),
      )
      ..registerType<JoinMapEvent>(
        TypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: JoinMapEvent.fromMap,
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

  @override
  Future<void> onLoadMaps() {
    logger.d('Loading maps...');
    return super.onLoadMaps();
  }

  @override
  void onStart() {
    logger.i('Start Game loop');
    super.onStart();
  }

  @override
  void stop() {
    logger.i('Stop Game loop');
    super.stop();
  }
}
