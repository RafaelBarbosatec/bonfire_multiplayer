import 'package:bonfire_socket_server/src/socket_client.dart';

mixin BonfireSocketActions {
  void sendBroadcast<T>(String event, T message);
  void sendTo<T>(BSocketClient client, String event, T message);
}
