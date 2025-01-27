import 'package:shared_events/shared_events.dart';

import 'base/shape.dart';

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
}
