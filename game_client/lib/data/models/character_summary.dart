/// A character of the logged user, as returned by the server REST API.
class CharacterSummary {
  const CharacterSummary({
    required this.id,
    required this.nickName,
    required this.skin,
    required this.mapId,
    required this.x,
    required this.y,
  });

  final String id;
  final String nickName;
  final String skin;
  final String mapId;
  final double x;
  final double y;

  factory CharacterSummary.fromMap(Map<String, dynamic> map) {
    final position = (map['position'] as Map).cast<String, dynamic>();
    return CharacterSummary(
      id: map['id'] as String,
      nickName: map['nickName'] as String,
      skin: map['skin'] as String,
      mapId: map['mapId'] as String,
      x: (position['x'] as num).toDouble(),
      y: (position['y'] as num).toDouble(),
    );
  }
}
