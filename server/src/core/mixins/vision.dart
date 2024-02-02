import '../game_component.dart';

mixin Vision on GameComponent {
  @override
  void onUpdate(double dt) {
    // TODO: implement onUpdate
    super.onUpdate(dt);
  }

  void onFieldOfVision(List<GameComponent> components) {}
}
