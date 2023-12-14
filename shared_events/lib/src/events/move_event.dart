class MoveEvent {
  MoveEvent({
    required this.time,
    required this.direction,
  });

  final String time;
  final String direction;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'time': time,
      'direction': direction,
    };
  }

  factory MoveEvent.fromMap(Map<String, dynamic> map) {
    return MoveEvent(
      time: map['time'] as String,
      direction: map['direction'] as String,
    );
  }
}

class MoveResponseEvent {
  MoveResponseEvent({required this.success, this.errorMessage});

  final bool success;
  final String? errorMessage;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'errorMessage': errorMessage,
    };
  }

  factory MoveResponseEvent.fromMap(Map<String, dynamic> map) {
    return MoveResponseEvent(
      success: map['success'] as bool,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
