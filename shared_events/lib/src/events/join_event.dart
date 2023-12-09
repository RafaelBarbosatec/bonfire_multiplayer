// ignore_for_file: public_member_api_docs, sort_constructors_first

class JoinEvent {
  JoinEvent({required this.name, required this.skin});

  final String name;
  final String skin;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'skin': skin,
    };
  }

  factory JoinEvent.fromMap(Map<String, dynamic> map) {
    return JoinEvent(
      name: map['name'] as String,
      skin: map['skin'] as String,
    );
  }
}
