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
