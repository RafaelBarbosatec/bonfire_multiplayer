import 'package:bonfire_socket_server/bonfire_socket_server.dart';

import 'websocket_provider.dart';

class BonfireWebsocketClient extends WebsocketClient {
  BonfireWebsocketClient({required this.client});

  final BSocketChannel client;

  @override
  void on<T>(String event, void Function(T event) callback) {
    client.on<T>(event, callback);
  }

  @override
  void send<T>(String event, T data) {
    client.send<T>(event, data);
  }

  @override
  List<int> serializeEvent<T>(String event, T data) {
    return client.serialize<T>(event, data);
  }

  @override
  void sendRaw(List<int> bytes) {
    client.sendRaw(bytes);
  }

  @override
  // TODO: implement id
  String get id => client.id;

  @override
  void cleanListener(String event) {
    client.cleanListener(event);
  }
}
