import 'package:shared_events/shared_events.dart';

import 'base/shape.dart';
import 'base/shape_collision.dart';
import 'polygon.dart';
import 'rectangle.dart';
import 'segment.dart';

class CircleShape extends Shape {
  CircleShape(this.radius, {GameVector? position})
      : center = (position ?? GameVector.zero()).translated(radius, radius),
        rect = RectangleShape(
          GameVector(x: 2 * radius, y: 2 * radius),
          position: position,
        ),
        super(position);

  final double radius;
  final RectangleShape rect;
  GameVector center;

  @override
  set position(GameVector value) {
    if (value != super.position) {
      super.position = value;
      rect.position = value;
      center = value.translated(radius, radius);
    }
  }

  @override
  String toString() {
    return 'CircleShape(position:$position, radius:$radius)';
  }

  @override
  bool collideWithCircle(CircleShape circle) {
    return ShapeCollision.circleToCircle(this, circle);
  }

  @override
  bool collideWithPolygon(PolygonShape polygon) {
    return ShapeCollision.circleToPolygon(this, polygon);
  }

  @override
  bool collideWithRectangle(RectangleShape rectangle) {
    return ShapeCollision.rectToCircle(rectangle, this);
  }

  @override
  bool collideWithSegment(SegmentShape segment) {
    return ShapeCollision.segmentToCircle(segment, this);
  }

  @override
  CircleShape translated(GameVector position) {
    return CircleShape(
      radius,
      position: this.position + position,
    );
  }
}
