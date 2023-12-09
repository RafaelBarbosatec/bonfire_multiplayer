abstract class WebsocketProvider {
  Future<void> init({
    void Function()? onConnect,
    void Function()? onDisconnect,
  });
  void onConnect(void Function() onConnect);
  void onDisconnect(void Function() onDisconnect);
  void onEvent<T>(String event, void Function(T data) callback);
  void send<T>(String event, T data);
  void registerType<T>(TypeAdapter<T> type);
}

class TypeAdapter<T> {
  TypeAdapter({required this.toMap, required this.fromMap});

  final Map<String, dynamic> Function(T type) toMap;

  final T Function(Map<String, dynamic> map) fromMap;
}
