import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../components/map_gateway.dart';
import '../components/my_enemy.dart';
import '../game_server.dart';

class DesertMap extends GameMap with GameRef<GameServer> {
  DesertMap({
    super.id = 'desertId',
    super.name = 'desert',
    super.path = 'maps/map2/desert.tmj',
  });

  @override
  void onObjectBuilder(GameMapObjectProperties object) {
    switch (object.typeOrClass) {
      case 'enemy':
        add(
          MyEnemy(
            state: ComponentStateModel(
              id: object.id.toString(),
              name: 'Enemy',
              position: object.position,
              size: object.size,
              life: 100,
              speed: 25,
              properties: {
                'skin': 'girl',
              },
            ),
          ),
        );
      case 'gateway':
        add(
          MapGateway(
            position: object.position,
            size: object.size,
            mapTagetId: object.properties['mapId'].toString(),
            targetPlayerPosition: GameVector(
              x: double.parse(object.properties['x'].toString()),
              y: double.parse(object.properties['y'].toString()),
            ),
          ),
        );
    }
  }
}
