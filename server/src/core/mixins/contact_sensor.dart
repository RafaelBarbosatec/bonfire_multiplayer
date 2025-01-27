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
      final stop = onContact(other);
      final stop2 = other.onContact(this);
      if (stop && stop2) {
        onDidContact(other);
        other.onDidContact(this);
        return true;
      }
    }
    return false;
  }

  bool checkShapeContact(Shape otherSHape) {
    final myShape = getShapeContact();
    if (myShape == null) return false;
    return myShape.isCollision(otherSHape);
  }

  // return true if you can happen contact
  bool onContact(GameComponent comp) {
    return true;
  }

  void onDidContact(GameComponent comp) {}
}
