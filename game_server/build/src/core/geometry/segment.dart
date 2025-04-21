import 'package:shared_events/shared_events.dart';

import 'base/shape.dart';
import 'base/shape_collision.dart';
import 'circle.dart';
import 'polygon.dart';
import 'rectangle.dart';

class SegmentShape extends Shape {
  final GameVector start;
  final GameVector end;
  SegmentShape(GameVector start, GameVector end, {GameVector? position})
      : start = start + (position ?? GameVector.zero()),
        end = end + (position ?? GameVector.zero()),
        super(
          position ??
              GameVector(
                x: start.x,
                y: start.y,
              ),
        );

  @override
  set position(GameVector value) {
    if (value != super.position) {
      start.x += (super.position.x - value.x);
      start.y = (super.position.y - value.y);
      end.x = (super.position.x - value.x);
      end.y = (super.position.y - value.y);
      super.position = value;
    }
  }

  @override
  bool collideWithCircle(CircleShape circle) {
    return ShapeCollision.segmentToCircle(this, circle);
  }

  @override
  bool collideWithPolygon(PolygonShape polygon) {
    return ShapeCollision.segmentToPolygon(this, polygon);
  }

  @override
  bool collideWithRectangle(RectangleShape rectangle) {
    return ShapeCollision.rectToSegment(rectangle, this);
  }

  @override
  bool collideWithSegment(SegmentShape segment) {
    return ShapeCollision.segmentToSegment(this, segment);
  }

  @override
  SegmentShape translated(GameVector position) {
    return SegmentShape(
      start,
      end,
      position: this.position + position,
    );
  }
}
