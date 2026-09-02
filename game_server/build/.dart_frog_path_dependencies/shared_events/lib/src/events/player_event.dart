// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:shared_events/shared_events.dart';

class PlayerEvent {
  PlayerEvent({required this.player});

  final ComponentStateModel player;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'player': player.toMap(),
    };
  }

  factory PlayerEvent.fromMap(Map<String, dynamic> map) {
    return PlayerEvent(
      player: ComponentStateModel.fromMap((map['player'] as Map).cast()),
    );
  }
}
