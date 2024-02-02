import 'game_npc.dart';

abstract class GamePlayer extends GameNpc {
  GamePlayer({
    required super.state,
    super.components,
  });

  void send<T>(String event, T data);
}
