import 'package:bonfire/bonfire.dart';
import 'package:shared_events/shared_events.dart';

extension GamePositionExt on GamePosition {
  Vector2 toVector2() {
    return Vector2(x, y);
  }
}

extension Vector2Ext on Vector2 {
  GamePosition toGamePosition() {
    return GamePosition(x: x, y: y);
  }
}
