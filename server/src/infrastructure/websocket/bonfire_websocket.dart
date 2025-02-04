import 'package:bonfire_socket_server/bonfire_socket_server.dart';

import 'bonfire_websocket_client.dart';
import 'websocket_provider.dart';

class BonfireWebsocket extends WebsocketProvider {
  late BonfireSocket _socket;

  BonfireSocket get socket => _socket;

  @override
  Future<WebsocketProvider> init({
    required OnClientConnect onClientConnect,
    required OnClientDisconnect onClientDisconnect,
  }) async {
    _socket = BonfireSocket(
      onClientConnect: (client) {
        onClientConnect(BonfireWebsocketClient(client: client), this);
      },
      onClientDisconnect: (client) {
        onClientDisconnect(BonfireWebsocketClient(client: client));
      },
    );
    return this;
  }

  @override
  void sendToClient<T>(WebsocketClient client, String event, T data) {
    _socket.sendTo<T>((client as BonfireWebsocketClient).client, event, data);
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
