// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

class GameStateModel {
  final List<PlayerStateModel> players;

  GameStateModel({required this.players});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'players': players.map((x) => x.toMap()).toList(),
    };
  }

  factory GameStateModel.fromMap(Map<String, dynamic> map) {
    return GameStateModel(
      players: List<PlayerStateModel>.from(
        (map['players'] as List).map<PlayerStateModel>(
          (x) => PlayerStateModel.fromMap((x as Map).cast()),
        ),
      ),
    );
  }
}
