import 'package:bonfire_server/src/geometry/circle.dart';
import 'package:bonfire_server/src/geometry/polygon.dart';
import 'package:bonfire_server/src/geometry/rectangle.dart';
import 'package:bonfire_server/src/geometry/segment.dart';
import 'package:shared_events/shared_events.dart';

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
