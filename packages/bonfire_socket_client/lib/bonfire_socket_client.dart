import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:web_socket_client/web_socket_client.dart';

export 'package:bonfire_socket_shared/bonfire_socket_shared.dart';

class BonfireSocketClient
    with BonfireTypeAdapterProvider, EventSerializerProvider {
  late WebSocket _socket;
  final Uri uri;
  final Iterable<String>? protocols;
  final Duration? pingInterval;
  final Map<String, dynamic>? headers;
  final Backoff? backoff;
  final Duration? timeout;
  final String? binaryType;
  final bool debug;

  final Map<String, void Function(dynamic)> _onSubscribers = {};
  late EventPacker _packer;

  BonfireSocketClient({
    required this.uri,
    this.protocols,
    this.pingInterval,
    this.headers,
    this.backoff,
    this.timeout,
    this.binaryType,
    EventSerializer? serializer,
    this.debug = false,
  }) {
    this.serializer = serializer ?? EventSerializerDefault();
    _packer = EventPacker(
      serializerProvider: this,
      typeAdapterProvider: this,
    );
  }

  Future<void> connect({
    Function? onConnected,
    Function(String? reason)? onDisconnected,
  }) async {
    _socket = WebSocket(
      uri,
      protocols: protocols,
      pingInterval: pingInterval,
      headers: headers,
      backoff: backoff,
      timeout: timeout,
      binaryType: binaryType,
    );
    _socket.connection.listen((state) {
      print('BonfireSocketClient: Connection state: $state');
      if (state is Connected || state is Reconnected) {
        onConnected?.call();
      }

      if (state is Disconnected) {
        onDisconnected?.call(state.reason);
      }
    });
    _socket.messages.listen(_onMessageslListen);
  }

  void _onMessageslListen(dynamic message) {
    final event = _packer.unpackEvent(message);
    _onSubscribers[event.event]?.call(event.data);
    if (debug) {
      print('BonfireSocketClient: ${event.toMap()}');
    }
  }

  void send<T>(String event, T message) {
    _socket.send(_packer.packEvent<T>(event, message));
  }

  void on<T>(String event, void Function(T event) callback) {
    _onSubscribers[event] = (map) => callback(_packer.unpackData<T>(map));
  }
}
