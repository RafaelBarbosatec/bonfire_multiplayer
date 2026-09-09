// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class ComponentStateModel {
  ComponentStateModel({
    required this.id,
    required this.name,
    required this.position,
    required this.size,
    required this.life,
    int? maxLife,
    this.speed = 80,
    MoveDirectionEnum? direction,
    MoveDirectionEnum? lastDirection,
    this.action,
    Map<String, dynamic>? properties,
    this.lastInputId, // For client-side prediction acknowledgment
    this.serverTimestamp, // Server timestamp for lag compensation
    this.attributes, // Authoritative player attributes (HP/stamina/level/XP)
  })  : maxLife = maxLife ?? life,
        properties = properties ?? {},
        _direction = direction,
        _lastDirection = lastDirection ?? direction {
    initPosition = position.clone();
  }

  final String id;
  final String name;
  final String? action;
  final double speed;
  // Not final: the server updates it as inputs are processed
  // (client-side prediction acknowledgment).
  int? lastInputId;
  // Not final: the server stamps it on every move/stop (the moment the
  // position is true on the server clock — used for interpolation).
  int? serverTimestamp;
  MoveDirectionEnum? _lastDirection;
  MoveDirectionEnum? _direction;
  GameVector position;
  GameVector size;
  int life;

  /// Maximum life of the entity (spawn value for NPCs; derived pool for
  /// players). Defaults to [life] so old payloads / full-HP spawns keep
  /// working without sending it. Used by clients to render life bars with
  /// the correct scale even when they join mid-fight.
  final int maxLife;
  final Map<String, dynamic> properties;
  late final GameVector initPosition;

  /// Authoritative attributes (players only; NPCs keep it null). The server
  /// replaces the whole instance whenever a value changes.
  PlayerAttributes? attributes;

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
      'size': size.toMap(),
      'life': life,
      'maxLife': maxLife,
      'lastDirection': _lastDirection?.index,
      'direction': direction?.index,
      'action': action,
      'speed': speed,
      'properties': properties,
      'lastInputId': lastInputId,
      'serverTimestamp': serverTimestamp,
      'attributes': attributes?.toMap(),
    };
  }

  factory ComponentStateModel.fromMap(Map<String, dynamic> map) {
    return ComponentStateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      position: GameVector.fromMap((map['position'] as Map).cast()),
      size: GameVector.fromMap((map['size'] as Map).cast()),
      life: map['life'] as int,
      maxLife: map['maxLife'] as int?,
      direction: map['direction'] != null
          ? MoveDirectionEnum.values[map['direction']]
          : null,
      lastDirection: map['lastDirection'] != null
          ? MoveDirectionEnum.values[map['lastDirection']]
          : null,
      action: map['action'] as String?,
      speed: double.tryParse(map['speed'].toString()) ?? 80,
      properties: (map['properties'] as Map?)?.cast() ?? {},
      lastInputId: map['lastInputId'] as int?,
      serverTimestamp: map['serverTimestamp'] as int?,
      attributes: map['attributes'] != null
          ? PlayerAttributes.fromMap((map['attributes'] as Map).cast())
          : null,
    );
  }
}
