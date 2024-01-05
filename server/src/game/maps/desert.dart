import 'package:shared_events/shared_events.dart';

import '../../core/game_map.dart';
import '../../util/game_map_object_properties.dart';
import '../../util/game_ref.dart';
import '../components/map_gateway.dart';
import '../game_server.dart';

class DesertMap extends GameMap with GameRef<GameServer> {
  DesertMap({
    super.id = 'desertId',
    super.name = 'desert',
    super.path = 'maps/map2/desert.tmj',
  });

  @override
  void onObjectBuilder(GameMapObjectProperties object) {
    if (object.typeOrClass == 'gateway') {
      add(
        MapGateway(
          position: object.position,
          size: object.size,
          map: game.maps.firstWhere(
            (m) => m.id == object.properties['mapId'].toString(),
          ),
          playerPosition: GameVector(
            x: double.parse(object.properties['x'].toString()),
            y: double.parse(object.properties['y'].toString()),
          ),
        ),
      );
    }
  }
}
