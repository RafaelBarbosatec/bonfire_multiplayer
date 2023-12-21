import 'dart:async';

import '../../main.dart';
import 'game_component.dart';

abstract class Game {
  List<GameComponent> components = [];
  final List<GameComponent> _compsToRemove = [];

  Timer? _gameTimer;
  bool _needUpdate = false;
  final DateTime _initialTime = DateTime.now();
  double get _currentTime =>
      DateTime.now().difference(_initialTime).inMilliseconds / 1000.0;
  double _previous = 0;

  void onUpdate(double dt) {
    for (final element in components) {
      element.onUpdate(dt);
    }

    if (_compsToRemove.isNotEmpty) {
      for (final comp in _compsToRemove) {
        components.remove(comp);
      }
      _compsToRemove.clear();
    }

    if (_needUpdate) {
      _needUpdate = false;
      onUpdateState('');
    }
  }

  void requestUpdate(String id) {
    _needUpdate = true;
  }

  void onUpdateState(String key);

  void start() {
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
  }

  void stop() {
    logger.i('Stop Game loop');
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void add(GameComponent comp) {
    comp.game = this;
    components.add(comp);
  }

  void remove(GameComponent comp) {
    _compsToRemove.add(comp);
  }
}
