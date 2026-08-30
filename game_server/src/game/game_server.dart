import 'dart:math';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../main.dart';
import '../api/data/model/character_model.dart';
import '../api/data/repositories/character_repository.dart';
import '../api/usecases/authenticator.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import 'components/player.dart';
import 'state_tracker.dart';

class GameServer extends Game {
  GameServer({
    required this.server,
    required super.maps,
    required this.characterRepository,
    required this.authenticator,
  });
  static const tileSize = 16.0;

  List<WebsocketClient> clients = [];

  final WebsocketProvider server;

  /// Used to load the selected character when a client joins with a JWT.
  final CharacterRepository characterRepository;

  /// Validates the JWT sent in [JoinEvent].
  final Authenticator authenticator;

  /// State tracker per map for delta updates
  final Map<String, MapStateTracker> _mapTrackers = {};

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

      // Get or create tracker for this map
      final tracker = _mapTrackers.putIfAbsent(
        compChanged.id,
        () => MapStateTracker(),
      );

      // Generate delta (only changed entities)
      final delta = tracker.generateDelta(
        currentPlayers: compChanged.playersState,
        currentNpcs: compChanged.npcsState,
      );

      // Only send if there are actual changes
      if (tracker.hasChanges(delta)) {
        final players = compChanged.players.whereType<Player>().toList();
        if (players.isEmpty) {
          return;
        }
        // Serialize ONCE for the whole broadcast: the delta is the same for
        // every player in the map, so we do a single msgpack pass and send
        // the same bytes to each recipient (binary frames).
        final bytes = players.first.client.serializeEvent<GameStateModel>(
          EventType.UPDATE_STATE.name,
          delta,
        );
        for (final player in players) {
          player.client.sendRaw(bytes);
        }
      }
    }
  }

  Future<void> _joinPlayerInTheGame(
    WebsocketClient client,
    JoinEvent message,
  ) async {
    if (components
        .whereType<Player>()
        .any((element) => element.id == client.id)) {
      return;
    }

    if (maps.isEmpty) {
      return;
    }

    // Auth: when a JWT is provided, validate it and load the selected
    // character. Anonymous join (no token) keeps working for quick tests.
    CharacterModel? character;
    if (message.token != null) {
      final user = await authenticator.verifyToken(message.token!);
      if (user == null) {
        logger.e('Client(${client.id}) join rejected: invalid token');
        return;
      }
      if (message.characterId == null) {
        logger.e('Client(${client.id}) join rejected: characterId missing');
        return;
      }
      final result = await characterRepository.getById(message.characterId!);
      character = result.when(
        (c) => c.userId == user.id ? c : null,
        (error) => null,
      );
      if (character == null) {
        logger.e('Client(${client.id}) join rejected: character not found');
        return;
      }
    }

    // Position: saved character position or default spawn.
    final position = character != null
        ? GameVector(
            x: character.position.x,
            y: character.position.y,
          )
        : GameVector(
            x: (3 + Random().nextInt(3)) * tileSize,
            y: 11 * tileSize,
          );

    // Adds Player
    final player = Player(
      state: ComponentStateModel(
        id: client.id,
        name: character?.nickName ?? message.name,
        position: position,
        size: GameVector.all(16),
        life: 100,
        properties: {
          'skin': character?.skin ?? message.skin,
        },
      ),
      client: client,
    );

    player.state.serverTimestamp = DateTime.now().microsecondsSinceEpoch;

    // Map: character's saved map or the first map.
    final initialMap = maps.firstWhere(
      (m) => m.id == character?.mapId,
      orElse: () => maps[0],
    );
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

  @override
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
