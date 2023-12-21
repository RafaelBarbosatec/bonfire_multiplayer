import 'game.dart';

abstract class GameComponent {
  late Game game;
  void onUpdate(double dt);
  void removeFromParent() {
    game.remove(this);
  }
}
