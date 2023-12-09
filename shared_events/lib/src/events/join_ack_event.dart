// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class JoinAckEvent {
  JoinAckEvent({
    required this.state,
    required this.players,
  });

  final PlayerStateModel state;
  final List<PlayerStateModel> players;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'state': state.toMap(),
      'players': players
          .where((element) => element.id != state.id)
          .map((x) => x.toMap())
          .toList(),
    };
  }

  factory JoinAckEvent.fromMap(Map<String, dynamic> map) {
    return JoinAckEvent(
      state: PlayerStateModel.fromMap(map['state'] as Map<String, dynamic>),
      players: List<PlayerStateModel>.from(
        (map['players'] as List).map<PlayerStateModel>(
          (x) => PlayerStateModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}