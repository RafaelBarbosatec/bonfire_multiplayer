import 'package:shared_events/shared_events.dart';

import '../game_component.dart';

mixin ContactSensor on GameComponent {
  GameRectangle _sensorRectangle = GameRectangle.zero();
  // ignore: use_setters_to_change_properties
  void setupGameSensor(GameRectangle rect) {
    _sensorRectangle = rect;
  }

  GameRectangle getRectContact() => GameRectangle(
        position: GameVector(
          x: position.x + _sensorRectangle.position.x,
          y: position.y + _sensorRectangle.position.y,
        ),
        size: _sensorRectangle.size,
      );

  bool checkCollision(ContactSensor other) {
    if (getRectContact().overlaps(other.getRectContact())) {
      final stop = onContact(other);
      final stop2 = other.onContact(this);
      return stop || stop2;
    }
    return false;
  }

  bool onContact(GameComponent comp) {
    return false;
  }
}
