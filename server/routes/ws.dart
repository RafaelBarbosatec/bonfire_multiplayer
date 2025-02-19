import 'package:bonfire_socket_server/bonfire_socket_server.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return context.read<BonfireSocket>().handler(context);
}
