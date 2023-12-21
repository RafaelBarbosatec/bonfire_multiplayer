// ignore_for_file: public_member_api_docs, sort_constructors_first

class GameVector {
  double x;
  double y;

  GameVector({required this.x, required this.y});

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
}
