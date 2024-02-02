import 'package:shared_events/shared_events.dart';

import '../circle.dart';
import '../polygon.dart';
import '../rectangle.dart';
import 'shape.dart';
import 'shape_collision.dart';

extension ShapeExt on Shape {
  bool isCollision(Shape b) {
    return ShapeCollision.isCollision(this, b);
  }

  Shape translated(GameVector position) {
    return switch (runtimeType) {
      RectangleShape => RectangleShape(
          (this as RectangleShape).size,
          position: this.position + position,
        ),
      PolygonShape => PolygonShape(
          (this as PolygonShape).relativePoints,
          position: this.position + position,
        ),
      CircleShape => CircleShape(
          (this as CircleShape).radius,
          position: this.position + position,
        ),
      _ => this
    };
  }
}
