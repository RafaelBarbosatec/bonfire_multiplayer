import 'dart:math';

import 'package:shared_events/shared_events.dart';

import '../../main.dart';
import '../core/game.dart';
import '../core/game_component.dart';
import '../core/game_map.dart';
import '../core/game_player.dart';
import '../infrastructure/websocket/polo_websocket.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import 'components/player.dart';

class GameServer extends Game {
  GameServer({required this.server, required this.maps}) {
    _registerTypes();
  }
  static const tileSize = 16.0;
  final List<GameMap> maps;
  bool mapLoaded = false;
  List<PoloClient> clients = [];

  final WebsocketProvider<PoloClient> server;

  void enterClient(PoloClient client) {
    clients.add(client);
    logger.i('Client(${client.id}) Connected!');
    client.onEvent<JoinEvent>(EventType.JOIN.name, (message) {
      logger.i('JoinEvent: ${message.toMap()}');
      _joinPlayerInTheGame(client, message);
    });
  }

  void leaveClient(PoloClient client) {
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
  void onStateUpdate(GameComponent comp) {
    if (comp is GameMap) {
      for (final player in comp.players) {
        player.send(
          EventType.UPDATE_STATE.name,
          GameStateModel(
            players: comp.playersState,
            npcs: comp.npcsState,
          ),
        );
      }
    }
  }

  void _joinPlayerInTheGame(PoloClient client, JoinEvent message) {
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

    final initialMap = maps[0];

    initialMap.add(player);

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

  void changeMap(GamePlayer player, String newMapId) {
    try {
      final map = maps.firstWhere((element) => element.id == newMapId);
      player.removeFromParent();
      map.add(player);
      player.send(
        EventType.JOIN_MAP.name,
        JoinMapEvent(
          state: player.state,
          players: map.playersState,
          npcs: map.npcsState,
          map: map.toModel(),
        ),
      );
    } catch (e) {
      logger.e('Not found map: $newMapId');
    }
  }

  @override
  Future<void> start() async {
    await _loadMaps();
    return super.start();
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

  Future<void> _loadMaps() async {
    if (!mapLoaded) {
      logger.d('Loading maps...');
      addAll(maps);
      for (final map in maps) {
        await map.load();
      }
      mapLoaded = true;
    }
  }
}
