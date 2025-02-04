import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:web_socket_client/web_socket_client.dart';

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
  }

  Future<void> conect({
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
    final map = BEvent.fromMap(
      serializer.deserialize(message as List<int>),
    );
    _onSubscribers[map.event]?.call(map.data);
    if (debug) {
      print('BonfireSocketClient: ${map.toMap()}');
    }
  }

  void send<T>(String event, T message) {
    final typeString = T.toString();
    dynamic eventdata = message;
    if (types.containsKey(typeString)) {
      final adapter = types[typeString]! as BTypeAdapter<T>;
      eventdata = adapter.toMap(message);
    }
    final e = BEvent(
      event: event,
      data: eventdata,
    );
    final data = serializer.serialize(e.toMap());
    _socket.send(data);
  }

  void on<T>(String event, void Function(T event) callback) {
    final typeString = T.toString();
    _onSubscribers[event] = (map) {
      if (types.containsKey(typeString)) {
        final adapter = types[typeString]! as BTypeAdapter<T>;
        callback(adapter.fromMap((map as Map).cast()));
      } else {
        callback(map as T);
      }
    };
  }
}
