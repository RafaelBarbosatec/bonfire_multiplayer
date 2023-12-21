import 'dart:math';

/// An immutable, 2D, axis-aligned, floating-point rectangle whose coordinates
/// are relative to a given origin.
///
/// A Rect can be created with one of its constructors or from an [Point] and a
/// [Size] using the `&` operator:
///
/// ```dart
/// Rect myRect = const Point(1.0, 2.0) & const Size(3.0, 4.0);
/// ```
class Rect {
  /// Construct a rectangle from its left, top, right, and bottom edges.
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/rect_from_ltrb.png#gh-light-mode-only)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/rect_from_ltrb_dark.png#gh-dark-mode-only)
  @pragma('vm:entry-point')
  const Rect.fromLTRB(this.left, this.top, this.right, this.bottom);

  /// Construct a rectangle from its left and top edges, its width, and its
  /// height.
  ///
  /// To construct a [Rect] from an [Point] and a [Size], you can use the
  /// rectangle constructor operator `&`. See [Point.&].
  ///
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/rect_from_ltwh.png#gh-light-mode-only)
  /// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/rect_from_ltwh_dark.png#gh-dark-mode-only)
  const Rect.fromLTWH(double left, double top, double width, double height)
      : this.fromLTRB(left, top, left + width, top + height);

  /// The Point of the left edge of this rectangle from the x axis.
  final double left;

  /// The Point of the top edge of this rectangle from the y axis.
  final double top;

  /// The Point of the right edge of this rectangle from the x axis.
  final double right;

  /// The Point of the bottom edge of this rectangle from the y axis.
  final double bottom;

  /// The distance between the left and right edges of this rectangle.
  double get width => right - left;

  /// The distance between the top and bottom edges of this rectangle.
  double get height => bottom - top;

  /// The distance between the upper-left corner and the lower-right corner of
  /// this rectangle.
  Point get size => Point(width, height);

  /// Whether any of the dimensions are `NaN`.
  bool get hasNaN => left.isNaN || top.isNaN || right.isNaN || bottom.isNaN;

  /// A rectangle with left, top, right, and bottom edges all at zero.
  static const Rect zero = Rect.fromLTRB(0, 0, 0, 0);

  static const double _giantScalar =
      1000000000; // matches kGiantRect from layer.h

  /// A rectangle that covers the entire coordinate space.
  ///
  /// This covers the space from -1e9,-1e9 to 1e9,1e9.
  /// This is the space over which graphics operations are valid.
  static const Rect largest =
      Rect.fromLTRB(-_giantScalar, -_giantScalar, _giantScalar, _giantScalar);

  /// Whether any of the coordinates of this rectangle are equal to positive infinity.
  // included for consistency with Point and Size
  bool get isInfinite {
    return left >= double.infinity ||
        top >= double.infinity ||
        right >= double.infinity ||
        bottom >= double.infinity;
  }

  /// Whether all coordinates of this rectangle are finite.
  bool get isFinite =>
      left.isFinite && top.isFinite && right.isFinite && bottom.isFinite;

  /// Whether this rectangle encloses a non-zero area. Negative areas are
  /// considered empty.
  bool get isEmpty => left >= right || top >= bottom;

  /// Returns a new rectangle translated by the given Point.
  ///
  /// To translate a rectangle by separate x and y components rather than by an
  /// [Point], consider [translate].
  Rect shift(Point point) {
    return Rect.fromLTRB(
      left + point.x,
      top + point.y,
      right + point.x,
      bottom + point.y,
    );
  }

  /// Returns a new rectangle with translateX added to the x components and
  /// translateY added to the y components.
  ///
  /// To translate a rectangle by an [Point] rather than by separate x and y
  /// components, consider [shift].
  Rect translate(double translateX, double translateY) {
    return Rect.fromLTRB(
      left + translateX,
      top + translateY,
      right + translateX,
      bottom + translateY,
    );
  }

  /// Returns a new rectangle with edges moved outwards by the given delta.
  Rect inflate(double delta) {
    return Rect.fromLTRB(
      left - delta,
      top - delta,
      right + delta,
      bottom + delta,
    );
  }

  /// Returns a new rectangle with edges moved inwards by the given delta.
  Rect deflate(double delta) => inflate(-delta);

  /// Returns a new rectangle that is the intersection of the given
  /// rectangle and this rectangle. The two rectangles must overlap
  /// for this to be meaningful. If the two rectangles do not overlap,
  /// then the resulting Rect will have a negative width or height.
  Rect intersect(Rect other) {
    return Rect.fromLTRB(
      max(left, other.left),
      max(top, other.top),
      min(right, other.right),
      min(bottom, other.bottom),
    );
  }

  /// Returns a new rectangle which is the bounding box containing this
  /// rectangle and the given rectangle.
  Rect expandToInclude(Rect other) {
    return Rect.fromLTRB(
      min(left, other.left),
      min(top, other.top),
      max(right, other.right),
      max(bottom, other.bottom),
    );
  }

  /// Whether `other` has a nonzero area of overlap with this rectangle.
  bool overlaps(Rect other) {
    if (right <= other.left || other.right <= left) {
      return false;
    }
    if (bottom <= other.top || other.bottom <= top) {
      return false;
    }
    return true;
  }

  /// The lesser of the magnitudes of the [width] and the [height] of this
  /// rectangle.
  double get shortestSide => min(width.abs(), height.abs());

  /// The greater of the magnitudes of the [width] and the [height] of this
  /// rectangle.
  double get longestSide => max(width.abs(), height.abs());

  /// The Point to the intersection of the top and left edges of this rectangle.
  ///
  /// See also [Point.topLeft].
  Point get topLeft => Point(left, top);

  /// The Point to the center of the top edge of this rectangle.
  ///
  /// See also [Size.topCenter].
  Point get topCenter => Point(left + width / 2.0, top);

  /// The Point to the intersection of the top and right edges of this rectangle.
  ///
  /// See also [Size.topRight].
  Point get topRight => Point(right, top);

  /// The Point to the center of the left edge of this rectangle.
  ///
  /// See also [Size.centerLeft].
  Point get centerLeft => Point(left, top + height / 2.0);

  /// The Point to the point halfway between the left and right and the top and
  /// bottom edges of this rectangle.
  ///
  /// See also [Size.center].
  Point get center => Point(left + width / 2.0, top + height / 2.0);

  /// The Point to the center of the right edge of this rectangle.
  ///
  /// See also [Size.centerLeft].
  Point get centerRight => Point(right, top + height / 2.0);

  /// The Point to the intersection of the bottom and left edges of this rectangle.
  ///
  /// See also [Size.bottomLeft].
  Point get bottomLeft => Point(left, bottom);

  /// The Point to the center of the bottom edge of this rectangle.
  ///
  /// See also [Size.bottomLeft].
  Point get bottomCenter => Point(left + width / 2.0, bottom);

  /// The Point to the intersection of the bottom and right edges of this rectangle.
  ///
  /// See also [Size.bottomRight].
  Point get bottomRight => Point(right, bottom);

  /// Whether the point specified by the given Point (which is assumed to be
  /// relative to the origin) lies between the left and right and the top and
  /// bottom edges of this rectangle.
  ///
  /// Rectangles include their top and left edges but exclude their bottom and
  /// right edges.
  bool contains(Point point) {
    return point.x >= left &&
        point.x < right &&
        point.y >= top &&
        point.y < bottom;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return other is Rect &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() =>
      'Rect.fromLTRB(${left.toStringAsFixed(1)}, ${top.toStringAsFixed(1)}, ${right.toStringAsFixed(1)}, ${bottom.toStringAsFixed(1)})';
}
