import '../game_component.dart';
import '../geometry/base/extensions.dart';
import '../geometry/base/shape.dart';
import '../positioned_game_component.dart';

mixin ContactSensor on PositionedGameComponent {
  Shape? _shape;
  // ignore: use_setters_to_change_properties
  void setupGameSensor(Shape shape) {
    _shape = shape;
  }

  Shape? getShapeContact() => _shape?.translated(position);

  bool checkContact(ContactSensor other) {
    final myShape = getShapeContact();
    if (myShape == null) return false;
    final otherSHape = other.getShapeContact();
    if (otherSHape == null) return false;
    if (myShape.isCollision(otherSHape)) {
      final stop = checkIfNotifyContact(other);
      final stop2 = other.checkIfNotifyContact(this);
      if (stop && stop2) {
        onContact(other);
        other.onContact(this);
        return true;
      }
    }
    return false;
  }

  bool checkIfNotifyContact(GameComponent comp) {
    return true;
  }

  void onContact(GameComponent comp) {}
}
