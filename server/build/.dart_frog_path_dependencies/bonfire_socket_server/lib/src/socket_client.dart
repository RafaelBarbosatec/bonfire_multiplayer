import 'package:bonfire_socket_server/src/socket_actions.dart';
import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

// ignore: public_member_api_docs
class BSocketClient {
  /// Creates a new instance of [BSocketClient].
  BSocketClient({
    required this.id,
    required WebSocketChannel channel,
    required this.onDisconnect,
    required this.socket,
    required BonfireTypeAdapterProvider typeAdapterProvider,
    required EventSerializerProvider serializerProvider,
  }) : _channel = channel {
    _packer = EventPacker(
      serializerProvider: serializerProvider,
      typeAdapterProvider: typeAdapterProvider,
    );
    _channel.stream.listen(
      _onChannelListen,
      onDone: () => onDisconnect(this),
    );
  }
  late EventPacker _packer;

  /// The unique identifier for the client.
  final String id;

  final WebSocketChannel _channel;

  /// Callback function that is called when the client disconnects.
  final void Function(BSocketClient client) onDisconnect;

  /// The socket actions associated with this client.
  final BonfireSocketActions socket;

  final Map<String, void Function(BEvent)> _onSubscribers = {};

  /// Sends a message to the client.
  void send<T>(String event, T message) {
    final e = BEvent(
      event: event,
      time: DateTime.now().microsecondsSinceEpoch,
      data: _packer.packData<T>(message),
    );
    _channel.sink.add(_packer.packEvent(e));
  }

  /// Registers a callback for a specific event.
  void on<T>(String event, void Function(T event) callback) {
    _onSubscribers[event] = (map) => callback(_packer.unpackData<T>(map.data));
  }

  void _onChannelListen(dynamic message) {
    final event = _packer.unpackEvent(message.toString());
    if (event.event == BSyncTimeEvent.eventName) {
      _sendSyncTime();
      return;
    }
    _onSubscribers[event.event]?.call(event);
  }

  void _sendSyncTime() {
    final event = BSyncTimeEvent();
    _channel.sink.add(_packer.packEvent(event));
  }
}
