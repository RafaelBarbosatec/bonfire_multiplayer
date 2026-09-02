import 'package:bonfire_server/src/geometry/base/shape.dart';
import 'package:bonfire_server/src/geometry/base/shape_collision.dart';
import 'package:bonfire_server/src/geometry/circle.dart';
import 'package:bonfire_server/src/geometry/polygon.dart';
import 'package:bonfire_server/src/geometry/segment.dart';
import 'package:shared_events/shared_events.dart';

class RectangleShape extends Shape {
  RectangleShape(GameVector size, {GameVector? position})
      : _rect = GameRect(
          size: size,
        ),
        super(position) {
    _updateExtremities(this.position);
  }
  GameRect _rect;
  late GameVector leftTop;
  late GameVector rightTop;
  late GameVector rightBottom;
  late GameVector leftBottom;

  @override
  set position(GameVector value) {
    if (value != super.position) {
      super.position = value;
      _updateExtremities(value);
    }
  }

  void _updateExtremities(GameVector value) {
    _rect = GameRect(
      position: value,
      size: _rect.size,
    );
    leftTop = _rect.topLeft;
    rightTop = _rect.topRight;
    rightBottom = _rect.bottomRight;
    leftBottom = _rect.bottomLeft;
  }

  GameRect get rect => _rect;
  GameVector get size => _rect.size;

  double get height => _rect.size.y;
  double get width => _rect.size.x;
  double get left => _rect.left;
  double get top => _rect.top;
  double get right => _rect.right;
  double get bottom => _rect.bottom;

  @override
  String toString() {
    return 'RectangleShape(position:$position, size:$size)';
  }

  @override
  bool collideWithCircle(CircleShape circle) {
    return ShapeCollision.rectToCircle(this, circle);
  }

  @override
  bool collideWithPolygon(PolygonShape polygon) {
    return ShapeCollision.rectToPolygon(this, polygon);
  }

  @override
  bool collideWithRectangle(RectangleShape rectangle) {
    return ShapeCollision.rectToRect(this, rectangle);
  }

  @override
  bool collideWithSegment(SegmentShape segment) {
    return ShapeCollision.rectToSegment(this, segment);
  }

  @override
  RectangleShape translated(GameVector position) {
    return RectangleShape(
      size,
      position: this.position + position,
    );
  }
}
