// ignore_for_file: public_member_api_docs, sort_constructors_first

class JoinEvent {
  JoinEvent({
    required this.name,
    required this.skin,
    this.token,
    this.characterId,
  });

  final String name;
  final String skin;

  /// JWT returned by `/auth/sign_in` or `/auth/sign_up`. When present, the
  /// server validates it and loads the [characterId] from the user's account.
  final String? token;

  /// The selected character id. The server spawns the player using the
  /// character's saved skin/nickname/position/map.
  final String? characterId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'skin': skin,
      'token': token,
      'characterId': characterId,
    };
  }

  factory JoinEvent.fromMap(Map<String, dynamic> map) {
    return JoinEvent(
      name: map['name'] as String,
      skin: map['skin'] as String,
      token: map['token'] as String?,
      characterId: map['characterId'] as String?,
    );
  }
}
