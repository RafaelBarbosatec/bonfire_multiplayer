import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:polo_client/polo_client.dart';

class PoloWebsocket extends WebsocketProvider {
  PoloClient? _client;
  final String address;
  final int port;
  bool _connected = false;
  bool get connected => _connected;
  final int countReconnect;
  int _countTryReconnect = 0;

  List<void Function()> onConnectSubscribers = [];
  List<void Function()> onDisconnectSubscribers = [];

  PoloWebsocket({
    required this.address,
    this.port = 3000,
    this.countReconnect = 5,
  });

  @override
  Future<void> init({
    void Function()? onConnect,
    void Function()? onDisconnect,
  }) async {
    try {
      _client = await Polo.connect("ws://$address:$port");
      _client?.onConnect(() {
        _countTryReconnect = 0;
        _connected = true;
        if (kDebugMode) {
          print("Client Connected to Server");
        }
        onConnect?.call();
        for (var sub in onConnectSubscribers) {
          sub();
        }
      });

      _client?.onDisconnect(() {
        _connected = false;
        if (kDebugMode) {
          print("Client Disconnected from Server");
        }
        onDisconnect?.call();
        for (var sub in onDisconnectSubscribers) {
          sub();
        }
      });
      _client?.listen();
    } catch (e) {
      print('Error connection: $e');
      _tryReconnect(onConnect: onConnect, onDisconnect: onDisconnect);
    }
  }

  @override
  void onEvent<T>(String event, void Function(T data) callback) {
    _client?.onEvent<T>(event, callback);
  }

  @override
  void send<T>(String event, T data) {
    _client?.send(event, data);
  }

  @override
  void onConnect(void Function() onConnect) {
    onConnectSubscribers.add(onConnect);
  }

  @override
  void onDisconnect(void Function() onDisconnect) {
    onDisconnectSubscribers.add(onDisconnect);
  }

  @override
  void registerType<T>(TypeAdapter<T> type) {
    _client?.registerType<T>(
      PoloTypeAdapter<T>(
        toMap: type.toMap,
        fromMap: type.fromMap,
      ),
    );
  }

  void _tryReconnect({
    void Function()? onConnect,
    void Function()? onDisconnect,
  }) async {
    if (_countTryReconnect < countReconnect) {
      _countTryReconnect++;
      await Future.delayed(const Duration(seconds: 4));
      if (kDebugMode) {
        print('Try reconnecting $_countTryReconnect');
      }
      init(onConnect: onConnect, onDisconnect: onDisconnect);
    } else {
      if (kDebugMode) {
        print('Failure to try connecting.');
      }
    }
  }
}
