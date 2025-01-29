// ignore_for_file: public_member_api_docs, sort_constructors_first, hash_and_equals
import 'dart:math' as math;

class GameVector {
  double x;
  double y;

  GameVector({required this.x, required this.y});

  factory GameVector.zero() {
    return GameVector(x: 0, y: 0);
  }

  factory GameVector.all(double value) {
    return GameVector(x: value, y: value);
  }

  /// Check if two vectors are the same.
  @override
  bool operator ==(Object other) =>
      (other is GameVector) && (x == other.x) && (y == other.y);

  /// Negate.
  GameVector operator -() => clone()..negate();

  /// Subtract two vectors.
  GameVector operator -(GameVector other) => clone()..sub(other);

  /// Add two vectors.
  GameVector operator +(GameVector other) => clone()..add(other);

  /// Scale.
  GameVector operator /(double scale) => clone()..scale(1.0 / scale);

  /// Scale.
  GameVector operator *(double scale) => clone()..scale(scale);

  /// Scale this by [arg].
  void scale(double arg) {
    y = y * arg;
    x = x * arg;
  }

  /// Return a copy of this scaled by [arg].
  GameVector scaled(double arg) => clone()..scale(arg);

  /// Negate.
  void negate() {
    y = -y;
    x = -x;
  }

  /// Absolute value.
  void absolute() {
    y = y.abs();
    x = x.abs();
  }

  void add(GameVector arg) {
    x = x + arg.x;
    y = y + arg.y;
  }

  /// Add [arg] scaled by [factor] to this.
  void addScaled(GameVector arg, double factor) {
    x = x + arg.x * factor;
    y = y + arg.y * factor;
  }

  /// Subtract [arg] from this.
  void sub(GameVector arg) {
    x = x - arg.x;
    y = y - arg.y;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
    };
  }

  factory GameVector.fromMap(Map<String, dynamic> map) {
    return GameVector(
      x: double.parse(map['x']?.toString() ?? '0'),
      y: double.parse(map['y']?.toString() ?? '0'),
    );
  }

  GameVector clone() {
    return GameVector(x: x, y: y);
  }

  GameVector copyWith({double? x, double? y}) {
    return GameVector(x: x ?? this.x, y: y ?? this.y);
  }

  @override
  String toString() => 'GameVector(x: $x, y: $y)';

  GameVector translated(double x, double y) {
    return GameVector(x: this.x + x, y: this.y + y);
  }

  double distanceTo(GameVector arg) {
    return math.sqrt(distanceToSquared(arg));
  }

  double distanceToSquared(GameVector arg) {
    final dx = x - arg.x;
    final dy = y - arg.y;
    return dx * dx + dy * dy;
  }

  /// Normalize this vector.
  void normalize() {
    final length = math.sqrt(x * x + y * y);
    if (length != 0) {
      x /= length;
      y /= length;
    }
  }

  /// Return a normalized copy of this vector.
  GameVector normalized() {
    final length = math.sqrt(x * x + y * y);
    if (length == 0) {
      return GameVector.zero();
    }
    return GameVector(x: x / length, y: y / length);
  }

  /// Get the length (magnitude) of the vector.
  double get length => math.sqrt(x * x + y * y);
}
