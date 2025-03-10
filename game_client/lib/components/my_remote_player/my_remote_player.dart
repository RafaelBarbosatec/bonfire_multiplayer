import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/my_player.dart';
import 'package:bonfire_multiplayer/components/my_remote_player/bloc/my_remote_player_bloc.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/name_bottom.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:bonfire_multiplayer/util/update_movement_mixin.dart';

class MyRemotePlayer extends SimplePlayer
    with
        BlockMovementCollision,
        WithNameBottom,
        UpdateMovementMixin,
        BonfireBlocListenable<MyRemotePlayerBloc, MyRemotePlayerState> {
  final String id;
  MyRemotePlayer({
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
    bloc = MyRemotePlayerBloc(
      id,
      position,
      eventManager,
    );
    movementOnlyVisible = false;
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
    // cancel collision with Myplayer
    if (other is MyPlayer || other is MyRemotePlayer) {
      return false;
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void onNewState(MyRemotePlayerState state) {
    updateStateMove(state);
    super.onNewState(state);
  }

  @override
  void onRemove() {
    bloc.add(RemoveSbscribe());
    super.onRemove();
  }

  // do override to disable update direction
  @override
  void translate(Vector2 displacement) {
    position.add(displacement);
  }
}
