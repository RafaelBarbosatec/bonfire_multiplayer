import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:shared_events/shared_events.dart';

import '../src/game/game.dart';

Response onRequest(RequestContext context) {
  // ignore: strict_raw_type
  final game = context.read<Game>();
  final players = game.players().cast<PlayerStateModel>();
  return Response(body: jsonEncode(players.map((e) => e.toMap()).toList()));
}
