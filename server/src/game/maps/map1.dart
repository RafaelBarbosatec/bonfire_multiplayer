import '../../core/game_map.dart';
import '../../util/game_map_object.dart';
import '../../util/game_ref.dart';
import '../game_server.dart';

class Map1 extends GameMap with GameRef<GameServer> {
  Map1({super.name = 'map1', super.path = 'maps/map1/map.tmj'});

  @override
  void onObjectBuilder(GameMapObject object) {
    // TODO: implement onObjectBuild
  }
}
