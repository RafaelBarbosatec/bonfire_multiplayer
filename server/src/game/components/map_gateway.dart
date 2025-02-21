import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../../main.dart';
import '../game_server.dart';

class MapGateway extends PositionedGameComponent
    with ContactSensor, GameRef<GameServer> {
  MapGateway({
    required super.position,
    required super.size,
    required this.mapTagetId,
    required this.targetPlayerPosition,
  }) {
    setupGameSensor(
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
      game?.changeMap(
        comp,
        mapTagetId,
        targetPlayerPosition.clone(),
      );
      return false;
    }
    return true;
  }
}
