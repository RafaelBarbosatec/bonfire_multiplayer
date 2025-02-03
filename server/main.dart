// ignore_for_file: strict_raw_type

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import 'src/core/game.dart';
import 'src/game/game_server.dart';
import 'src/game/maps/desert.dart';
import 'src/game/maps/florest.dart';
import 'src/infrastructure/logger/logger_logger.dart';
import 'src/infrastructure/logger/logger_provider.dart';
import 'src/infrastructure/websocket/polo_websocket.dart';
import 'src/infrastructure/websocket/websocket_provider.dart';

GameServer? game;
final LoggerProvider logger = LoggerLogger();

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // final socket = BonfireSocket(onClientConnect: (client) {
  //   client.on<TestEvent>(
  //     'oi',
  //     (event) {
  //       print(event);
  //       print(event.toMap());
  //     },
  //   );

  //   client.on(
  //     'ola',
  //     (event) {
  //       print(event.runtimeType);
  //       print('ola: $event');
  //     },
  //   );
  // });
  // socket.registerType<TestEvent>(
  //   BTypeAdapter<TestEvent>(
  //     toMap: (type) => type.toMap(),
  //     fromMap: (map) => TestEvent.fromMap(map),
  //   ),
  // );
  final server = await PoloWebsocket().init(
    onClientConnect: onClientConnect,
    onClientDisconnect: onClientDisconnect,
  );
  game ??= GameServer(
    server: server,
    maps: [
      FlorestMap(),
      DesertMap(),
    ],
  );
  await game!.start();

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
