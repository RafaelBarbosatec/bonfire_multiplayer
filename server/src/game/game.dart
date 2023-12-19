import 'dart:async';

import '../../main.dart';
import 'game_client.dart';

abstract class Game<T> {
  List<GameClient<T>> clients = [];
  Timer? _gameTimer;
  void start() {
    if (_gameTimer == null) {
      logger.i('Start Game loop');
      _gameTimer = Timer.periodic(
        const Duration(milliseconds: 30),
        (timer) => onUpdate(),
      );
    }
  }

  void stop() {
    logger.i('Stop Game loop');
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void enterClient(GameClient<T> client) {
    clients.add(client);
  }

  void leaveClient(GameClient<T> client) {
    clients.remove(client);
  }

  void onUpdate();
  void requestUpdate();
  List<dynamic> players();
}
