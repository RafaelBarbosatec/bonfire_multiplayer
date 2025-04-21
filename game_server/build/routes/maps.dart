import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import '../src/core/game.dart';
import '../src/core/game_map.dart';

Response onRequest(RequestContext context) {
  // ignore: strict_raw_type
  final game = context.read<Game>();

  final resp = <Map<String, dynamic>>[];

  for (final comp in game.components) {
    if (comp is GameMap) {
      resp.add(comp.toModel().toMap());
    }
  }

  return Response(body: jsonEncode(resp));
}
