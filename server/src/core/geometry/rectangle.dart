import 'package:shared_events/shared_events.dart';

import 'base/shape.dart';

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
}
