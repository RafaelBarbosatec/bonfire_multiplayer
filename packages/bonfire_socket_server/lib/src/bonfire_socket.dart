import 'package:bonfire_socket_server/src/socket_actions.dart';
import 'package:bonfire_socket_server/src/socket_client.dart';
import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:uuid/uuid.dart';

class BonfireSocket
    with
        BonfireTypeAdapterProvider,
        BonfireSocketActions,
        EventSerializerProvider {
  BonfireSocket({
    this.onClientConnect,
    this.onClientDisconnect,
    EventSerializer? serializer,
  }) {
    this.serializer = serializer ?? EventSerializerDefault();
  }
  final List<BSocketClient> _clients = [];
  void Function(BSocketClient client)? onClientConnect;
  void Function(BSocketClient client)? onClientDisconnect;

  Handler handler() {
    return webSocketHandler(_addClient);
  }

  void _addClient(WebSocketChannel channel, _) {
    final client = BSocketClient(
      id: const Uuid().v1(),
      channel: channel,
      onDisconnect: _onClientDisconnect,
      typeAdapterProvider: this,
      socket: this,
      serializerProvider: this,
    );
    _clients.add(client);
    onClientConnect?.call(client);
    print('BonfireSocket: Client connected: ${client.id}');
  }

  void _onClientDisconnect(BSocketClient client) {
    _clients.remove(client);
    onClientDisconnect?.call(client);
    print('BonfireSocket: Client disconnected: ${client.id}');
  }

  @override
  void sendBroadcast<T>(String event, T message) {
    for (final client in _clients) {
      client.send<T>(event, message);
    }
  }

  @override
  void sendTo<T>(BSocketClient client, String event, T message) {
    client.send<T>(event, message);
  }
}
