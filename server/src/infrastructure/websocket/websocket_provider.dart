typedef OnClientConnect<T> = void Function(
  T client,
  WebsocketProvider<T> server,
);

typedef OnClientDisconnect<T> = void Function(
  T client,
);

abstract class WebsocketProvider<C> {
  Future<WebsocketProvider<C>> init({
    required OnClientConnect<C> onClientConnect,
    required OnClientDisconnect<C> onClientDisconnect,
  });

  void send<T>(String event, T data);
  void sendToClient<T>(C client, String event, T data);
  void sendToRoom<T>(String room, String event, T data);
  void broadcastFrom<T>(C client, String event, T data);
  void registerType<T>(TypeAdapter<T> type);
}

class TypeAdapter<T> {
  TypeAdapter({required this.toMap, required this.fromMap});

  final Map<String, dynamic> Function(T type) toMap;

  final T Function(Map<String, dynamic> map) fromMap;
}
