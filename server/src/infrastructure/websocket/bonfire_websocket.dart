import 'package:bonfire_socket_server/bonfire_socket_server.dart';

import 'websocket_provider.dart';

class BonfireWebsocket extends WebsocketProvider<BSocketClient> {
  late BonfireSocket _socket;

  BonfireSocket get socket => _socket;

  @override
  Future<WebsocketProvider<BSocketClient>> init({
    required OnClientConnect<BSocketClient> onClientConnect,
    required OnClientDisconnect<BSocketClient> onClientDisconnect,
  }) async {
    _socket = BonfireSocket(
      onClientConnect: (client) {
        onClientConnect(client, this);
      },
      onClientDisconnect: onClientDisconnect,
    );
    return this;
  }

  @override
  void sendToClient<T>(BSocketClient client, String event, T data) {
    _socket.sendTo<T>(client, event, data);
  }

  @override
  void sendToRoom<T>(String room, String event, T data) {
    //
  }

  @override
  void registerType<T>(TypeAdapter<T> type) {
    _socket.registerType<T>(
      BTypeAdapter<T>(
        toMap: type.toMap,
        fromMap: type.fromMap,
      ),
    );
  }

  @override
  void broadcast<T>(String event, T data) {
    _socket.sendBroadcast<T>(event, data);
  }
}
