import 'package:bonfire_server/src/components/positioned_game_component.dart';
import 'package:bonfire_server/src/util/game_timer.dart';
import 'package:shared_events/shared_events.dart';

export 'package:bonfire_server/src/extensions/movement_ext.dart';

mixin Movement on PositionedGameComponent {
  /// Diagonal speed factor. MUST match the client's `Movement.diagonalFactor`
  /// (bonfire lib: √2/2 ≈ 0.7071): a different factor makes the authoritative
  /// server walk diagonals faster/slower than the client's prediction, so the
  /// two drift apart over time and server-positioned effects (attack slash)
  /// appear far from the rendered player.
  static const double diaginalReduction = 0.7071067811865476;

  MoveDirectionEnum? direction;
  final GameTimer _timer = GameTimer(
    duration: 0.05,
    loop: true,
  ); // 20Hz position updates while moving (was 1s -> remote players "stop-and-go")
  double speed = 0;

  void moveFromDirection(double dt, MoveDirectionEnum direction) {
    final newPosition = _getNewPosition(dt, direction);
    if (newPosition != position) {
      if (direction != this.direction) {
        this.direction = direction;
        requestUpdate();
      }
      onMove(newPosition);
    }
  }

  GameVector _getNewPosition(double dt, MoveDirectionEnum direction) {
    final displacement = dt * speed;
    switch (direction) {
      case MoveDirectionEnum.left:
        return position.copyWith(x: position.x - displacement);
      case MoveDirectionEnum.right:
        return position.copyWith(x: position.x + displacement);
      case MoveDirectionEnum.up:
        return position.copyWith(y: position.y - displacement);
      case MoveDirectionEnum.down:
        return position.copyWith(y: position.y + displacement);
      case MoveDirectionEnum.upLeft:
        return position.copyWith(
          y: position.y - displacement * diaginalReduction,
          x: position.x - displacement * diaginalReduction,
        );
      case MoveDirectionEnum.upRight:
        return position.copyWith(
          y: position.y - displacement * diaginalReduction,
          x: position.x + displacement * diaginalReduction,
        );
      case MoveDirectionEnum.downLeft:
        return position.copyWith(
          y: position.y + displacement * diaginalReduction,
          x: position.x - displacement * diaginalReduction,
        );
      case MoveDirectionEnum.downRight:
        return position.copyWith(
          y: position.y + displacement * diaginalReduction,
          x: position.x + displacement * diaginalReduction,
        );
    }
  }

  // ignore: use_setters_to_change_properties
  void onMove(GameVector newPosition) {
    position = newPosition;
  }

  void onStopMove() {
    direction = null;
    requestUpdate();
  }

  void stopMove() {
    if (direction != null) {
      onStopMove();
    }
  }

  @override
  void onUpdate(double dt) {
    super.onUpdate(dt);
    if (direction != null && _timer.update(dt)) {
      requestUpdate();
    }
  }
}
