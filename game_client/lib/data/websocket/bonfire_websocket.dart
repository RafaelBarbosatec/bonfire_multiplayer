import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:bonfire_socket_client/bonfire_socket_client.dart';
import 'package:flutter/foundation.dart';

class BonfireWebsocket extends WebsocketProvider {
  BonfireSocketClient? _client;
  final Uri address;

  bool _connected = false;
  bool get connected => _connected;

  void Function()? onConnectSubscriber;
  void Function()? onDisconnectSubscriber;
  BonfireWebsocket({
    required this.address,
  });

  @override
  Future<void> init({
    void Function()? onConnect,
    void Function()? onDisconnect,
  }) async {
    _client = BonfireSocketClient(
      uri: address,
    );
    _client?.connect(onConnected: () {
      _connected = true;
      if (kDebugMode) {
        print("Client Connected to Server");
      }
      onConnect?.call();
      onConnectSubscriber?.call();
    }, onDisconnected: (reason) {
      _connected = false;
      if (kDebugMode) {
        print("Client Disconnected from Server: $reason");
      }
      onDisconnect?.call();
      onDisconnectSubscriber?.call();
    });
  }

  @override
  void onEvent<T>(String event, void Function(T data) callback) {
    _client?.on<T>(event, callback);
  }

  @override
  void send<T>(String event, T data) {
    _client?.send(event, data);
  }

  @override
  void onConnect(void Function() onConnect) {
    onConnectSubscriber = onConnect;
  }

  @override
  void onDisconnect(void Function() onDisconnect) {
    onDisconnectSubscriber = onDisconnect;
  }

  @override
  void registerType<T>(TypeAdapter<T> type) {
    _client?.registerType<T>(
      BTypeAdapter<T>(
        toMap: type.toMap,
        fromMap: type.fromMap,
      ),
    );
  }
}
