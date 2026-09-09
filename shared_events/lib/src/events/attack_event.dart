// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

/// Client → server request to perform a melee attack.
///
/// The server is authoritative: it validates cooldown/range, resolves the
/// nearest enemy, applies the damage and broadcasts the result via
/// [DamageEvent] (plus the regular state delta for life/removal/XP).
class AttackEvent {
  AttackEvent({
    required this.mapId,
    required this.time,
  });

  final String mapId;

  /// Microseconds since epoch (same unit as [ComponentStateModel.serverTimestamp]).
  final int time;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'map': mapId,
      'time': time,
    };
  }

  factory AttackEvent.fromMap(Map<String, dynamic> map) {
    return AttackEvent(
      mapId: map['map'] as String,
      time: map['time'] as int,
    );
  }
}
