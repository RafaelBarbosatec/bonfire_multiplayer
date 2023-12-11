// ignore_for_file: public_member_api_docs, sort_constructors_first

class GamePosition {
  final double x;
  final double y;

  GamePosition({required this.x, required this.y});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
    };
  }

  factory GamePosition.fromMap(Map<String, dynamic> map) {
    return GamePosition(
      x: double.parse(map['x']?.toString() ?? '0'),
      y: double.parse(map['y']?.toString() ?? '0'),
    );
  }

  GamePosition clone() {
    return GamePosition(x: x, y: y);
  }
}
