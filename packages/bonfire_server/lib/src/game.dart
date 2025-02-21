import 'dart:async';

import 'package:bonfire_server/src/components/game_component.dart';
import 'package:bonfire_server/src/components/game_map.dart';

abstract class Game extends GameComponent {
  Game({this.maps = const [], super.components});

  final List<GameMap> maps;
  bool _mapLoaded = false;
  bool get mapsIsLoaded => _mapLoaded;

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
        updateListeners(comp);
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

  void updateListeners(GameComponent compChanged);

  Future<void> start() async {
    await onLoadMaps();
    _gameTimer ??= Timer.periodic(
      const Duration(milliseconds: 30),
      (timer) {
        final curr = _currentTime;
        final dt = curr - _previous;
        _previous = curr;
        onUpdate(dt);
      },
    );
    onStarted();
  }

  void stop() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void onStarted() {}

  Future<void> onLoadMaps() async {
    if (!_mapLoaded) {
      addAll(maps);
      for (final map in maps) {
        await map.load();
      }
      _mapLoaded = true;
    }
  }
}
