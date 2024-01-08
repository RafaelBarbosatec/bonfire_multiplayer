import 'package:polo_server/polo_server.dart';

import 'websocket_provider.dart';

export 'package:polo_server/polo_server.dart';

class PoloWebsocket extends WebsocketProvider<PoloClient> {
  factory PoloWebsocket() {
    return _singleton;
  }

  PoloWebsocket._internal(this.address, this.port);

  late PoloServer _server;
  final String address;
  final int port;
  bool initialized = false;

  static final PoloWebsocket _singleton = PoloWebsocket._internal(
    '0.0.0.0',
    // '127.0.0.1',
    3000,
  );

  @override
  Future<WebsocketProvider<PoloClient>> init({
    required OnClientConnect<PoloClient> onClientConnect,
    required OnClientDisconnect<PoloClient> onClientDisconnect,
  }) async {
    if (!initialized) {
      // Polo Server
      _server = await Polo.createServer(address: address, port: port);
      _server
        ..onClientConnect((c) => onClientConnect(c, this))
        ..onClientDisconnect(onClientDisconnect);
      initialized = true;
    }
    return this;
  }

  @override
  void send<T>(String event, T data) {
    _server.send<T>(event, data);
  }

  @override
  void sendToClient<T>(PoloClient client, String event, T data) {
    _server.sendToClient<T>(client, event, data);
  }

  @override
  void sendToRoom<T>(String room, String event, T data) {
    _server.sendToRoom<T>(room, event, data);
  }

  @override
  void broadcastFrom<T>(PoloClient client, String event, T data) {
    _server.broadcastFrom<T>(client, event, data);
  }

  @override
  void registerType<T>(TypeAdapter<T> type) {
    _server.registerType<T>(
      PoloTypeAdapter<T>(
        toMap: type.toMap,
        fromMap: type.fromMap,
      ),
    );
  }
}
