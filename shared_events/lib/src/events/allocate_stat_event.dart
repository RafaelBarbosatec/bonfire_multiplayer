// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

/// Client → server request to invest one status point in a base stat.
///
/// The server validates affordability/cap ([PlayerAttributes.tryAllocateStat])
/// and replies by broadcasting the updated [PlayerAttributes] in the regular
/// state delta — there is no dedicated ack.
class AllocateStatEvent {
  AllocateStatEvent({required this.stat});

  /// One of [PlayerAttributes.statKeys] ('str', 'agi', 'vit', 'int',
  /// 'dex', 'luk').
  final String stat;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stat': stat,
    };
  }

  factory AllocateStatEvent.fromMap(Map<String, dynamic> map) {
    return AllocateStatEvent(
      stat: map['stat'] as String,
    );
  }
}
