// ignore_for_file: public_member_api_docs, sort_constructors_first

class CharacterModel {
  CharacterModel({
    required this.id,
    required this.nickName,
    required this.skin,
    required this.userId,
    required this.position,
    required this.mapId,
  });

  static const document = 'players';

  final String id;
  final String nickName;
  final String skin;
  final String userId;
  final CharacterPosition position;
  final String mapId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nickName': nickName,
      'skin': skin,
      'userId': userId,
      'position': position.toMap(),
      'mapId': mapId,
    };
  }

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      id: map['id'] as String,
      nickName: map['nickName'] as String,
      skin: map['skin'] as String,
      userId: map['userId'] as String,
      position: CharacterPosition.fromMap(map['position'] as Map<String, dynamic>),
      mapId: map['mapId'] as String,
    );
  }
}

class CharacterPosition {
  CharacterPosition({
    required this.x,
    required this.z,
  });

  factory CharacterPosition.fromMap(Map<String, dynamic> map) {
    return CharacterPosition(
      x: map['x'] as double,
      z: map['z'] as double,
    );
  }
  final double x;
  final double z;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'z': z,
    };
  }
}
