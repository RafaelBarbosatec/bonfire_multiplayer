import 'dart:math';

import 'package:shared_events/shared_events.dart';

import '../circle.dart';
import '../polygon.dart';
import '../rectangle.dart';
import '../segment.dart';

/// Class responsible to verify collision of the Shapes.
/// Code based from: https://github.com/hahafather007/collision_check
class ShapeCollision {
  static bool rectToRect(RectangleShape a, RectangleShape b) {
    return a.rect.overlaps(b.rect);
  }

  static bool rectToCircle(RectangleShape a, CircleShape b) {
    if (!rectToRect(a, b.rect)) return false;

    final points = [
      a.leftTop,
      a.rightTop,
      a.rightBottom,
      a.leftBottom,
      a.leftTop,
    ];
    for (var i = 0; i < points.length - 1; i++) {
      final distance = getNearestDistance(points[i], points[i + 1], b.center);
      if (_getFixDouble(distance) <= b.radius) return true;
    }

    return false;
  }

  static bool rectToPolygon(RectangleShape a, PolygonShape b) {
    if (!rectToRect(a, b.rect)) return false;

    if (!isLinesShadowOver(
      a.leftTop,
      a.rightBottom,
      b.rect.leftTop,
      b.rect.rightBottom,
    )) {
      return false;
    }

    if (polygonPoint(b, a.position)) {
      return true;
    }

    final pointsA = [
      a.leftTop,
      a.rightTop,
      a.rightBottom,
      a.leftBottom,
      a.leftTop,
    ];
    final pointsB = b.points.toList()..add(b.points.first);

    for (var i = 0; i < pointsA.length - 1; i++) {
      final pointA = pointsA[i];
      final pointB = pointsA[i + 1];
      for (var j = 0; j < pointsB.length - 1; j++) {
        final pointC = pointsB[j];
        final pointD = pointsB[j + 1];

        if (!isLinesShadowOver(pointA, pointB, pointC, pointD)) {
          continue;
        }

        if (isLinesOver(pointA, pointB, pointC, pointD)) {
          return true;
        }
      }
    }

    return false;
  }

  static bool circleToCircle(CircleShape a, CircleShape b) {
    if (!rectToRect(a.rect, b.rect)) return false;

    final distance = a.radius + b.radius;
    final w = a.center.x - b.center.x;
    final h = a.center.y - b.center.y;

    return sqrt(w * w + h * h) <= distance;
  }

  static bool circleToPolygon(CircleShape a, PolygonShape b) {
    if (!rectToRect(a.rect, b.rect)) return false;

    if (b.points.isNotEmpty) {
      final points = b.points.toList();
      points.add(points.first);
      for (var i = 0; i < points.length - 1; i++) {
        final distance = getNearestDistance(points[i], points[i + 1], a.center);
        if (distance <= a.radius) {
          return true;
        }
      }
    }

    return false;
  }

  static bool polygonToPolygon(PolygonShape a, PolygonShape b) {
    if (!rectToRect(a.rect, b.rect)) return false;

    final pointsA = a.points.toList()..add(a.points.first);
    final pointsB = b.points.toList()..add(b.points.first);
    for (var i = 0; i < pointsA.length - 1; i++) {
      final pointA = pointsA[i];
      final pointB = pointsA[i + 1];

      if (!isLinesShadowOver(
        pointA,
        pointB,
        b.rect.leftTop,
        b.rect.rightBottom,
      )) {
        continue;
      }

      for (var j = 0; j < pointsB.length - 1; j++) {
        final pointC = pointsB[j];
        final pointD = pointsB[j + 1];

        if (!isLinesShadowOver(pointA, pointB, pointC, pointD)) {
          continue;
        }

        if (isLinesOver(pointA, pointB, pointC, pointD)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get [o] point distance [o1] and [o2] line segment distance
  /// https://blog.csdn.net/yjukh/article/details/5213577
  static double getNearestDistance(GameVector o1, GameVector o2, GameVector o) {
    if (o1 == o || o2 == o) return 0;

    final a = o2.distanceTo(o);
    final b = o1.distanceTo(o);
    final c = o1.distanceTo(o2);

    if (a * a >= b * b + c * c) return b;
    if (b * b >= a * a + c * c) return a;

    // 海伦公式
    final l = (a + b + c) / 2;
    final area = sqrt(l * (l - a) * (l - b) * (l - c));

    return 2 * area / c;
  }

  /// Obtain the [double] value with 4 decimal places to avoid errors caused
  /// by precision problems
  static double _getFixDouble(double value) {
    return double.parse(value.toStringAsFixed(4));
  }

  /// Rapid rejection experiment
  /// Determine whether the projections of the line segment [a]~[b] and
  ///  the line segment [c]~[d] on the x-axis and y-axis have a common area
  static bool isLinesShadowOver(
    GameVector a,
    GameVector b,
    GameVector c,
    GameVector d,
  ) {
    if (min(a.x, b.x) > max(c.x, d.x) ||
        min(c.x, d.x) > max(a.x, b.x) ||
        min(a.y, b.y) > max(c.y, d.y) ||
        min(c.y, d.y) > max(a.y, b.y)) {
      return false;
    }

    return true;
  }

  /// Straddle experiment
  /// Determine whether the line segment [a]~[b] and the line segment [c]~[d]
  /// https://www.rogoso.info/%E5%88%A4%E6%96%AD%E7%BA%BF%E6%AE%B5%E7%9B%B8%E4%BA%A4/
  static bool isLinesOver(
    GameVector a,
    GameVector b,
    GameVector c,
    GameVector d,
  ) {
    final ac = VectorVector(a, c);
    final ad = VectorVector(a, d);
    final bc = VectorVector(b, c);
    final bd = VectorVector(b, d);
    final ca = ac.negative;
    final cb = bc.negative;
    final da = ad.negative;
    final db = bd.negative;

    return vectorProduct(ac, ad) * vectorProduct(bc, bd) <= 0 &&
        vectorProduct(ca, cb) * vectorProduct(da, db) <= 0;
  }

  static double vectorProduct(VectorVector a, VectorVector b) {
    return a.x * b.y - b.x * a.y;
  }

  // POLYGON/POINT
// only needed if you're going to check if the rectangle
// is INSIDE the polygon
  static bool polygonPoint(PolygonShape b, GameVector point) {
    var collision = false;

    // go through each of the vertices, plus the next
    // vertex in the list
    final vertices = b.points;
    var next = 0;
    for (var current = 0; current < vertices.length; current++) {
      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current + 1;
      if (next == vertices.length) next = 0;

      // get the PVectors at our current position
      // this makes our if statement a little cleaner
      final vc = vertices[current]; // c for "current"
      final vn = vertices[next]; // n for "next"

      // compare position, flip 'collision' variable
      // back and forth
      if (((vc.y > point.y && vn.y < point.y) ||
              (vc.y < point.y && vn.y > point.y)) &&
          (point.x < (vn.x - vc.x) * (point.y - vc.y) / (vn.y - vc.y) + vc.x)) {
        collision = !collision;
      }
    }
    return collision;
  }

  static bool segmentToSegment(
    SegmentShape a,
    SegmentShape b,
  ) {
    final p = a.start;
    final q = b.start;
    final r = GameVector(x: a.end.x - a.start.x, y: a.end.y - a.start.y);
    final s = GameVector(x: b.end.x - b.start.x, y: b.end.y - b.start.y);

    final rxs = cross(r, s);
    final qmp = GameVector(x: q.x - p.x, y: q.y - p.y);

    if (rxs.abs() < 1e-10) return false;

    final t = cross(qmp, s) / rxs;
    final u = cross(qmp, r) / rxs;

    return (t >= 0) && (t <= 1) && (u >= 0) && (u <= 1);
  }

  static double cross(GameVector p1, GameVector p2) {
    return p1.x * p2.y - p1.y * p2.x;
  }

  static bool rectToSegment(RectangleShape b, SegmentShape a) {
    // Check if either endpoint is inside rectangle
    if (isPointInRectangle(a.start, b) || isPointInRectangle(a.end, b)) {
      return true;
    }

    // Check intersection with all 4 sides of rectangle
    final rectSegments = [
      SegmentShape(b.leftTop, b.rightTop),
      SegmentShape(b.rightTop, b.rightBottom),
      SegmentShape(b.rightBottom, b.leftBottom),
      SegmentShape(b.leftBottom, b.leftTop)
    ];

    return rectSegments.any((segment) => segmentToSegment(a, segment));
  }

  static bool isPointInRectangle(GameVector p, RectangleShape rect) {
    return p.x >= rect.left &&
        p.x <= rect.right &&
        p.y >= rect.top &&
        p.y <= rect.bottom;
  }

  static bool segmentToCircle(SegmentShape a, CircleShape b) {
    final closest = _getClosestPointOnSegment(a, b.center);
    final distance =
        sqrt(pow(closest.x - b.center.x, 2) + pow(closest.y - b.center.y, 2));
    return distance <= b.radius;
  }

  static GameVector _getClosestPointOnSegment(SegmentShape a, GameVector p) {
    final v = GameVector(x: a.end.x - a.start.x, y: a.end.y - a.start.y);
    final w = GameVector(x: p.x - a.start.x, y: p.y - a.start.y);

    final c1 = dot(w, v);
    if (c1 <= 0) return a.start;

    final c2 = dot(v, v);
    if (c2 <= c1) return a.end;

    final b = c1 / c2;
    return GameVector(x: a.start.x + b * v.x, y: a.start.y + b * v.y);
  }

  static double dot(GameVector p1, GameVector p2) {
    return p1.x * p2.x + p1.y * p2.y;
  }

  static bool segmentToPolygon(SegmentShape a, PolygonShape b) {
    // Check if either endpoint is inside polygon
    if (polygonPoint(b, a.start) || polygonPoint(b, a.end)) {
      return true;
    }

    // Check intersection with all polygon edges
    for (int i = 0; i < b.points.length; i++) {
      final nextIndex = (i + 1) % b.points.length;
      final polygonSegment = SegmentShape(b.points[i], b.points[nextIndex]);
      if (segmentToSegment(a, polygonSegment)) {
        return true;
      }
    }
    return false;
  }
}

class VectorVector {
  VectorVector(this.start, this.end)
      : x = end.x - start.x,
        y = end.y - start.y;
  final GameVector start;
  final GameVector end;
  final double x;
  final double y;

  /// Vector negation
  VectorVector get negative => VectorVector(end, start);
}
