import 'package:bonfire_socket_server/src/socket_actions.dart';
import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

class BSocketClient {
  BSocketClient({
    required this.id,
    required WebSocketChannel channel,
    required this.onDisconnect,
    required BonfireTypeAdapterProvider typeAdapterProvider,
    required this.socket,
    required this.serializerProvider,
  })  : _channel = channel,
        _typeAdapterProvider = typeAdapterProvider {
    _channel.stream.listen(
      _onChannelListen,
      onDone: () => onDisconnect(this),
    );
  }
  final String id;
  final WebSocketChannel _channel;
  final void Function(BSocketClient client) onDisconnect;
  final BonfireTypeAdapterProvider _typeAdapterProvider;
  final BonfireSocketActions socket;
  final EventSerializerProvider serializerProvider;

  final Map<String, void Function(dynamic)> _onSubscribers = {};

  void send<T>(String event, T message) {
    final typeString = T.toString();
    dynamic eventdata = message;
    if (_typeAdapterProvider.types.containsKey(typeString)) {
      final adapter =
          _typeAdapterProvider.types[typeString]! as BTypeAdapter<T>;

      eventdata = adapter.toMap(message);
    }
    final e = BEvent(
      event: event,
      data: eventdata,
    );
    final data = serializerProvider.serializer.serialize(e.toMap());
    _channel.sink.add(data);
  }

  void on<T>(String event, void Function(T event) callback) {
    final typeString = T.toString();
    _onSubscribers[event] = (map) {
      if (_typeAdapterProvider.types.containsKey(typeString)) {
        final adapter =
            _typeAdapterProvider.types[typeString]! as BTypeAdapter<T>;

        callback(adapter.fromMap((map as Map).cast()));
      } else {
        callback(map as T);
      }
    };
  }

  void _onChannelListen(dynamic message) {
    final map = BEvent.fromMap(
      serializerProvider.serializer.deserialize(message as List<int>),
    );
    _onSubscribers[map.event]?.call(map.data);
  }
}
