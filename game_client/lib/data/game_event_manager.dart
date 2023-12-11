import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:shared_events/shared_events.dart';

class GameEventManager {
  final WebsocketProvider websocket;

  final Map<String, void Function(PlayerStateModel data)>
      playerStateSubscriber = {};

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

  void onEvent<T>(String event, void Function(T data) callback) {
    websocket.onEvent<T>(event, callback);
  }

  void onDisconnect(void Function() onDisconnect) {
    websocket.onDisconnect(onDisconnect);
  }

  void onPlayerState(
    String id,
    void Function(PlayerStateModel data) callback,
  ) {
    playerStateSubscriber[id] = callback;
  }

  void removeOnPlayerState(String id) {
    playerStateSubscriber.remove(id);
  }

  void _initOnPlayerState() {
    websocket.onEvent<GameStateModel>(
      EventType.UPDATE_STATE.name,
      (state) {
        for (var player in state.players) {
          playerStateSubscriber[player.id]?.call(player);
        }
      },
    );
  }

  void _registerTypes() {
    websocket.registerType<JoinAckEvent>(
      TypeAdapter(
        toMap: (type) => type.toMap(),
        fromMap: JoinAckEvent.fromMap,
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
