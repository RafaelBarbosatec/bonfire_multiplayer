import 'package:shared_events/shared_events.dart';

import '../../../main.dart';
import '../../core/game_component.dart';
import '../../core/game_player.dart';
import '../../core/geometry/rectangle.dart';
import '../../core/mixins/contact_sensor.dart';
import '../../core/mixins/game_ref.dart';
import '../../core/positioned_game_component.dart';
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
      comp
        ..position = targetPlayerPosition.clone()
        ..stopMove()
        ..removeFromParent();
      game?.changeMap(comp, mapTagetId);
      return false;
    }
    return true;
  }
}
