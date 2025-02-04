import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';

mixin BonfireTypeAdapterProvider {
  final Map<String, BTypeAdapter<dynamic>> _types = {};

  Map<String, BTypeAdapter<dynamic>> get types => _types;

  void registerType<T>(BTypeAdapter<T> type) {
    _types[T.toString()] = type;
  }
}
