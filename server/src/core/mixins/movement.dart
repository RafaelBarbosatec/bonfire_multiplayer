import 'package:shared_events/shared_events.dart';

import '../game_component.dart';

mixin Movement on GameComponent {
  static const diaginalReduction = 0.7853981633974483;
  double speed = 0;

  void moveFromDirection(double dt, MoveDirectionEnum direction) {
    final displacement = dt * speed;
    switch (direction) {
      case MoveDirectionEnum.left:
        position.x -= displacement;
      case MoveDirectionEnum.right:
        position.x += displacement;
      case MoveDirectionEnum.up:
        position.y -= displacement;
      case MoveDirectionEnum.down:
        position.y += displacement;
      case MoveDirectionEnum.upLeft:
        position.y -= displacement * diaginalReduction;
        position.x -= displacement * diaginalReduction;
      case MoveDirectionEnum.upRight:
        position.y -= displacement * diaginalReduction;
        position.x += displacement * diaginalReduction;
      case MoveDirectionEnum.downLeft:
        position.y += displacement * diaginalReduction;
        position.x -= displacement * diaginalReduction;
      case MoveDirectionEnum.downRight:
        position.y += displacement * diaginalReduction;
        position.x += displacement * diaginalReduction;
    }
  }
}
