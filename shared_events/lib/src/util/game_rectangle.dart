// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/src/util/game_vector.dart';

class GameRectangle {
  final GameVector position;
  final GameVector size;

  GameRectangle({required this.position, required this.size});

  bool overlaps(GameRectangle other) {
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

  factory GameRectangle.fromMap(Map<String, dynamic> map) {
    return GameRectangle(
      position: GameVector.fromMap(map['position'] as Map<String, dynamic>),
      size: GameVector.fromMap(map['size'] as Map<String, dynamic>),
    );
  }

  GameRectangle copyWith({
    GameVector? position,
    GameVector? size,
  }) {
    return GameRectangle(
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}
