import 'game.dart';

abstract class GameComponent<T> {
  late Game<T> game;
  void onUpdate(double dt);
  void removeFromParent() {
    game.remove(this);
  }
}
