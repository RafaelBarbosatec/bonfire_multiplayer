import 'package:bonfire_server/src/components/game_component.dart';
import 'package:bonfire_server/src/components/positioned_game_component.dart';
import 'package:bonfire_server/src/geometry/base/shape.dart';

mixin Collision on PositionedGameComponent {
  Shape? _shape;
  // ignore: use_setters_to_change_properties
  void setupCollision(Shape shape) {
    _shape = shape;
  }

  Shape? getShapeContact() => _shape?.translated(position);

  bool checkContact(Collision other) {
    final myShape = getShapeContact();
    if (myShape == null) return false;
    final otherSHape = other.getShapeContact();
    if (otherSHape == null) return false;
    if (myShape.collidesWith(otherSHape)) {
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
    return myShape.collidesWith(otherSHape);
  }

  // return true if you can happen contact
  bool onContact(GameComponent comp) {
    return true;
  }

  void onDidContact(GameComponent comp) {}
}
