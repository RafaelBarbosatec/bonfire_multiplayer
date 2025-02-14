// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:developer';

import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:web_socket_client/web_socket_client.dart';

export 'package:bonfire_socket_shared/bonfire_socket_shared.dart';

class BonfireSocketClient
    with BonfireTypeAdapterProvider, EventSerializerProvider {
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
    this.syncTimeInterval = const Duration(minutes: 1),
    this.bufferDelayEnabled = false,
  }) {
    this.serializer = serializer ?? EventSerializerDefault();
    _packer = EventPacker(
      serializerProvider: this,
      typeAdapterProvider: this,
    );
    timeSync = TimeSync();
    _eventQueue = EventQueue<BEvent>(
      timeSync: timeSync,
      listen: _onListernQueue,
      enabled: bufferDelayEnabled,
    );
  }
  late WebSocket _socket;
  final Uri uri;
  final Iterable<String>? protocols;
  final Duration? pingInterval;
  final Map<String, dynamic>? headers;
  final Backoff? backoff;
  final Duration? timeout;
  final String? binaryType;
  final bool debug;
  final Map<String, void Function(BEvent)> _onSubscribers = {};
  late EventPacker _packer;
  final Duration syncTimeInterval;
  final bool bufferDelayEnabled;
  late TimeSync timeSync;
  late EventQueue<BEvent> _eventQueue;
  Completer<DateTime>? _timeSyncCompleter;
  Timer? _syncTimeTimer;

  bool _connected = false;

  void connect({
    void Function()? onConnected,
    void Function(String? reason)? onDisconnected,
    void Function()? onConnecting,
  }) {
    _socket = WebSocket(
      uri,
      protocols: protocols,
      pingInterval: pingInterval,
      headers: headers,
      backoff: backoff,
      timeout: timeout,
      binaryType: binaryType,
    );
    _socket.connection.listen((state) async {
      log('BonfireSocketClient: Connection state: $state');

      if (state is Connecting || state is Reconnecting) {
        onConnecting?.call();
      }

      if (state is Connected || state is Reconnected) {
        await _startSyncTimePing();
        _connected = true;
        onConnected?.call();
      }

      if (state is Disconnected && _connected) {
        _connected = false;
        _syncTimeTimer?.cancel();
        _syncTimeTimer = null;
        onDisconnected?.call(state.reason);
      }
    });
    _socket.messages.listen(_onMessageslListen);
  }

  void _onMessageslListen(dynamic message) {
    final event = _packer.unpackEvent(message.toString());
    if (_handleSyncTime(event)) {
      return;
    }
    _eventQueue.add(
      Frame(event, event.time),
    );
    if (debug) {
      log('BonfireSocketClient: ${event.toMap()}');
    }
  }

  void send<T>(String event, T message) {
    final e = BEvent(
      event: event,
      time: DateTime.now().microsecondsSinceEpoch,
      data: _packer.packData<T>(message),
    );
    _socket.send(_packer.packEvent(e));
  }

  void on<T>(String event, void Function(T event) callback) {
    _onSubscribers[event] = (map) {
      callback(_packer.unpackData<T>(map.data));
    };
  }

  void _onListernQueue(BEvent event) {
    _onSubscribers[event.event]?.call(event);
  }

  Future<void> _syncTime() async {
    if (_timeSyncCompleter != null) {
      return;
    }
    _timeSyncCompleter = Completer<DateTime>();
    await timeSync.synchronize(
      () {
        _sendPingSyncTime();
        return _timeSyncCompleter!.future;
      },
    );
  }

  Future<void> _startSyncTimePing() async {
    await _syncTime();
    _syncTimeTimer = Timer.periodic(
      syncTimeInterval,
      (timer) => _syncTime(),
    );
  }

  bool _handleSyncTime(BEvent event) {
    if (event.event == PongSyncTimeEvent.eventName) {
      _timeSyncCompleter?.complete(
        DateTime.fromMicrosecondsSinceEpoch(event.time),
      );
      _timeSyncCompleter = null;
      return true;
    }

    if (event.event == PingSyncTimeEvent.eventName) {
      _sendPongSyncTime();
      return true;
    }

    return false;
  }

  void _sendPingSyncTime() {
    final event = PingSyncTimeEvent();
    _socket.send(_packer.packEvent(event));
  }

  void _sendPongSyncTime() {
    final event = PongSyncTimeEvent();
    _socket.send(_packer.packEvent(event));
  }
}
