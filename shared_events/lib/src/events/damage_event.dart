// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

/// Server → clients broadcast describing a landed melee hit.
///
/// Sent so clients can show damage feedback (floating numbers) without
/// parsing state deltas. The authoritative life/removal/XP still flow through
/// the regular [GameStateModel] deltas.
class DamageEvent {
  DamageEvent({
    required this.sourceId,
    required this.targetId,
    required this.damage,
    required this.targetDied,
  });

  /// Id of the attacking player.
  final String sourceId;

  /// Id of the damaged entity (player or NPC).
  final String targetId;

  final int damage;

  /// True when this hit reduced the target's life to 0.
  final bool targetDied;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sourceId': sourceId,
      'targetId': targetId,
      'damage': damage,
      'targetDied': targetDied,
    };
  }

  factory DamageEvent.fromMap(Map<String, dynamic> map) {
    return DamageEvent(
      sourceId: map['sourceId'] as String,
      targetId: map['targetId'] as String,
      damage: map['damage'] as int,
      targetDied: map['targetDied'] as bool,
    );
  }
}
