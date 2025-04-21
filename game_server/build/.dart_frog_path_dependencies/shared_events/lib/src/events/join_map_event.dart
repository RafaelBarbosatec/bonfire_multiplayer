// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class JoinMapEvent {
  JoinMapEvent({
    required this.state,
    required this.map,
    required this.players,
    required this.npcs,
  });

  final ComponentStateModel state;
  final MapModel map;
  final Iterable<ComponentStateModel> players;
  final Iterable<ComponentStateModel> npcs;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'state': state.toMap(),
      'map': map.toMap(),
      'players': players
          .where((element) => element.id != state.id)
          .map((x) => x.toMap())
          .toList(),
      'npcs': npcs.map((x) => x.toMap()).toList(),
    };
  }

  factory JoinMapEvent.fromMap(Map<String, dynamic> map) {
    return JoinMapEvent(
      state: ComponentStateModel.fromMap(map['state'] as Map<String, dynamic>),
      map: MapModel.fromMap(map['map'] as Map<String, dynamic>),
      players: List<ComponentStateModel>.from(
        (map['players'] as List).map<ComponentStateModel>(
          (x) => ComponentStateModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      npcs: List<ComponentStateModel>.from(
        (map['npcs'] as List).map<ComponentStateModel>(
          (x) => ComponentStateModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
