import 'package:shared_events/shared_events.dart';

import '../../components/map_gateway.dart';
import '../../core/game_map.dart';
import '../../util/game_map_object_properties.dart';
import '../../util/game_ref.dart';
import '../game_server.dart';

class FlorestMap extends GameMap with GameRef<GameServer> {
  FlorestMap({super.name = 'florest', super.path = 'maps/map1/florest.tmj'});

  @override
  void onObjectBuilder(GameMapObjectProperties object) {
    if (object.typeOrClass == 'gateway') {
      add(
        MapGateway(
          position: object.position,
          size: object.size,
          map: game.maps.firstWhere(
            (m) => m.name == object.properties['map'].toString(),
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
