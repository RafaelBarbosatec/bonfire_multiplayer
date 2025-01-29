import 'dart:async';

import '../../main.dart';
import 'game_component.dart';

abstract class Game extends GameComponent {
  final List<GameComponent> _compRequestedUpdate = [];
  Timer? _gameTimer;
  final DateTime _initialTime = DateTime.now();
  double get _currentTime {
    return DateTime.now().difference(_initialTime).inMilliseconds / 1000.0;
  }

  double _previous = 0;

  @override
  void onUpdate(double dt) {
    super.onUpdate(dt);
    if (_compRequestedUpdate.isNotEmpty) {
      for (final comp in _compRequestedUpdate) {
        onStateUpdate(comp);
      }
      _compRequestedUpdate.clear();
    }
  }

  @override
  void onRequestUpdate(GameComponent comp) {
    if (!_compRequestedUpdate.contains(comp)) {
      _compRequestedUpdate.add(comp);
    }
  }

  void onStateUpdate(GameComponent comp);

  Future<void> start() {
    if (_gameTimer == null) {
      logger.i('Start Game loop');
      _gameTimer = Timer.periodic(
        const Duration(milliseconds: 30),
        (timer) {
          final curr = _currentTime;
          final dt = curr - _previous;
          _previous = curr;
          onUpdate(dt);
        },
      );
    }
    return Future.value();
  }

  void stop() {
    logger.i('Stop Game loop');
    _gameTimer?.cancel();
    _gameTimer = null;
  }
}
