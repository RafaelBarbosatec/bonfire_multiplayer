import 'package:bonfire_socket_client/bonfire_socket_client.dart';

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
  void disconnect([int? code, String? reason]);

  /// Clock synchronization with the server. Used to convert server
  /// timestamps (e.g. ComponentStateModel.serverTimestamp) to the local
  /// timeline for jitter-free interpolation.
  TimeSync? get timeSync;
}

class TypeAdapter<T> {
  TypeAdapter({required this.toMap, required this.fromMap});

  final Map<String, dynamic> Function(T type) toMap;

  final T Function(Map<String, dynamic> map) fromMap;
}
