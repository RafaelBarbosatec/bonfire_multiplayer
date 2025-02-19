import 'dart:async';

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
    this.bufferDelayEnabled = true,
  }) : _channel = channel {
    _packer = EventPacker(
      serializerProvider: serializerProvider,
      typeAdapterProvider: typeAdapterProvider,
    );
    _timeSync = TimeSync();
    _eventQueue = EventQueue<BEvent>(
      timeSync: _timeSync,
      listen: _onQueueEvent,
      enabled: bufferDelayEnabled,
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

  /// Indicates whether the buffer delay is enabled for the socket client.
  /// When set to `true`, the socket client will use a buffer delay to optimize
  /// data transmission, potentially reducing the number of packets sent.
  /// When set to `false`, data will be sent immediately without buffering.
  final bool bufferDelayEnabled;

  final Map<String, void Function(BEvent)> _onSubscribers = {};

  Completer<DateTime>? _timeSyncCompleter;
  late TimeSync _timeSync;

  late EventQueue<BEvent> _eventQueue;

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
    if (_handleSyncTime(event)) {
      return;
    }
    _eventQueue.add(
      Frame(event, event.time),
    );
  }

  void _onQueueEvent(BEvent event) {
    _onSubscribers[event.event]?.call(event);
  }

  Future<void> _syncTime() async {
    if (_timeSyncCompleter != null) {
      return;
    }
    _timeSyncCompleter = Completer<DateTime>();
    await _timeSync.synchronize(
      () {
        _sendPingSyncTime();
        return _timeSyncCompleter!.future;
      },
    );
  }

  void _sendPongSyncTime() {
    final event = PongSyncTimeEvent();
    _channel.sink.add(_packer.packEvent(event));
  }

  void _sendPingSyncTime() {
    final event = PingSyncTimeEvent();
    _channel.sink.add(_packer.packEvent(event));
  }

  bool _handleSyncTime(BEvent event) {
    if (event.event == PingSyncTimeEvent.eventName) {
      _sendPongSyncTime();
      _syncTime();
      return true;
    }

    if (event.event == PongSyncTimeEvent.eventName) {
      _timeSyncCompleter?.complete(
        DateTime.fromMicrosecondsSinceEpoch(event.time),
      );
      _timeSyncCompleter = null;
      return true;
    }

    return false;
  }

  /// Gets the room ID associated with this socket client.
  ///
  /// This property retrieves the room ID by calling the `getMyRoomId` method
  /// on the `socket` object, passing this client instance as a parameter.
  ///
  /// Returns `null` if the client is not in a room.
  String? get roomId => socket.getMyRoomId(this);

  /// Allows the client to leave the current room.
  ///
  /// This method retrieves the current room ID using the `roomId` property.
  /// If the client is in a room (i.e., the room ID is not `null`), it calls
  /// the `leaveRoom` method on the `socket` object, passing the room ID and
  /// this client instance as parameters.
  void leaveRoom() {
    final id = roomId;
    if (id != null) {
      socket.leaveRoom(id, this);
    }
  }
}
