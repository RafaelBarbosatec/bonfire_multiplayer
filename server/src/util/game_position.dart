import 'dart:convert';
import 'dart:math';

class GamePosition extends Point<double> {
  GamePosition(super.x, super.y);

  factory GamePosition.fromMap(Map<String, dynamic> map) {
    return GamePosition(
      double.tryParse(map['x'].toString()) ?? 0,
      double.tryParse(map['y'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'x': x, 'y': y};
  }

  String toJSON() {
    return jsonEncode(toMap());
  }

  Point<T> clone<T extends num>() {
    return Point<T>(x as T, y as T);
  }
}
