// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class ComponentStateModel {
  ComponentStateModel({
    required this.id,
    required this.name,
    required this.position,
    required this.life,
    this.speed = 80,
    MoveDirectionEnum? direction,
    MoveDirectionEnum? lastDirection,
    this.action,
    Map<String, dynamic>? properties,
  })  : properties = properties ?? {},
        _direction = direction,
        _lastDirection = lastDirection ?? direction {
    initPosition = position.clone();
  }

  final String id;
  final String name;
  final String? action;
  final double speed;
  MoveDirectionEnum? _lastDirection;
  MoveDirectionEnum? _direction;
  GameVector position;
  int life;
  final Map<String, dynamic> properties;
  late final GameVector initPosition;

  set direction(MoveDirectionEnum? d) {
    if (d == null && _direction != null) {
      _lastDirection = direction;
    }
    _direction = d;
  }

  MoveDirectionEnum? get direction => _direction;
  MoveDirectionEnum? get lastDirection => _lastDirection;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'position': position.toMap(),
      'life': life,
      'lastDirection': _lastDirection?.index,
      'direction': direction?.index,
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
      direction: map['direction'] != null
          ? MoveDirectionEnum.values[map['direction']]
          : null,
      lastDirection: map['lastDirection'] != null
          ? MoveDirectionEnum.values[map['lastDirection']]
          : null,
      action: map['action'] as String?,
      speed: double.tryParse(map['speed'].toString()) ?? 80,
      properties: map['properties'] as Map<String, dynamic>? ?? {},
    );
  }
}
