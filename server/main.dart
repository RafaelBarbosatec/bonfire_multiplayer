// ignore_for_file: strict_raw_type

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import 'src/core/game.dart';
import 'src/game/game_server.dart';
import 'src/infrastructure/logger/logger_logger.dart';
import 'src/infrastructure/logger/logger_provider.dart';
import 'src/infrastructure/websocket/polo_websocket.dart';
import 'src/infrastructure/websocket/websocket_provider.dart';

GameServer? game;
final LoggerProvider logger = LoggerLogger();

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final server = await PoloWebsocket().init(
    onClientConnect: onClientConnect,
    onClientDisconnect: onClientDisconnect,
  );
  game ??= GameServer(server: server)..start();

  return serve(
    handler.use(
      provider<Game>(
        (context) => game!,
      ),
    ),
    ip,
    port,
  );
}

void onClientConnect(PoloClient client, WebsocketProvider websocket) {
  game?.enterClient(client);
}

void onClientDisconnect(PoloClient client) {
  game?.leaveClient(client);
}
