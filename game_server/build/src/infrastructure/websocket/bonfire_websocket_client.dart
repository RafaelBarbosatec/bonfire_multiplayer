import 'package:bonfire_socket_server/bonfire_socket_server.dart';

import 'websocket_provider.dart';

class BonfireWebsocketClient extends WebsocketClient {
  BonfireWebsocketClient({required this.client});

  final BSocketClient client;

  @override
  void on<T>(String event, void Function(T event) callback) {
    client.on<T>(event, callback);
  }

  @override
  void send<T>(String event, T data) {
    client.send<T>(event, data);
  }

  @override
  // TODO: implement id
  String get id => client.id;
}
