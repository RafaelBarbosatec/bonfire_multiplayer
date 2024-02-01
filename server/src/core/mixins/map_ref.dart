
import '../game_component.dart';
import '../game_map.dart';

mixin MapRef<T extends GameMap> on GameComponent {
  T get map {
    return _checkAndReturnGame(parent);
  }

  T _checkAndReturnGame(GameComponent? parent) {
    if (parent is T) {
      return parent;
    } else {
      return _checkAndReturnGame(parent?.parent);
    }
  }
}
