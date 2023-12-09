import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:polo_client/polo_client.dart';

class PoloWebsocket extends WebsocketProvider {
  PoloClient? _client;
  final String address;
  final int port;
  bool _connected = false;
  bool get connected => _connected;

  List<void Function()> onConnectSubscribers = [];
  List<void Function()> onDisconnectSubscribers = [];

  PoloWebsocket({required this.address, this.port = 3000});

  @override
  Future<void> init({
    void Function()? onConnect,
    void Function()? onDisconnect,
  }) async {
    _client = await Polo.connect("ws://$address:$port");
    _client?.onConnect(() {
      _connected = true;
      print("Client Connected to Server");
      onConnect?.call();
      for (var sub in onConnectSubscribers) {
        sub();
      }
    });

    _client?.onDisconnect(() {
      _connected = false;
      print("Client Disconnected from Server");
      onDisconnect?.call();
      for (var sub in onDisconnectSubscribers) {
        sub();
      }
    });
    _client?.listen();
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
}
