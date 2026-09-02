import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

extension MyGameExtension on Game {
  bool changeMap(GamePlayer player, String newMapId, GameVector position) {
    try {
      final map = maps.firstWhere((element) => element.id == newMapId);

      player
        ..position = position
        ..stopMove()
        ..removeFromParent();

      map.add(player);
      onPlayerChangeMap(player, map);
      return true;
    } catch (e) {
      return false;
    }
  }
}
