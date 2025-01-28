import 'package:shared_events/shared_events.dart';

import '../circle.dart';
import '../polygon.dart';
import '../rectangle.dart';
import '../segment.dart';

abstract class Shape {
  Shape(GameVector? position) : position = position ?? GameVector.zero();
  GameVector position;

  bool collidesWith(Shape other) {
    switch (other.runtimeType) {
      case CircleShape:
        return collideWithCircle(other as CircleShape);
      case PolygonShape:
        return collideWithPolygon(other as PolygonShape);
      case RectangleShape:
        return collideWithRectangle(other as RectangleShape);
      case SegmentShape:
        return collideWithSegment(other as SegmentShape);
      default:
        throw UnimplementedError();
    }
  }

  bool collideWithCircle(CircleShape circle);
  bool collideWithRectangle(RectangleShape rectangle);
  bool collideWithPolygon(PolygonShape polygon);
  bool collideWithSegment(SegmentShape segment);

  Shape translated(GameVector position);
}
