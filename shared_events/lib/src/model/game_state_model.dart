// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class GameStateModel {
  final Iterable<ComponentStateModel> players;
  final Iterable<ComponentStateModel> npcs;
  final int timestamp;

  GameStateModel({required this.players, required this.npcs, int? timestamp})
      : timestamp = timestamp ?? DateTime.now().toUtc().microsecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'players': players.map((x) => x.toMap()).toList(),
      'npcs': npcs.map((x) => x.toMap()).toList(),
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
      timestamp: int.tryParse(map['timestamp'].toString()) ?? 0,
    );
  }
}
