// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

/// Server → clients broadcast describing a visual attack effect to play.
///
/// The server is authoritative about *which* effect (melee swing, future
/// ranged/skill projectiles...) and *where* it happens, so every client
/// renders the exact same effect at the exact same world position.
///
/// Clients keep a registry of known [effectId]s: an id they don't recognize
/// (older client, newer server) is silently ignored — nothing is rendered.
class AttackEffectEvent {
  AttackEffectEvent({
    required this.sourceId,
    required this.effectId,
    required this.position,
    this.direction,
  });

  /// Id of the attacking player.
  final String sourceId;

  /// Which effect to play (e.g. `melee_slash`). Unknown ids are ignored by
  /// clients, so new attack types don't break older clients.
  final String effectId;

  /// World position where the effect should be spawned (center point).
  final GameVector position;

  /// Facing/orientation of the effect, when it is directional.
  final MoveDirectionEnum? direction;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sourceId': sourceId,
      'effectId': effectId,
      'position': position.toMap(),
      'direction': direction?.index,
    };
  }

  factory AttackEffectEvent.fromMap(Map<String, dynamic> map) {
    return AttackEffectEvent(
      sourceId: map['sourceId'] as String,
      effectId: map['effectId'] as String,
      position: GameVector.fromMap((map['position'] as Map).cast()),
      direction: map['direction'] != null
          ? MoveDirectionEnum.values[map['direction']]
          : null,
    );
  }
}

/// Well-known attack effect ids shared between server and client.
abstract final class AttackEffectId {
  /// A classic melee slash spawned in front of the attacker.
  static const String meleeSlash = 'melee_slash';
}
