import 'package:shared_events/shared_events.dart';

import '../geometry/circle.dart';
import '../positioned_game_component.dart';
import 'contact_sensor.dart';

mixin Vision<T extends ContactSensor> on PositionedGameComponent {
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
    if (_visionField == null) {
      _visionField = CircleShape(
        radiusVision,
        position: GameVector(
          x: center.x - radiusVision,
          y: center.y - radiusVision,
        ),
      );
    }

    final contacts = getShapeContacts(_visionField!).whereType<T>();
    if (contacts.isNotEmpty) {
      onFieldOfVision(contacts);
    }
    super.onUpdate(dt);
  }

  void onFieldOfVision(Iterable<T> components);
}
