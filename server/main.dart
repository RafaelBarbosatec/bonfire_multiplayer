import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import 'src/game/game_impl.dart';
import 'src/infrastructure/logger/logger_logger.dart';
import 'src/infrastructure/logger/logger_provider.dart';
import 'src/infrastructure/websocket_manager.dart';

GameImpl? game;
final LoggerProvider logger = LoggerLogger();

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final server = await WebsocketManager().init(
    onClientConnect: onClientConnect,
    onClientDisconnect: onClientDisconnect,
  );
  game ??= GameImpl(server: server)..start();
  return serve(handler, ip, port);
}

void onClientConnect(PoloClient client, WebsocketManager websocket) {
  game?.enterPlayer(client);
}

void onClientDisconnect(PoloClient client) {
  game?.leavePlayer(client);
}
