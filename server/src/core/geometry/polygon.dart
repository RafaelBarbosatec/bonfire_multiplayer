import 'package:shared_events/shared_events.dart';

import 'base/shape.dart';
import 'rectangle.dart';

class PolygonShape extends Shape {
  PolygonShape(this.relativePoints, {GameVector? position})
      : assert(relativePoints.length > 2, 'Is necessary min 2 points'),
        points = _initPoints(relativePoints, position ?? GameVector.zero()),
        rect = _initRect(relativePoints, position ?? GameVector.zero()),
        super(position) {
    _minX = rect.position.x - (position?.x ?? 0);
    _minY = rect.position.y - (position?.y ?? 0);
  }
  final List<GameVector> relativePoints;
  final List<GameVector> points;
  final RectangleShape rect;
  double _minX = 0;
  double _minY = 0;

  static List<GameVector> _initPoints(
    List<GameVector> relativePoints,
    GameVector position,
  ) {
    final list = <GameVector>[];
    for (var i = 0; i < relativePoints.length; i++) {
      list.add(relativePoints[i] + position);
    }
    return list;
  }

  static RectangleShape _initRect(
    List<GameVector> relativePoints,
    GameVector position,
  ) {
    var height = 0.0;
    var width = 0.0;

    var minX = relativePoints.first.x;
    var maxX = relativePoints.first.x;

    var minY = relativePoints.first.y;
    var maxY = relativePoints.first.y;
    for (final offset in relativePoints) {
      if (offset.x < minX) {
        minX = offset.x;
      }
      if (offset.x > maxX) {
        maxX = offset.x;
      }
      if (offset.y < minY) {
        minY = offset.y;
      }
      if (offset.y > maxY) {
        maxY = offset.y;
      }
    }

    height = maxY - minY;
    width = maxX - minX;

    return RectangleShape(
      GameVector(x: width, y: height),
      position: GameVector(x: position.x + minX, y: position.y + minY),
    );
  }

  @override
  set position(GameVector value) {
    if (value != position) {
      super.position = value;

      for (var i = 0; i < points.length; i++) {
        points[i] = relativePoints[i] + value;
      }

      rect.position = GameVector(x: value.x + _minX, y: value.y + _minY);
    }
  }
}
