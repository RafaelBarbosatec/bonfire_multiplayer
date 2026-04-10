// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class GameStateModel {
  /// Players that changed since last update (not all players)
  final Iterable<ComponentStateModel> players;

  /// NPCs that changed since last update (not all npcs)
  final Iterable<ComponentStateModel> npcs;

  /// IDs of entities (players or NPCs) that were removed from the map
  final List<String> removed;

  /// Whether this is a full state (true) or delta update (false)
  final bool fullState;

  final int timestamp;

  GameStateModel({
    required this.players,
    required this.npcs,
    List<String>? removed,
    this.fullState = false,
    int? timestamp,
  })  : removed = removed ?? [],
        timestamp = timestamp ?? DateTime.now().microsecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'players': players.map((x) => x.toMap()).toList(),
      'npcs': npcs.map((x) => x.toMap()).toList(),
      'removed': removed,
      'fullState': fullState,
      'timestamp': timestamp,
    };
  }

  factory GameStateModel.fromMap(Map<String, dynamic> map) {
    return GameStateModel(
      players: List<ComponentStateModel>.from(
        (map['players'] as List).map<ComponentStateModel>(
          (x) => ComponentStateModel.fromMap((x as Map).cast()),
        ),
      ),
      npcs: List<ComponentStateModel>.from(
        (map['npcs'] as List).map<ComponentStateModel>(
          (x) => ComponentStateModel.fromMap((x as Map).cast()),
        ),
      ),
      removed: List<String>.from(map['removed'] ?? []),
      fullState: map['fullState'] as bool? ?? false,
      timestamp: int.tryParse(map['timestamp'].toString()) ?? 0,
    );
  }
}
