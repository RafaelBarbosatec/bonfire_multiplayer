// ignore_for_file: strict_raw_type

import 'dart:io';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:bonfire_socket_server/bonfire_socket_server.dart';
import 'package:dart_frog/dart_frog.dart';

import 'src/game/game_server.dart';
import 'src/game/maps/desert.dart';
import 'src/game/maps/florest.dart';
import 'src/infrastructure/logger/logger_logger.dart';
import 'src/infrastructure/logger/logger_provider.dart';
import 'src/infrastructure/websocket/bonfire_websocket.dart';
import 'src/infrastructure/websocket/websocket_provider.dart';
import 'src/injector.dart';

GameServer? game;
final LoggerProvider logger = LoggerLogger();
BonfireWebsocket? server;

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  if (server == null) {
    server = BonfireWebsocket();
    await server!.init(
      onClientConnect: onClientConnect,
      onClientDisconnect: onClientDisconnect,
    );
  }
  game ??= GameServer(
    server: server!,
    maps: [
      FlorestMap(),
      DesertMap(),
    ],
  );

  await game!.start();

  return serve(
    Injector.run(
      handler
          .use(
            provider<Game>(
              (context) => game!,
            ),
          )
          .use(
            provider<BonfireSocket>(
              (context) => server!.socket,
            ),
          ),
    ),
    ip,
    port,
  );
}

void onClientConnect(WebsocketClient client, WebsocketProvider websocket) {
  game?.enterClient(client);
}

void onClientDisconnect(WebsocketClient client) {
  game?.leaveClient(client);
}
