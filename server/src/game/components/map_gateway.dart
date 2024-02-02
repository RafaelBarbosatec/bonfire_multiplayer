import 'package:shared_events/shared_events.dart';

import '../../../main.dart';
import '../../core/game_component.dart';
import '../../core/game_map.dart';
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
    required this.map,
    required this.playerPosition,
  }) {
    setupGameSensor(
      RectangleShape(
        size,
      ),
    );
  }
  final GameMap map;
  final GameVector playerPosition;

  @override
  bool checkIfNotifyContact(GameComponent comp) {
    if (comp is GamePlayer) {
      logger.i(
        'Player(${comp.state.id}) change map {${comp.parent} to {$map}}',
      );
      comp
        ..position = playerPosition.clone()
        ..state.direction = null
        ..removeFromParent();
      map.add(comp);
      comp.send(
        EventType.JOIN_MAP.name,
        JoinMapEvent(
          state: comp.state,
          players: map.playersState,
          npcs: map.npcsState,
          map: map.toModel(),
        ),
      );
    }
    return false;
  }
}
