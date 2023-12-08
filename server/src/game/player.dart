// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import '../infrastructure/websocket_manager.dart';
import '../model/move_event.dart';
import '../util/event_type.dart';
import '../util/game_position.dart';

class Player {
  Player({
    required this.id,
    required this.name,
    required this.skin,
    required this.position,
    required this.life,
    required this.client,
  }) {
    initPosition = position.clone();
  }

  final String id;
  final String name;
  final String skin;
  final GamePosition position;
  final PoloClient client;
  final int life;
  late Point<double> initPosition;

  void configure(WebsocketManager server) {
    _confMove(server);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'skin': skin,
      'position': position.toMap(),
      'life': life,
    };
  }

  void _confMove(WebsocketManager server) {
    client.onEvent<MoveEvent>(EventType.PLAYER_MOVE.name, (data) {
      final event = data.toMap()
        ..addAll({
          'playerId': id,
        });
      server.broadcastFrom(
        client,
        EventType.PLAYER_MOVE.name,
        event,
      );
    });
  }
}
