import 'package:dart_frog/dart_frog.dart';

import '../src/core/game.dart';
import '../src/core/game_map.dart';
import '../src/components/player.dart';

Future<Response> onRequest(RequestContext context) async {
  // ignore: strict_raw_type
  final game = context.read<Game>();

  var countMap = 0;
  var countPlayers = 0;

  for (final comp in game.components) {
    if (comp is GameMap) {
      final players = comp.components
          .whereType<Player>()
          .map((e) => e.state)
          .map((e) => e.toMap());
      countPlayers += players.length;
      countMap++;
    }
  }

  return Response(
    body:
        'Welcome Game Server\n $countMap maps \n $countPlayers players online.',
  );
}
