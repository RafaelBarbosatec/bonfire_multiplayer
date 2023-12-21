import 'package:dart_frog/dart_frog.dart';

import '../src/core/game.dart';

Future<Response> onRequest(RequestContext context) async {
  // ignore: strict_raw_type
  final game = context.read<Game>();
  return Response(
    body: 'Welcome Game Server\n ${game.components.length} players online.',
  );
}
