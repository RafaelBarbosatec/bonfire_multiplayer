import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import '../src/game/components/player.dart';
import '../src/core/game.dart';
import '../src/core/game_map.dart';

Response onRequest(RequestContext context) {
  // ignore: strict_raw_type
  final game = context.read<Game>();

  final resp = <String, dynamic>{};

  for (final comp in game.components) {
    if (comp is GameMap) {
      final players = comp.components
          .whereType<Player>()
          .map((e) => e.state)
          .map((e) => e.toMap())
          .toList();
      resp[comp.name] = players;
    }
  }

  return Response(body: jsonEncode(resp));
}
