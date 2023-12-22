// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class JoinAckEvent {
  JoinAckEvent({
    required this.state,
    required this.map,
    required this.players,
  });

  final ComponentStateModel state;
  final String map;
  final List<ComponentStateModel> players;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'state': state.toMap(),
      'map': map,
      'players': players
          .where((element) => element.id != state.id)
          .map((x) => x.toMap())
          .toList(),
    };
  }

  factory JoinAckEvent.fromMap(Map<String, dynamic> map) {
    return JoinAckEvent(
      state: ComponentStateModel.fromMap(map['state'] as Map<String, dynamic>),
      map: map['map'].toString(),
      players: List<ComponentStateModel>.from(
        (map['players'] as List).map<ComponentStateModel>(
          (x) => ComponentStateModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
