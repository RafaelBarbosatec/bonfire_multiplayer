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
      onDisconnect: onDisconnect,
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

  void _listenState(GameStateModel state) {
    for (var call in playerStateSubscriber) {
      call(state.players);
    }
    for (var player in state.players) {
      specificPlayerStateSubscriber[player.id]?.call(player);
    }

    for (var call in enemyStateSubscriber) {
      call(state.npcs);
    }

    for (var npc in state.npcs) {
      specificEnemyStateSubscriber[npc.id]?.call(npc);
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
