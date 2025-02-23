import 'package:bonfire_server/src/components/positioned_game_component.dart';
import 'package:bonfire_server/src/geometry/circle.dart';
import 'package:bonfire_server/src/mixins/contact_sensor.dart';
import 'package:shared_events/shared_events.dart';

mixin Vision<T extends Collision> on PositionedGameComponent {
  CircleShape? _visionField;

  double get radiusVision;

  @override
  set position(GameVector position) {
    super.position = position;
    _visionField?.position = GameVector(
      x: center.x - radiusVision,
      y: center.y - radiusVision,
    );
  }

  @override
  void onUpdate(double dt) {
    _visionField ??= CircleShape(
      radiusVision,
      position: GameVector(
        x: center.x - radiusVision,
        y: center.y - radiusVision,
      ),
    );

    final contacts = getShapeContacts(_visionField!).whereType<T>();
    if (contacts.isNotEmpty) {
      onFieldOfVision(contacts);
    }
    super.onUpdate(dt);
  }

  void onFieldOfVision(Iterable<T> components);
}
