import 'package:shared_events/shared_events.dart';

import '../../main.dart';
import '../core/game_component.dart';
import '../core/game_map.dart';
import '../core/game_player.dart';
import '../core/game_sensor.dart';
import '../game/game_server.dart';
import '../util/game_ref.dart';

class MapGateway extends GameComponent
    with GameSensorContact, GameRef<GameServer> {
  MapGateway({
    required super.position,
    required this.size,
    required this.map,
    required this.playerPosition,
  }) {
    setupGameSensor(
      GameRectangle(
        position: GameVector.zero(),
        size: size,
      ),
    );
  }
  final GameVector size;
  final GameMap map;
  final GameVector playerPosition;

  @override
  bool onContact(GameComponent comp) {
    if (comp is GamePlayer) {
      comp
        ..position = playerPosition
        ..state.direction = null
        ..removeFromParent();
      map.add(comp);
      comp.send(
        EventType.JOIN_ACK.name,
        JoinAckEvent(
          state: comp.state,
          players: map.playersState,
          npcs: map.npcsState,
          map: MapModel(
            name: map.name,
            path: map.path,
          ),
        ),
      );
      logger.i(
        'Player(${comp.state.id}) change map {${comp.parent} to {$map}}',
      );
    }
    return super.onContact(comp);
  }
}
