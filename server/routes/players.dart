import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import '../src/core/game.dart';
import '../src/game/player.dart';

Response onRequest(RequestContext context) {
  // ignore: strict_raw_type
  final game = context.read<Game>();
  final players = game.components.whereType<Player>().map((e) => e.state);
  return Response(body: jsonEncode(players.map((e) => e.toMap()).toList()));
}
