// ignore_for_file: strict_raw_type

import 'dart:io';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:bonfire_socket_server/bonfire_socket_server.dart';
import 'package:dart_frog/dart_frog.dart';

import 'src/api/data/datasource/memory_datasource.dart';
import 'src/api/data/repositories/character_repository.dart';
import 'src/api/data/repositories/user_repository.dart';
import 'src/api/usecases/authenticator.dart';
import 'src/game/game_server.dart';
import 'src/game/maps/desert.dart';
import 'src/game/maps/florest.dart';
import 'src/infrastructure/logger/logger_logger.dart';
import 'src/infrastructure/logger/logger_provider.dart';
import 'src/infrastructure/websocket/bonfire_websocket.dart';
import 'src/infrastructure/websocket/websocket_provider.dart';
import 'src/injector.dart';
import 'src/server_type_injector.dart';

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
    injectServerTypes(server!);
  }
  // Shared in-memory datasource: the REST API (users/characters) and the
  // websocket join validation read/write the SAME data.
  final datasource = MemoryDatasource();
  final userRepository = UserRepository(datasource: datasource);
  final characterRepository = CharacterRepository(datasource: datasource);

  game ??= GameServer(
    server: server!,
    maps: [
      FlorestMap(),
      DesertMap(),
    ],
    characterRepository: characterRepository,
    authenticator: Authenticator(userRepository),
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
