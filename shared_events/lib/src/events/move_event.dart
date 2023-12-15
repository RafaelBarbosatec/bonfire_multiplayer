// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class MoveEvent {
  MoveEvent({
    required this.position,
    required this.time,
    required this.direction,
  });

  final GamePosition position;
  final String time;
  final String? direction;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': position.toMap(),
      'time': time,
      'direction': direction,
    };
  }

  factory MoveEvent.fromMap(Map<String, dynamic> map) {
    return MoveEvent(
      position: GamePosition.fromMap(map['position'] as Map<String, dynamic>),
      time: map['time'] as String,
      direction: map['direction'] as String?,
    );
  }
}

class MoveValidationEvent {
  MoveValidationEvent({
    required this.isValid,
    required this.position,
    required this.direction, // Add this line
  });

  final bool isValid;
  final GamePosition position;
  final String? direction; // And this line

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isValid': isValid,
      'position': position.toMap(),
      'direction': direction, // And this line
    };
  }

  factory MoveValidationEvent.fromMap(Map<String, dynamic> map) {
    return MoveValidationEvent(
      isValid: map['isValid'] as bool,
      position: GamePosition.fromMap(map['position'] as Map<String, dynamic>),
      direction: map['direction'] as String?, // And this line
    );
  }
}
