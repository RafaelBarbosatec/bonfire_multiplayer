import 'package:flutter/foundation.dart';
import 'package:polo_client/polo_client.dart';

class MyWebsocket {
  PoloClient? _client;
  final String address;
  final int port;

  bool _connected = false;
  bool get connected => _connected;

  MyWebsocket({required this.address, this.port = 3000});

  Future<MyWebsocket> init({
    void Function()? onConnect,
    void Function()? onDisconnect,
  }) async {
    _client = await Polo.connect("ws://10.0.2.2:$port/");
    _client?.onConnect(() {
      _connected = true;
      if (kDebugMode) {
        print("Client Connected to Server");
      }
      onConnect?.call();
    });

    _client?.onDisconnect(() {
      _connected = false;
      if (kDebugMode) {
        print("Client Disconnected from Server");
      }
      onDisconnect?.call();
    });

    _client?.listen();
    return this;
  }

  void onEvent<T>(String event, void Function(T data) callback) {
    _client?.onEvent<T>(event, callback);
  }

  void send<T>(String event, T data) {
    _client?.send(event, data);
  }
}
