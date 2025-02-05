import 'package:bonfire_socket_server/src/socket_actions.dart';
import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

// ignore: public_member_api_docs
class BSocketClient extends EventPacker {
  /// Creates a new instance of [BSocketClient].
  BSocketClient({
    required this.id,
    required WebSocketChannel channel,
    required this.onDisconnect,
    required this.socket,
    required BonfireTypeAdapterProvider typeAdapterProvider,
    required EventSerializerProvider serializerProvider,
  }) : _channel = channel {
    this.serializerProvider = serializerProvider;
    this.typeAdapterProvider = typeAdapterProvider;
    _channel.stream.listen(
      _onChannelListen,
      onDone: () => onDisconnect(this),
    );
  }

  /// The unique identifier for the client.
  final String id;

  final WebSocketChannel _channel;

  /// Callback function that is called when the client disconnects.
  final void Function(BSocketClient client) onDisconnect;

  /// The socket actions associated with this client.
  final BonfireSocketActions socket;

  final Map<String, void Function(dynamic)> _onSubscribers = {};

  /// Sends a message to the client.
  void send<T>(String event, T message) {
    _channel.sink.add(packEvent<T>(event, message));
  }

  /// Registers a callback for a specific event.
  void on<T>(String event, void Function(T event) callback) {
    _onSubscribers[event] = (map) => unpackEvent<T>(map);
    // final typeString = T.toString();
    // _onSubscribers[event] = (map) {
    //   if (_typeAdapterProvider.types.containsKey(typeString)) {
    //     final adapter =
    //         _typeAdapterProvider.types[typeString]! as BTypeAdapter<T>;

    //     callback(adapter.fromMap((map as Map).cast()));
    //   } else {
    //     callback(map as T);
    //   }
    // };
  }

  void _onChannelListen(dynamic message) {
    final map = BEvent.fromMap(
      serializerProvider.serializer.deserialize(message as List<int>),
    );
    _onSubscribers[map.event]?.call(map.data);
  }
}
