import 'dart:convert';

class BEvent {
  BEvent({required this.event, required this.data});

  factory BEvent.fromMap(Map<String, dynamic> map) {
    return BEvent(
      event: map['e'].toString(),
      data: map['d'],
    );
  }
  final String event;
  final dynamic data;

  Map<String, dynamic> toMap() {
    return {
      'e': event,
      'd': data,
    };
  }

  String toJson() => jsonEncode(toMap());
}
