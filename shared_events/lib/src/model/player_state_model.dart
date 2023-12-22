// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class ComponentStateModel {
  ComponentStateModel({
    required this.id,
    required this.name,
    required this.skin,
    required this.position,
    required this.life,
    this.direction,
    this.action,
  }) {
    initPosition = position.clone();
  }

  final String id;
  final String name;
  final String skin;
  final String? action;
  String? direction;
  GameVector position;
  int life;
  late final GameVector initPosition;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'skin': skin,
      'position': position.toMap(),
      'life': life,
      'direction': direction,
      'action': action,
    };
  }

  factory ComponentStateModel.fromMap(Map<String, dynamic> map) {
    return ComponentStateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      skin: map['skin'] as String,
      position: GameVector.fromMap(map['position'] as Map<String, dynamic>),
      life: map['life'] as int,
      direction: map['direction'] as String?,
      action: map['action'] as String?,
    );
  }
}
