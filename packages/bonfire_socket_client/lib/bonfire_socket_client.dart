// ignore_for_file: public_member_api_docs

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
  }) {
    this.serializer = serializer ?? EventSerializerDefault();
    _packer = EventPacker(
      serializerProvider: this,
      typeAdapterProvider: this,
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

  Future<void> connect({
    void Function()? onConnected,
    void Function(String? reason)? onDisconnected,
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
      log('BonfireSocketClient: Connection state: $state');
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
    final event = _packer.unpackEvent(message.toString());
    _onSubscribers[event.event]?.call(event);
    if (debug) {
      log('BonfireSocketClient: ${event.toMap()}');
    }
  }

  void send<T>(String event, T message) {
    final e = BEvent(
      event: event,
      data: _packer.packData<T>(message),
    );
    _socket.send(_packer.packEvent<T>(e));
  }

  void on<T>(String event, void Function(T event) callback) {
    _onSubscribers[event] = (map) {
      callback(_packer.unpackData<T>(map.data));
    };
  }
}
