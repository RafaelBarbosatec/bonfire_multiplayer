import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../../main.dart';
import '../game_server.dart';

class MapGateway extends PositionedGameComponent
    with Collision, GameRef<GameServer> {
  MapGateway({
    required super.position,
    required super.size,
    required this.mapTagetId,
    required this.targetPlayerPosition,
  }) {
    setupCollision(
      RectangleShape(
        size,
      ),
    );
  }
  final String mapTagetId;
  final GameVector targetPlayerPosition;

  @override
  bool onContact(GameComponent comp) {
    if (comp is GamePlayer) {
      logger.i(
        'Player(${comp.state.id}) change map {${comp.parent} to {$mapTagetId}}',
      );
      final success = game?.changeMap(
            comp,
            mapTagetId,
            targetPlayerPosition.clone(),
          ) ??
          false;
      if (!success) {
        logger.e('Not found map: $mapTagetId');
      }
      return false;
    }
    return true;
  }
}
