// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import '../game/player.dart';
import '../util/game_position.dart';

class JoinAckEvent {
  JoinAckEvent({
    required this.id,
    required this.name,
    required this.skin,
    required this.position,
    required this.players,
  });

  final String id;
  final String name;
  final String skin;
  final GamePosition position;
  final List<Player> players;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'skin': skin,
      'position': position.toMap(),
      'players': players.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}
