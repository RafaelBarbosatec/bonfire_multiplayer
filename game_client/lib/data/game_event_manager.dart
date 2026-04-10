import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:shared_events/shared_events.dart';

class GameEventManager {
  final WebsocketProvider websocket;

  final Map<String, void Function(ComponentStateModel data)>
      specificPlayerStateSubscriber = {};
  final Map<String, void Function(ComponentStateModel data)>
      specificEnemyStateSubscriber = {};

  final List<void Function(Iterable<ComponentStateModel> data)>
      playerStateSubscriber = [];

  final List<void Function(Iterable<ComponentStateModel> data)>
      enemyStateSubscriber = [];

  /// Callbacks for when entities are removed (by ID)
  final List<void Function(List<String> removedIds)> removedSubscriber = [];

  void Function(JoinMapEvent event)? _onJoinMapEvent;

  GameEventManager({required this.websocket});

  Future<void> connect({
    void Function()? onConnect,
    void Function()? onDisconnect,
  }) async {
    await websocket.init(
      onConnect: () {
        _registerTypes();
        _initOnPlayerState();
        onConnect?.call();
      },
      onDisconnect: () {
        clearSubscribers();
        onDisconnect?.call();
      },
    );
  }

  void send<T>(String event, T data) {
    websocket.send(event, data);
  }

  void onDisconnect(void Function() onDisconnect) {
    websocket.onDisconnect(onDisconnect);
  }

  void onSpecificPlayerState(
    String id,
    void Function(ComponentStateModel data) callback,
  ) {
    specificPlayerStateSubscriber[id] = callback;
  }

  void onSpecificEnemyState(
    String id,
    void Function(ComponentStateModel data) callback,
  ) {
    specificEnemyStateSubscriber[id] = callback;
  }

  void onPlayerState(
    void Function(Iterable<ComponentStateModel> data) callback,
  ) {
    playerStateSubscriber.add(callback);
  }

  void onEnemyState(
    void Function(Iterable<ComponentStateModel> data) callback,
  ) {
    enemyStateSubscriber.add(callback);
  }

  void onRemoved(void Function(List<String> removedIds) callback) {
    removedSubscriber.add(callback);
  }

  void removeOnRemoved(void Function(List<String> removedIds) callback) {
    removedSubscriber.remove(callback);
  }

  void removeOnSpecificPlayerState(String id) {
    specificPlayerStateSubscriber.remove(id);
  }

  void removeOnSpecificEnemyState(String id) {
    specificEnemyStateSubscriber.remove(id);
  }

  void removeOnPlayerState(
    void Function(List<ComponentStateModel> data) callback,
  ) {
    playerStateSubscriber.remove(callback);
  }

  void removeOnEnemyState(
    void Function(List<ComponentStateModel> data) callback,
  ) {
    enemyStateSubscriber.remove(callback);
  }

  void onJoinMapEvent(void Function(JoinMapEvent event)? callback) {
    _onJoinMapEvent = callback;
  }

  /// Clear all subscribers (call on disconnect)
  void clearSubscribers() {
    specificPlayerStateSubscriber.clear();
    specificEnemyStateSubscriber.clear();
    playerStateSubscriber.clear();
    enemyStateSubscriber.clear();
    removedSubscriber.clear();
    _onJoinMapEvent = null;
  }

  void _listenState(GameStateModel state) {
    // Notify about changed/new players
    if (state.players.isNotEmpty) {
      for (var call in playerStateSubscriber) {
        call(state.players);
      }
      for (var player in state.players) {
        specificPlayerStateSubscriber[player.id]?.call(player);
      }
    }

    // Notify about changed/new NPCs
    if (state.npcs.isNotEmpty) {
      for (var call in enemyStateSubscriber) {
        call(state.npcs);
      }
      for (var npc in state.npcs) {
        specificEnemyStateSubscriber[npc.id]?.call(npc);
      }
    }

    // Notify about removed entities (players or NPCs)
    if (state.removed.isNotEmpty) {
      for (var call in removedSubscriber) {
        call(state.removed);
      }
    }
  }

  void _initOnPlayerState() {
    websocket.onEvent<GameStateModel>(
      EventType.UPDATE_STATE.name,
      _listenState,
    );
    websocket.onEvent<JoinMapEvent>(
      EventType.JOIN_MAP.name,
      (data) {
        _onJoinMapEvent?.call(data);
      },
    );
  }

  void _registerTypes() {
    websocket.registerType<JoinMapEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: JoinMapEvent.fromMap,
      ),
    );
    websocket.registerType<JoinEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: JoinEvent.fromMap,
      ),
    );
    websocket.registerType<GameStateModel>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: GameStateModel.fromMap,
      ),
    );
    websocket.registerType<MoveEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: MoveEvent.fromMap,
      ),
    );
    websocket.registerType<PlayerEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: PlayerEvent.fromMap,
      ),
    );
  }
}
