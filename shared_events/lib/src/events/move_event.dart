// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class MoveEvent {
  MoveEvent({
    required this.position,
    required this.time,
    required this.direction,
    required this.mapId,
    this.inputId, // For client-side prediction
    this.timestamp, // For lag compensation
  });

  final GameVector position;
  final String time;
  final MoveDirectionEnum? direction;
  final String mapId;
  final int? inputId;
  final int? timestamp; // Client timestamp in milliseconds

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': position.toMap(),
      'time': time,
      'direction': direction?.index,
      'map': mapId,
      'inputId': inputId,
      'timestamp': timestamp,
    };
  }

  factory MoveEvent.fromMap(Map<String, dynamic> map) {
    return MoveEvent(
      position: GameVector.fromMap(map['position'] as Map<String, dynamic>),
      time: map['time'] as String,
      mapId: map['map'] as String,
      direction: map['direction'] != null
          ? MoveDirectionEnum.values[map['direction']]
          : null,
      inputId: map['inputId'] as int?,
      timestamp: map['timestamp'] as int?,
    );
  }
}

enum MoveDirectionEnum {
  left,
  right,
  up,
  down,
  upLeft,
  upRight,
  downLeft,
  downRight;

  factory MoveDirectionEnum.fromVector(GameVector vector,
      {bool isDiagonal = true}) {
    if (vector.x == 0 && vector.y == 0) {
      return MoveDirectionEnum.down;
    }
    if (vector.x == 0 && vector.y < 0) {
      return MoveDirectionEnum.up;
    }
    if (vector.x == 0 && vector.y > 0) {
      return MoveDirectionEnum.down;
    }
    if (vector.x < 0 && vector.y == 0) {
      return MoveDirectionEnum.left;
    }
    if (vector.x > 0 && vector.y == 0) {
      return MoveDirectionEnum.right;
    }

    if (vector.x > 0 && vector.y < 0) {
      if (isDiagonal) {
        return MoveDirectionEnum.upRight;
      } else {
        return MoveDirectionEnum.right;
      }
    }

    if (vector.x < 0 && vector.y < 0) {
      if (isDiagonal) {
        return MoveDirectionEnum.upLeft;
      } else {
        return MoveDirectionEnum.left;
      }
    }

    if (vector.x < 0 && vector.y > 0) {
      if (isDiagonal) {
        return MoveDirectionEnum.downLeft;
      } else {
        return MoveDirectionEnum.left;
      }
    }
    if (vector.x > 0 && vector.y > 0) {
      if (isDiagonal) {
        return MoveDirectionEnum.downRight;
      } else {
        return MoveDirectionEnum.right;
      }
    }
    throw Exception('Invalid vector');
  }
}
