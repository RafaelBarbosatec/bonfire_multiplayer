import 'package:polo_server/polo_server.dart';

import '../model/join_event.dart';
import '../model/move_event.dart';

export 'package:polo_server/polo_server.dart';

typedef OnClientConnect = void Function(
  PoloClient client,
  WebsocketManager server,
);

typedef OnClientDisconnect = void Function(
  PoloClient client,
);

class WebsocketManager {
  factory WebsocketManager() {
    return _singleton;
  }

  WebsocketManager._internal(this.address, this.port);

  late PoloServer _server;
  final String address;
  final int port;
  bool initialized = false;

  static final WebsocketManager _singleton = WebsocketManager._internal(
    '127.0.0.1',
    3000,
  );

  Future<WebsocketManager> init({
    required OnClientConnect onClientConnect,
    required OnClientDisconnect onClientDisconnect,
  }) async {
    if (!initialized) {
      // Polo Server
      _server = await Polo.createServer(address: address, port: port);
      _server
        ..onClientConnect((c) => onClientConnect(c, this))
        ..onClientDisconnect(onClientDisconnect);
      _registerTypes();
      initialized = true;
    }
    return this;
  }

  void send<T>(String event, T data) {
    _server.send<T>(event, data);
  }

  void sendToClient<T>(PoloClient client, String event, T data) {
    _server.sendToClient<T>(client, event, data);
  }

  void sendToRoom<T>(String room, String event, T data) {
    _server.sendToRoom<T>(room, event, data);
  }

  void broadcastFrom<T>(PoloClient client, String event, T data) {
    _server.broadcastFrom<T>(client, event, data);
  }

  void _registerTypes() {
    _server
      ..registerType<JoinEvent>(
        PoloTypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: JoinEvent.fromMap,
        ),
      )
      ..registerType<MoveEvent>(
        PoloTypeAdapter(
          toMap: (type) => type.toMap(),
          fromMap: MoveEvent.fromMap,
        ),
      );
  }
}
