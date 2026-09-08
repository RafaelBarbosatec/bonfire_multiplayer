// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class CharacterModel {
  CharacterModel({
    required this.id,
    required this.nickName,
    required this.skin,
    required this.userId,
    required this.position,
    required this.mapId,
    this.attributes = const PlayerAttributes(),
  });

  static const document = 'players';

  final String id;
  final String nickName;
  final String skin;
  final String userId;
  final CharacterPosition position;
  final String mapId;

  /// Persisted attributes (level/XP/HP/stamina survive re-login).
  final PlayerAttributes attributes;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nickName': nickName,
      'skin': skin,
      'userId': userId,
      'position': position.toMap(),
      'mapId': mapId,
      'attributes': attributes.toMap(),
    };
  }

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      id: map['id'] as String,
      nickName: map['nickName'] as String,
      skin: map['skin'] as String,
      userId: map['userId'] as String,
      position: CharacterPosition.fromMap((map['position'] as Map).cast()),
      mapId: map['mapId'] as String,
      attributes: map['attributes'] != null
          ? PlayerAttributes.fromMap((map['attributes'] as Map).cast())
          : const PlayerAttributes(),
    );
  }
}

class CharacterPosition {
  CharacterPosition({
    required this.x,
    required this.y,
  });

  factory CharacterPosition.fromMap(Map<String, dynamic> map) {
    return CharacterPosition(
      x: map['x'] as double,
      y: map['y'] as double,
    );
  }

  final double x;
  final double y;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
    };
  }
}
