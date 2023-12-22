// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class ComponentStateModel {
  ComponentStateModel({
    required this.id,
    required this.name,
    required this.position,
    required this.life,
    this.speed = 80,
    this.direction,
    this.action,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {} {
    initPosition = position.clone();
  }

  final String id;
  final String name;
  final String? action;
  final double speed;
  String? direction;
  GameVector position;
  int life;
  final Map<String, dynamic> properties;
  late final GameVector initPosition;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'position': position.toMap(),
      'life': life,
      'direction': direction,
      'action': action,
      'speed': action,
      'properties': properties,
    };
  }

  factory ComponentStateModel.fromMap(Map<String, dynamic> map) {
    return ComponentStateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      position: GameVector.fromMap(map['position'] as Map<String, dynamic>),
      life: map['life'] as int,
      direction: map['direction'] as String?,
      action: map['action'] as String?,
      speed: double.tryParse(map['speed'].toString()) ?? 80,
      properties: map['properties'] as Map<String, dynamic>? ?? {},
    );
  }
}
