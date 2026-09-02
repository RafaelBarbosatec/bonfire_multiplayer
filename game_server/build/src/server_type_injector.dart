import 'package:shared_events/shared_events.dart';

import 'infrastructure/websocket/websocket_provider.dart';

void injectServerTypes(WebsocketProvider server) {
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
