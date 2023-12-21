import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:shared_events/shared_events.dart';

class GameEventManager {
  final WebsocketProvider websocket;

  final Map<String, void Function(PlayerStateModel data)>
      specificPlayerStateSubscriber = {};

  final List<void Function(List<PlayerStateModel> data)> playerStateSubscriber =
      [];

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

  void onSpecificPlayerState(
    String id,
    void Function(PlayerStateModel data) callback,
  ) {
    specificPlayerStateSubscriber[id] = callback;
  }

  void onPlayerState(
    void Function(List<PlayerStateModel> data) callback,
  ) {
    playerStateSubscriber.add(callback);
  }

  void removeOnSpecificPlayerState(String id) {
    specificPlayerStateSubscriber.remove(id);
  }

  void removeOnPlayerState(
    void Function(PlayerStateModel data) callback,
  ) {
    playerStateSubscriber.remove(callback);
  }

  void _initOnPlayerState() {
    websocket.onEvent<GameStateModel>(
      EventType.UPDATE_STATE.name,
      (state) {
        for (var call in playerStateSubscriber) {
          call(state.players);
        }
        for (var player in state.players) {
          specificPlayerStateSubscriber[player.id]?.call(player);
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
