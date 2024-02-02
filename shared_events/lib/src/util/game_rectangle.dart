// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/src/util/game_vector.dart';

class GameRect {
  final GameVector position;
  final GameVector size;

  GameRect({GameVector? position, required this.size})
      : position = position ?? GameVector.zero();

  factory GameRect.zero() {
    return GameRect(
      position: GameVector.zero(),
      size: GameVector.zero(),
    );
  }

  GameVector get topLeft => position;

  GameVector get topRight => GameVector(x: right, y: top);

  GameVector get bottomRight => GameVector(x: right, y: bottom);

  GameVector get bottomLeft => GameVector(x: left, y: bottom);

  bool overlaps(GameRect other) {
    if (right <= other.left || other.right <= left) {
      return false;
    }
    if (bottom <= other.top || other.bottom <= top) {
      return false;
    }
    return true;
  }

  double get right => position.x + size.x;
  double get left => position.x;
  double get bottom => position.y + size.y;
  double get top => position.y;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': position.toMap(),
      'size': size.toMap(),
    };
  }

  factory GameRect.fromMap(Map<String, dynamic> map) {
    return GameRect(
      position: GameVector.fromMap(map['position'] as Map<String, dynamic>),
      size: GameVector.fromMap(map['size'] as Map<String, dynamic>),
    );
  }

  GameRect copyWith({
    GameVector? position,
    GameVector? size,
  }) {
    return GameRect(
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}
