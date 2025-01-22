import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/name_bottom.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';

import 'bloc/my_remote_enemy_bloc.dart';

class MyRemoteEnemy extends SimpleEnemy
    with
        BlockMovementCollision,
        WithNameBottom,
        BonfireBlocListenable<MyRemoteEnemyBloc, MyRemoteEnemyState> {
  final String id;
  MyRemoteEnemy({
    required super.position,
    required PlayerSkin skin,
    required GameEventManager eventManager,
    required this.id,
    required String name,
    Direction? initDirection,
    super.speed,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(skin.path),
          initDirection: initDirection ?? Direction.down,
        ) {
    this.name = name;

    bloc = MyRemoteEnemyBloc(
      id,
      position,
      eventManager,
    );
  }

  @override
  Future<void> onLoad() {
    // adds Rectangle collision
    add(
      RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
      ),
    );
    return super.onLoad();
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    // cancel collision with MyRemoteEnemy
    if (other is MyRemoteEnemy) {
      return false;
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void onNewState(MyRemoteEnemyState state) {
    // if distance greater than 5 pixel do interpolation of position
    if (position.distanceTo(state.position) > 5) {
      add(
        MoveEffect.to(
          state.position,
          EffectController(duration: 0.05),
        ),
      );
    }
    if (state.direction != null) {
      setZeroVelocity();
      moveFromDirection(state.direction!.toDirection());
    } else {
      lastDirection = state.lastDirection.toDirection();
      stopMove();
    }
    super.onNewState(state);
  }

  @override
  void onRemove() {
    bloc.add(RemoveSubscribe());
    super.onRemove();
  }

  // do override to disable update direction
  @override
  void translate(Vector2 displacement) {
    position.add(displacement);
  }
}
