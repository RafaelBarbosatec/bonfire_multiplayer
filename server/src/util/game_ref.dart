import '../core/game.dart';
import '../core/game_component.dart';

mixin GameRef<T extends Game> on GameComponent {
  T get game {
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
